
% ROI_threshold_calculation.m
%
% SCRIPT for imlook4d to obtain ROI from pixels above threshold and
% calculate PVE-corrected activities for the ROIs
%
%Threshold is calculated as a wheighted sum of tumor and background
%intensity.
%
%ROI is drawn employing a region growing method, where pixels in the 
%currently selected frame are compared to the threshold.
%
% The script uses the file reconstruction_methods.m to define parameters 
% for different reconstruction methods. These parameters are specific for
% each reconstruction method. Using wrong parameters will yield incorrect
% results.
%
% Elin Wallstén


    StartScript
    historyDescriptor='New ROI'; 
    go_on=0; %variable for continue with activity calculation, set by gui_threshold_calc. 
    own_roi=0; % variable for defining own roi, set by gui_threshold_calc.
    
    h = gui_threshold_calc;
    uiwait(h);
    
    
    Export
    
    if size(imlook4d_Cdata, 4)==1
        image_temp=imlook4d_Cdata;
    else image_temp=imlook4d_Cdata(:, :, :, imlook4d_frame); % Sets current frame as foundation for volume calculation
    end
    
    ROI_start=single(imlook4d_ROI); %Save start ROI.
    nr_tumours=max(ROI_start(:))/2;
    
    %
    % Calculate new ROI if old ROI is not ready to use. 
    %    
    if own_roi==0 
        imlook4d_ROI=imlook4d_ROI.*0;
        
        for t=1:nr_tumours
            ROI_tumour=single(ROI_start==(2*t-1));
            ROI_tumour_content=ROI_tumour.*image_temp;
            [roi_max, z]=max(max(max(ROI_tumour_content)));
            [~, y]=max(max(ROI_tumour_content(:, :, z)));
            [~, x]=max(max(ROI_tumour_content(:, :, z).'));

            T_70=0.7*roi_max;

            ROI_70=regiongrow(image_temp,T_70,x,y,z);
            I_70=sum(ROI_70(:).*image_temp(:))/sum(ROI_70(:));   

            ROI_bgd=single(ROI_start==(2*t));
            I_bgd=sum(ROI_bgd(:).*image_temp(:))/sum(ROI_bgd(:));    
            if max(ROI_bgd(:).*image_temp(:))>max(ROI_tumour_content(:))
                errordlg('ROIs are not drawn in correct order. Please try again.')
                error('ROIs are not drawn in correct order.')
            end

            T_bgd=I_bgd+epsilon*I_70; % T_bgd is the threshold used for new ROI calculations.

             ROI_T_bgd=regiongrow(image_temp,T_bgd,x,y,z);
             I_T_bgd=sum(ROI_T_bgd(:).*image_temp(:))/sum(ROI_T_bgd(:));

             imlook4d_ROI=imlook4d_ROI+int8(ROI_T_bgd.*(2*t-1));
             imlook4d_ROI=imlook4d_ROI+int8(ROI_bgd.*(2*t));
        end          
    end
     
    volumes=zeros(nr_tumours, 1);
    
        
    %
    % If user choses, calculate correction factors.
    %
    if go_on==1
        %
        % Define fourier transforms.
        %
        FFTN = @(x)fftshift(fftn(ifftshift(x)));
        iFFTN = @(x)fftshift(ifftn(ifftshift(x)));
        size_roi=size(imlook4d_ROI);
        
        %
        % Define the point spread function
        %
        
        x=1:1:size_roi(1);
        x=single(x);
        y=1:1:size_roi(2);
        y=single(y);
        z=1:1:size_roi(3);
        z=single(z);
        [X, Y, Z]=ndgrid(x, y, z);
        mux=(size_roi(1)+2)/2;
        muy=(size_roi(2)+2)/2;
        muz=(size_roi(3)+1)/2;
        
        sigma_xy=psf_values(1)/imlook4d_current_handles.image.pixelSizeX;
        sigma_z=psf_values(2)/imlook4d_current_handles.image.sliceSpacing;
        
        psf=(1/(2*pi)^(3/2))*(1/(sigma_xy*sigma_xy*sigma_z))*exp(-(((X-mux).^2)/(2*sigma_xy^2)+((Y-muy).^2)/(2*sigma_xy)+((Z-muz).^2)/(2*sigma_z^2)));
        ftn_psf=FFTN(psf);
        
        corr_spread_out=zeros(1, nr_tumours);
        corr_spread_in=zeros(1, nr_tumours);
        original_uptake=zeros(nr_tumours, size(imlook4d_Cdata, 4));
        corrected_uptake=zeros(nr_tumours, size(imlook4d_Cdata, 4));
        
        contents=cell(1, nr_tumours);
        tumour_roi_names=cell(1, nr_tumours);
        
        d = waitbar(0,'Correction factors are calculated...'); 
        
        
        %
        % Calculate correction factor for each ROI in each frame.
        %
        for i=1:nr_tumours          
            
            waitbar(i/nr_tumours, d)
            
            roi=single((imlook4d_ROI==(2*i-1)));
            
            volumes(i)=sum(roi(:))*imlook4d_current_handles.image.pixelSizeX*imlook4d_current_handles.image.pixelSizeY*imlook4d_current_handles.image.sliceSpacing/(1E3);
                        
            contents{i}=[imlook4d_ROINames{2*i-1} ' (' num2str(volumes(i), '%3.2f') ' ml)' ];
            tumour_roi_names{i}=imlook4d_ROINames{2*i-1};
            
            ftn_roi=FFTN(roi);

            ftn_conv_roi=ftn_roi.*ftn_psf;
            conv_roi=iFFTN(ftn_conv_roi);

            inv_roi=roi;
            inv_roi(inv_roi==0)=20;
            inv_roi(inv_roi==1)=0;
            inv_roi(inv_roi==20)=1;

            ftn_inv_roi=FFTN(inv_roi);
            ftn_conv_inv_roi=ftn_inv_roi.*ftn_psf;
            conv_inv_roi=iFFTN(ftn_conv_inv_roi);

            corr_spread_out(i)=sum(conv_roi(:).*roi(:))/sum(roi(:));  
            corr_spread_in(i)=1-corr_spread_out(i);
            ROI_bgd=single(ROI_start==(2*i));
            for j=1:size(imlook4d_Cdata, 4)                
                image_temp2=imlook4d_Cdata(:, :, :, j);
                I_bgd=sum(image_temp2(:).*ROI_bgd(:))/sum(ROI_bgd(:));
                original_uptake(i, j)=sum(roi(:).*image_temp2(:))/sum(roi(:));
                corrected_uptake(i, j)=(original_uptake(i, j)-corr_spread_in(i)*I_bgd)/corr_spread_out(i);
            end
        end
        
        delete(d)
    
        time_scale=[0:1:(size(imlook4d_Cdata, 4)-1)].*imlook4d_duration;
      
        %
        %Plot the results
        %
        g=figure('Name', 'TACT', 'NumberTitle' ,'off');
        subplot(2, 1, 1)
        plot(time_scale, original_uptake, '-o') 
        ax1=axis;
        legend(contents, 'Location','BestOutside' ); 
        title('TACT without PVE correction')
        xlabel('Time [s]');
        ylabel('Intensity');

        
        subplot(2, 1, 2)
        plot(time_scale, corrected_uptake, '-o')  
        ax2=axis;
        legend(contents, 'Location','BestOutside'); 
        title('TACT with PVE correction')
        xlabel('Time [s]');
        ylabel('Intensity');
        
        x_min=min(ax1(1), ax2(1));
        x_max=max(ax1(2), ax2(2));
        y_min=min(ax1(3), ax2(3));
        y_max=max(ax1(4), ax2(4));
        
        subplot(2, 1, 1)
        axis([x_min, x_max, y_min, y_max])
        subplot(2, 1, 2)
        axis([x_min, x_max, y_min, y_max])
        
    %
    % Save to text file.
    %
        [file,path] = uiputfile('TACT.xls','TACT-curve Save file name');
        fullPath=[path file];
        
        roiNames=imlook4d_ROINames(1:size(imlook4d_ROINames,1)-1);      % Remove "Add ROI"
        
        tempHeader={'frame', 'time [s]', 'duration [s]',  tumour_roi_names{:}};
        
        tactHeader=[sprintf(['%s uncorrected' '\t'], tempHeader{:})  sprintf(['%s PVE-corrected ' '\t'], tumour_roi_names{:}  )];
        tactHeader=tactHeader(1:end-1); % Remove last TAB

        frameNumbers=1:size(time_scale,2);
        
        dataTable=num2cell([ frameNumbers' time_scale' imlook4d_duration' double(original_uptake') double(corrected_uptake')]);  % ROI-upptag
        
        
        % JAN: Add volumes in row below ROI uptake data
            dataTable3=cell(1,size(dataTable,2)); % Empty row 
            dataTable=[dataTable; dataTable3];    % Add empty row

            offset=size(dataTable,2)-size(volumes,1); % First column
            for i=1:( size(dataTable,2)-offset )
                dataTable3{i+offset}=volumes(i);
            end
            dataTable3{1}='Volumes';                 % Lable for volumes row
            dataTable=[dataTable; dataTable3];       % add row with volumes
        
        % Save to disk
        try
        save_cellarray( dataTable, fullPath, tactHeader );
        catch
            
        end          
        
    end
    
    EndScript 
