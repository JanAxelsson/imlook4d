function  ExportROIs( roiNumbers)

% Used by ROI_data_to_workspace.m
%
% This script assumes that imlook4d_current_handle is set in base workspace
%
% This script generates a cell of columnvectors, with the pixel values in each ROI:
% If called without argument roiNumbers, all ROIs are calculated.
% If called by roiNumbers the column 1 up to first roiNumber are set to zero.  
%
% SCRIPT for imlook4d
% Jan Axelsson




%
% INITIALIZE
%
    %  imlook4d_current_handles is updated whenever SCRIPTS menu in imlook4d is
    %  selected
    %imlook4d_ROI_vectors={};
    
    STAT_TOOLBOX = 1; % assume existing
    
    imlook4d_ROI_data=[];

    
    % Import from workspace
    try
        imlook4d_current_handle=evalin('base', 'imlook4d_current_handle');
        imlook4d_current_handles = evalin('base', 'guidata(imlook4d_current_handle)' ); % Read updated handles from imlook4d window

    catch
        disp('failed importing imlook4d_current_handles from base workspace');
    end 
    
%     StoreVariables
%     Export
    try
        evalin('base', 'Menu(''Export (untouched)'')');    
        imlook4d_Cdata=evalin('base', 'imlook4d_Cdata');
        imlook4d_ROI=evalin('base', 'imlook4d_ROI');
        imlook4d_frame=evalin('base', 'imlook4d_frame');
    catch
        disp('failed importing variables from base workspace');
    end  
       
    
    
   % lastROI=max(imlook4d_ROI(:));  % 
    names=get(imlook4d_current_handles.ROINumberMenu,'String');
    names=names(1:end-1);
    
    imlook4d_ROI_data.names=names;
    
    lastROI=length( names);
    
    if ( lastROI < 1 )
        displayMessageRowError('No ROIs defined')
        return
    end
    
        
    if nargin == 0
        roiNumbers = 1 : lastROI;
    end
    
    numberOfFrames=size(imlook4d_Cdata,4);

    
%
% Export imlook4d window info
%
    try
         imlook4d_ROI_data.window_title = get(imlook4d_current_handles.figure1,'Name');
         imlook4d_ROI_data.image_directory = imlook4d_current_handles.image.folder;
    catch
    end
%
% Export unit
%
    try
        imlook4d_ROI_data.unit = imlook4d_current_handles.image.unit;
    catch
        imlook4d_ROI_data.unit = '';
    end
%
% Export times and durations
%
    try
        imlook4d_ROI_data.midtime=imlook4d_current_handles.image.time'+0.5*imlook4d_current_handles.image.duration';
    catch
        
    end
    try
        imlook4d_ROI_data.duration=imlook4d_current_handles.image.duration';
    catch
        
    end    
%
% LOOP ROIs
%

    
    % Remove hidden ROIs from calculation
     counter = 0;
     for i=roiNumbers
            if  not( contains( imlook4d_ROI_data.names{i},'(hidden)' ) )
                counter = counter + 1;
                newRoiNumbers(counter) = i;
            end    
     end
    roiNumbers = newRoiNumbers;
    
    %for i=1:lastROI
    for i=roiNumbers
        
        disp([num2str(i) ') Evaluating ROI=' names{i}]);
        roiPixels=[]; % All pixel values in current ROI

% SLOW old way:
%        % loop frames
%             for j=1:size(imlook4d_Cdata,4)
%                 oneFrame=imlook4d_Cdata(:,:,:,j);
%                 roiPixels(:,j)=oneFrame(imlook4d_ROI==i);
%                 imlook4d_ROI_data.Npixels(i)=length(roiPixels(:,j));
%             end        
        
% New way:
        
        % Determine indeces to Cdata matrix for this ROI
        indecesToROI=find(imlook4d_ROI==i); % from ROI definition
        NPixels(i)=size(indecesToROI,1);    % Number of pixels in ROI i
        offset=size(imlook4d_ROI(:),1 );    % offset to next frame (number of pixels in volume)
        allIndecesToROI=zeros(size(indecesToROI,1),numberOfFrames); % place for indeces in all frames
        
        % Get all indeces
        for j=1:numberOfFrames 
            allIndecesToROI(:,j)=indecesToROI+(j-1)*offset;
        end
        
        roiPixels = double( imlook4d_Cdata(allIndecesToROI) );

% Same as before:        
        
        % loop frames
            for j=1:size(imlook4d_Cdata,4)
%                 oneFrame=imlook4d_Cdata(:,:,:,j);
%                 roiPixels(:,j)=oneFrame(imlook4d_ROI==i);
                imlook4d_ROI_data.Npixels(i)=length(roiPixels(:,j));
            end
            
       % Assign matrix to the cell of ROI i
       % imlook4d_ROI_vectors{i}=roiPixels;

            imlook4d_ROI_data.mean(:,i)=mean(roiPixels)';
            imlook4d_ROI_data.stdev(:,i)=std(roiPixels)';
            
            try
                imlook4d_ROI_data.skewness(:,i)=imlook4d_skewness(roiPixels)';
                imlook4d_ROI_data.kurtosis(:,i)=imlook4d_kurtosis(roiPixels)';
            catch
                % Missing Statistical toolbox
                STAT_TOOLBOX = 0;
            end
            
            
           % imlook4d_ROI_data.stdev_pos_values(:,i)=std(roiPixels(roiPixels>0))';  % Stdev of pixels that have value above zero
           % imlook4d_ROI_data.stdev_pos_values(:,i)=std(roiPixels(:,i)>0)';  
            
            imlook4d_ROI_data.pixels{i}=roiPixels;
            try
                if isempty(roiPixels)
                    imlook4d_ROI_data.max(:,i)=NaN(numberOfFrames,1);
                    imlook4d_ROI_data.min(:,i)=NaN(numberOfFrames,1);
                else
                    imlook4d_ROI_data.max(:,i)=max(roiPixels)';
                    imlook4d_ROI_data.min(:,i)=min(roiPixels)';
                end
                
                
            catch
                imlook4d_ROI_data.max(:,i)=0;
                imlook4d_ROI_data.min(:,i)=0;
            end
       
            try
                dX=imlook4d_current_handles.image.pixelSizeX;  % mm
                dY=imlook4d_current_handles.image.pixelSizeY;  % mm
                dZ=imlook4d_current_handles.image.sliceSpacing;% mm
                dV=abs( dX*dY*dZ/1000 );  % cm3
            catch
                dX=0;
                dY=0;
                dZ=0;
                dV=0;
            end
            
            imlook4d_ROI_data.volume(i)=dV*length(roiPixels);   % cm3
            imlook4d_ROI_data.voxelsize=[dX dY dZ dV];
        
        % Calculate Centroid and dimensions
            M=imlook4d_ROI;
            TotalMass=sum(M(:)==i);

            X=1:size(M,1); 
            SumX=sum( sum(M==i,3),2);  % creating a sum vector: sum Z values, then rows
            CG_X= sum(SumX(:).*X(:))/TotalMass;
            imlook4d_ROI_data.centroid{i}.x=CG_X;
            find(SumX);
            imlook4d_ROI_data.dimension{i}.x=max(find(SumX))-min(find(SumX))+1;          

            Y=1:size(M,2); %
            SumY=sum( sum(M==i,3),1); % creating a sum vector: sum Z values, then columns
            CG_Y= sum(SumY(:).*Y(:))/TotalMass;
            imlook4d_ROI_data.centroid{i}.y=CG_Y;
            imlook4d_ROI_data.dimension{i}.y=max(find(SumY))-min(find(SumY))+1;

            Z=1:size(M,3);
            SumZ=sum( sum(M==i,1),2); % creating a sum vector: sum columns, then rows
            CG_Z= sum(SumZ(:).*Z(:))/TotalMass;
            imlook4d_ROI_data.centroid{i}.z=CG_Z;
            
            imlook4d_ROI_data.dimension{i}.z=max(find(SumZ))-min(find(SumZ))+1;
            
        % Calculate Entropy and uniformity
        % As used in Ganeshan et al, Eur J Rad 70 (2009) p.101-110
            for j=1:numberOfFrames
                A = roiPixels(:,j);
                N = 128;  % Use fixed number of levels.  Entropy is dependent on N!
                p = hist(A, N) ./ numel(A);
                imlook4d_ROI_data.uniformity(j,i) = sum(p.^2);  % Uniformity
                imlook4d_ROI_data.entropy(j,i) = -sum(p.*(log2( (p + eps)  ))); % Entropy
            end
            

    end
    
    %
    % PVE-correction (if correction factors exist in pveFactors, typically generated in script beforehand)
    %
    if exist('pveFactors')
        try
            imlook4d_ROI_data.pve = (pveFactors' \ imlook4d_ROI_data.mean')';
        catch
        end
    end
    
    %
    % Print data
    %

        % Find frame to use (set to frame=1 when a model is used)
            
            frame=imlook4d_frame;
            if (frame>size(imlook4d_ROI_data.mean,1))
                frame=1;
            end
            
        % Not PVE-corrected data
        data=[ imlook4d_ROI_data.mean(frame,:),
            imlook4d_ROI_data.volume(:)',
            imlook4d_ROI_data.Npixels(:)',
            imlook4d_ROI_data.max(frame,:),
            imlook4d_ROI_data.min(frame,:),
            imlook4d_ROI_data.stdev(frame,:)]';
        
        
        TAB=sprintf('\t');
        disp(' ');
        if (STAT_TOOLBOX)
            if isfield(imlook4d_ROI_data,'pve')
                % PVE-corrected
                disp([ 'ROI-name'  TAB 'pvc-mean'  TAB 'mean'  TAB 'volume[cm3]' TAB '# of pixels' TAB 'max     ' TAB 'min     ' TAB 'stdev   '  TAB 'skewness   ' TAB 'kurtosis   ' TAB 'uniformity   ' TAB 'entropy   ']);
                data=[ imlook4d_ROI_data.pve(frame,:),
                    imlook4d_ROI_data.mean(frame,:),
                    imlook4d_ROI_data.volume(:)',
                    imlook4d_ROI_data.Npixels(:)',
                    imlook4d_ROI_data.max(frame,:),
                    imlook4d_ROI_data.min(frame,:),
                    imlook4d_ROI_data.stdev(frame,:)]';
            else
                % Not corrected
                disp([ 'ROI-name'  TAB 'mean'  TAB 'volume[cm3]' TAB '# of pixels' TAB 'max     ' TAB 'min     ' TAB 'stdev   '  TAB 'skewness   ' TAB 'kurtosis   ' TAB 'uniformity   ' TAB 'entropy   ']);
            end
        else
            disp([ 'ROI-name'  TAB 'mean'  TAB 'volume[cm3]' TAB '# of pixels' TAB 'max     ' TAB 'min     ' TAB 'stdev   ' TAB 'uniformity   ' TAB 'entropy   ' ]);
        end
     


            
            if (STAT_TOOLBOX)  % No need for STAT_TOOLBOX anymore
                % Append columns to the right
                data = [ data imlook4d_ROI_data.skewness(frame,:)' imlook4d_ROI_data.kurtosis(frame,:)'];   
                data = [ data imlook4d_ROI_data.uniformity(frame,:)' imlook4d_ROI_data.entropy(frame,:)' ];   
            end
           
            %for i=1:size(data,1)
            for i=roiNumbers
                disp(sprintf('%s\t%9.5f\t%9.5f\t%9d\t%9.5f\t%9.5f\t',names{i},data(i,:)));
            end  
            
            disp(['Pixel dimensions=(' num2str(dX) ', ' num2str(dY) ', ' num2str(dZ) ') [mm]']);
    
    
    %ClearVariables
   assignin('base', 'imlook4d_ROI_data', imlook4d_ROI_data);
