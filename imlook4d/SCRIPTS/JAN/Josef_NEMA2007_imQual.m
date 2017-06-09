% NEMA2007_imQual.m
% Script for creating ROIs for NEMA image quality phantom
% Josef Lundman 2012-12-06
%
% Instructions:
% 1) Go to slice where the spheres are centered
% 2) Run script and give slice number and background
% 3) Check that the ROIs are correctly placed
% 4) Copy data from output Struct in Workspace to where you need it

% Output:
%   ROIout.bg      - Background activity for the 12 ROIs. 1st column gives
%                    ROI diameter in mm, 2nd gives the slice position rel.
%                    to the central slice and column 3-14 gives the ROI
%                    activity of ROI 1-12 respectively.
%
%   ROIout.Spheres - 1st row specifies the sphere size and 2nd gives ROI
%                    activity of the sphere.
%
%   ROIout.Lung    - Not yet implemented.

%
% Initialize
%
    StoreVariables  % Remember variables
    Export

    TAB=sprintf('\t');

    % Get user input
    prompt={'Slice with centre of the spheres (slice number)',...
                'Background (approximate absolute value)'};
        title='Image series information';
        numlines=1;
    if ~exist('defaultanswer')  % If variable defaultanswer is not predefined outside script, set values
    	defaultanswer={'8','7500'};
    end
    
    answer=inputdlg(prompt,title,numlines,defaultanswer);
    deltaSlice=imlook4d_current_handles.image.sliceSpacing;% mm
    
    centralSlice=str2num(answer{1});
    centralSliceMinusTwoCM=centralSlice-round(20/deltaSlice);
    centralSliceMinusOneCM=centralSlice-round(10/deltaSlice);
    centralSlicePlusOneCM=centralSlice+round(10/deltaSlice);
    centralSlicePlusTwoCM=centralSlice+round(20/deltaSlice);
    
    % Calculate max level in current frame and set as max threshold level
    MaxThresholdLevel=max(reshape(imlook4d_Cdata(:,:,:,imlook4d_frame), 1,size(imlook4d_Cdata,1)*size(imlook4d_Cdata,2)*size(imlook4d_Cdata,3)  ) );
    % Set minimum threshold level as half the background level
    MinThresholdLevel=round(str2num(answer{2})/2);
    
    activeROI=get(imlook4d_current_handles.ROINumberMenu,'Value');
    
% 
% PROCESS (Set background ROI)
%
    newROI=zeros(size(imlook4d_ROI),'uint8');
    
    % Define pixels in new ROI
    for i=centralSliceMinusTwoCM:centralSlicePlusTwoCM
        
        % Get temporary image, and threshold levels
        temp=imlook4d_Cdata(:,:,i,imlook4d_frame);                   % Current Image, defined by current slice and frame
  
        % New ROI (new algorithm)
            newROI(:,:,i)=  uint8( activeROI*( (temp>MinThresholdLevel) & (temp<=MaxThresholdLevel) ) ) ;       
        
    end
    
    % Add pixels to new ROI
    imlook4d_ROI=imlook4d_ROI - uint8(newROI>0).*imlook4d_ROI ;   % Remove existing ROI pixels that overlap new ROI
    imlook4d_ROI=imlook4d_ROI + uint8(newROI>0).*newROI;          % Add new ROI pixels
    
%
% CONTINUE (Place NEMA2007 ROIs) 
%

    % Diameters of ROIs in mm
    d=[10, 13, 17, 22, 28, 30, 37];
    
    % Radius of ROIs in mm
    radie=d./2;
    
    %
    % Get parameters
    %
        dX=imlook4d_current_handles.image.pixelSizeX;  % mm
        dY=imlook4d_current_handles.image.pixelSizeY;  % mm
        dZ=imlook4d_current_handles.image.sliceSpacing;% mm
    
        % radius in pixels
        radie=radie/dX;
        
    %
    % Define extent for current slice (in pixels)
    %
        midPoint=size(imlook4d_Cdata,1)/2;
        X1_minus2cm=min(find(imlook4d_ROI(:,midPoint,centralSliceMinusTwoCM)==1));
        X2_minus2cm=max(find(imlook4d_ROI(:,midPoint,centralSliceMinusTwoCM)==1));
        Y1_minus2cm=min(find(imlook4d_ROI(midPoint,:,centralSliceMinusTwoCM)==1));
        Y2_minus2cm=max(find(imlook4d_ROI(midPoint,:,centralSliceMinusTwoCM)==1));
        
        X1_minus1cm=min(find(imlook4d_ROI(:,midPoint,centralSliceMinusOneCM)==1));
        X2_minus1cm=max(find(imlook4d_ROI(:,midPoint,centralSliceMinusOneCM)==1));
        Y1_minus1cm=min(find(imlook4d_ROI(midPoint,:,centralSliceMinusOneCM)==1));
        Y2_minus1cm=max(find(imlook4d_ROI(midPoint,:,centralSliceMinusOneCM)==1));
        
        X1=min(find(imlook4d_ROI(:,midPoint,centralSlice)==1));
        X2=max(find(imlook4d_ROI(:,midPoint,centralSlice)==1));
        Y1=min(find(imlook4d_ROI(midPoint,:,centralSlice)==1));
        Y2=max(find(imlook4d_ROI(midPoint,:,centralSlice)==1));
        
        X1_plus1cm=min(find(imlook4d_ROI(:,midPoint,centralSlicePlusTwoCM)==1));
        X2_plus1cm=max(find(imlook4d_ROI(:,midPoint,centralSlicePlusTwoCM)==1));
        Y1_plus1cm=min(find(imlook4d_ROI(midPoint,:,centralSlicePlusTwoCM)==1));
        Y2_plus1cm=max(find(imlook4d_ROI(midPoint,:,centralSlicePlusTwoCM)==1));
        
        X1_plus2cm=min(find(imlook4d_ROI(:,midPoint,centralSlicePlusTwoCM)==1));
        X2_plus2cm=max(find(imlook4d_ROI(:,midPoint,centralSlicePlusTwoCM)==1));
        Y1_plus2cm=min(find(imlook4d_ROI(midPoint,:,centralSlicePlusTwoCM)==1));
        Y2_plus2cm=max(find(imlook4d_ROI(midPoint,:,centralSlicePlusTwoCM)==1));
    
    ROI_coordinates=[ ...
        0.5158    0.1266
        0.7789    0.2405
        0.8526    0.3924
        0.9158    0.5696
        0.9158    0.7342
        0.8033    0.886
        0.6316    0.8861
        0.4842    0.8861
        0.2421    0.8608
        0.1053    0.7342
        0.0632    0.5190
        0.2105    0.2405 ];

%
% Make 12 ROIs (clear existing)
%
        
        imlook4d_ROI(2:end)=0;
        
        addROI=imlook4d_ROINames{end};  % Store name for "add ROI" command
        
        ROIout.bg=zeros(35,12);
        for i=1:length(d)
            ROIout.bg(5*i-4,2)=-2; ROIout.bg(5*i-4,1)=d(i);
            ROIout.bg(5*i-3,2)=-1; ROIout.bg(5*i-3,1)=d(i);
            ROIout.bg(5*i-2,2)=0; ROIout.bg(5*i-2,1)=d(i);
            ROIout.bg(5*i-1,2)=1; ROIout.bg(5*i-1,1)=d(i);
            ROIout.bg(5*i,2)=2; ROIout.bg(5*i,1)=d(i);
        end
            
        for k=1:length(radie);
            r=radie(k);
            for i=1:size(ROI_coordinates,1)
                imlook4d_ROINames{i}=['ROI ' num2str(i)];

                Xc=round( absoluteCoordinate(X1_minus2cm,X2_minus2cm,ROI_coordinates(i,1)) );
                Yc=round( absoluteCoordinate(Y1_minus2cm,Y2_minus2cm,ROI_coordinates(i,2)) );
                imlook4d_ROI(:,:,centralSliceMinusTwoCM)=circleROI(imlook4d_ROI(:,:,centralSliceMinusTwoCM), i, Xc, Yc, r);
                
                % Calculate activity concentration in ROI
                [tempData(:,:,centralSliceMinusTwoCM,:), explainedFraction, fullEigenValues]=imlook4d('generateImage',imlook4d_current_handles, centralSliceMinusTwoCM, 1);
                numberOfFrames=size(tempData,4);
                indecesToROI=find(imlook4d_ROI(:,:,centralSliceMinusTwoCM)==i);
                tempData2=tempData(:,:,centralSliceMinusTwoCM);
                roiPixelValues=tempData2(indecesToROI);
                activity(i,1)=mean( reshape(roiPixelValues,[],numberOfFrames),1 ); % Mean value of each column
                
                ROIout.bg(k*5-4,i+2)=activity(i,1);
                
                Xc=round( absoluteCoordinate(X1_minus1cm,X2_minus1cm,ROI_coordinates(i,1)) );
                Yc=round( absoluteCoordinate(Y1_minus1cm,Y2_minus1cm,ROI_coordinates(i,2)) );
                imlook4d_ROI(:,:,centralSliceMinusOneCM)=circleROI(imlook4d_ROI(:,:,centralSliceMinusOneCM), i, Xc, Yc, r);
                
                % Calculate activity concentration in ROI
                [tempData(:,:,centralSliceMinusOneCM,:), explainedFraction, fullEigenValues]=imlook4d('generateImage',imlook4d_current_handles, centralSliceMinusOneCM, 1);
                numberOfFrames=size(tempData,4);
                indecesToROI=find(imlook4d_ROI(:,:,centralSliceMinusOneCM)==i);
                tempData2=tempData(:,:,centralSliceMinusOneCM);
                roiPixelValues=tempData2(indecesToROI);
                activity(i,2)=mean( reshape(roiPixelValues,[],numberOfFrames),1 ); % Mean value of each column
            
                ROIout.bg(k*5-3,i+2)=activity(i,2);
                
                Xc=round( absoluteCoordinate(X1,X2,ROI_coordinates(i,1)) );
                Yc=round( absoluteCoordinate(Y1,Y2,ROI_coordinates(i,2)) );
                imlook4d_ROI(:,:,centralSlice)=circleROI(imlook4d_ROI(:,:,centralSlice), i, Xc, Yc, r);
                
                % Calculate activity concentration in ROI
                [tempData(:,:,centralSlice,:), explainedFraction, fullEigenValues]=imlook4d('generateImage',imlook4d_current_handles, centralSlice, 1);
                numberOfFrames=size(tempData,4);
                indecesToROI=find(imlook4d_ROI(:,:,centralSlice)==i);
                tempData2=tempData(:,:,centralSlice);
                roiPixelValues=tempData2(indecesToROI);
                activity(i,3)=mean( reshape(roiPixelValues,[],numberOfFrames),1 ); % Mean value of each column
            
                ROIout.bg(k*5-2,i+2)=activity(i,3);
                
                Xc=round( absoluteCoordinate(X1_plus1cm,X2_plus1cm,ROI_coordinates(i,1)) );
                Yc=round( absoluteCoordinate(Y1_plus1cm,Y2_plus1cm,ROI_coordinates(i,2)) );
                imlook4d_ROI(:,:,centralSlicePlusOneCM)=circleROI(imlook4d_ROI(:,:,centralSlicePlusOneCM), i, Xc, Yc, r);
                
                % Calculate activity concentration in ROI
                [tempData(:,:,centralSlicePlusOneCM,:), explainedFraction, fullEigenValues]=imlook4d('generateImage',imlook4d_current_handles, centralSlicePlusOneCM, 1);
                numberOfFrames=size(tempData,4);
                indecesToROI=find(imlook4d_ROI(:,:,centralSlicePlusOneCM)==i);
                tempData2=tempData(:,:,centralSlicePlusOneCM);
                roiPixelValues=tempData2(indecesToROI);
                activity(i,4)=mean( reshape(roiPixelValues,[],numberOfFrames),1 ); % Mean value of each column
            
                ROIout.bg(k*5-1,i+2)=activity(i,4);
                
                Xc=round( absoluteCoordinate(X1_plus2cm,X2_plus2cm,ROI_coordinates(i,1)) );
                Yc=round( absoluteCoordinate(Y1_plus2cm,Y2_plus2cm,ROI_coordinates(i,2)) );
                imlook4d_ROI(:,:,centralSlicePlusTwoCM)=circleROI(imlook4d_ROI(:,:,centralSlicePlusTwoCM), i, Xc, Yc, r);
                
                % Calculate activity concentration in ROI
                [tempData(:,:,centralSlicePlusTwoCM,:), explainedFraction, fullEigenValues]=imlook4d('generateImage',imlook4d_current_handles, centralSlicePlusTwoCM, 1);
                numberOfFrames=size(tempData,4);
                indecesToROI=find(imlook4d_ROI(:,:,centralSlicePlusTwoCM)==i);
                tempData2=tempData(:,:,centralSlicePlusTwoCM);
                roiPixelValues=tempData2(indecesToROI);
                activity(i,5)=mean( reshape(roiPixelValues,[],numberOfFrames),1 ); % Mean value of each column
                
                ROIout.bg(k*5,i+2)=activity(i,5);
                
            end
        end
        ROIout.bg_headings(1,:)={'Size [mm]' 'Position [cm]' 'ROI 1' 'ROI 2' 'ROI 3' 'ROI 4' 'ROI 5' 'ROI 6' 'ROI 7' 'ROI 8' 'ROI 9' 'ROI 10' 'ROI 11' 'ROI 12'};
        
        imlook4d_ROINames{i+1}=addROI;  % Restore name for "add ROI" command
        
    % Ask if user has imaging toolbox. (If yes then find circles)
    tool=questdlg('Do you have the imaging toolbox?',...
        'Imaging toolbox?',...
        'Yes','No','Yes');
    
    switch tool
        case 'Yes'
            % Create output variable
            ROIout.Spheres(1,1:6)=[d(1:5) d(7)];
            % Find centres of hot spheres
            [cent, radii]=imfindcircles(imlook4d_Cdata(:,:,centralSlice,imlook4d_frame),[5 30]);
            tmpSize = size(cent);
            if tmpSize < 4
                msgbox({'Could not find all hot spheres.';'Possibly the resolution is to low.';'';'The ROIs of the hot and cold spheres will have to be placed manually'});
            else
                centres(1,:)=cent(4,:); centres(2,:)=cent(3,:); centres(3,:)=cent(2,:); centres(4,:)=cent(1,:);
                if ((cent(4,1)-cent(3,1))^2+(cent(4,2)-cent(3,2))^2)>((cent(4,1)-cent(2,1))^2+(cent(4,2)-cent(2,2))^2)
                    centres(2,:)=cent(2,:); centres(3,:)=cent(3,:);
                end
            
                % Define the central point in the "lung" (also centrum of the
                % circle in which the spheres are placed
                centralPoint(1,1)=(max(cent(4,1),cent(1,1))-min(cent(4,1),cent(1,1)))/2+min(cent(4,1),cent(1,1));
                centralPoint(1,2)=(max(cent(4,2),cent(1,2))-min(cent(4,2),cent(1,2)))/2+min(cent(4,2),cent(1,2));
            
                % Calculate position of cold spheres
                centres(5,1)=centralPoint(1,1)-(centres(2,1)-centralPoint(1,1));
                centres(5,2)=centralPoint(1,2)-(centres(2,2)-centralPoint(1,2));
                centres(6,1)=centralPoint(1,1)-(centres(3,1)-centralPoint(1,1));
                centres(6,2)=centralPoint(1,2)-(centres(3,2)-centralPoint(1,2));
            
                % Place ROIs
                imlook4d_ROINames{13}=['ROI 13'];
                Xc=round(centres(1,2));
                Yc=round(centres(1,1));
                imlook4d_ROI(:,:,centralSlice)=circleROI(imlook4d_ROI(:,:,centralSlice), 13, Xc, Yc, radie(1));
        
                    % Calculate activity concentration in ROI
                    [tempData(:,:,centralSlice,:), explainedFraction, fullEigenValues]=imlook4d('generateImage',imlook4d_current_handles, centralSlice, 1);
                    numberOfFrames=size(tempData,4);
                    indecesToROI=find(imlook4d_ROI(:,:,centralSlice)==13);
                    tempData2=tempData(:,:,centralSlice);
                    roiPixelValues=tempData2(indecesToROI);
                    ROIout.Spheres(2,1)=mean( reshape(roiPixelValues,[],numberOfFrames),1 ); % Mean value of each column
                
                    Xc=round(centres(2,2));
                    Yc=round(centres(2,1));
                imlook4d_ROINames{14}=['ROI 14'];
                imlook4d_ROI(:,:,centralSlice)=circleROI(imlook4d_ROI(:,:,centralSlice), 14, Xc, Yc, radie(2));
        
                    % Calculate activity concentration in ROI
                    [tempData(:,:,centralSlice,:), explainedFraction, fullEigenValues]=imlook4d('generateImage',imlook4d_current_handles, centralSlice, 1);
                    numberOfFrames=size(tempData,4);
                    indecesToROI=find(imlook4d_ROI(:,:,centralSlice)==14);
                    tempData2=tempData(:,:,centralSlice);
                    roiPixelValues=tempData2(indecesToROI);
                    ROIout.Spheres(2,2)=mean( reshape(roiPixelValues,[],numberOfFrames),1 ); % Mean value of each column
                
                Xc=round(centres(3,2));
                Yc=round(centres(3,1));
                imlook4d_ROINames{15}=['ROI 15'];
                imlook4d_ROI(:,:,centralSlice)=circleROI(imlook4d_ROI(:,:,centralSlice), 15, Xc, Yc, radie(3));
        
                    % Calculate activity concentration in ROI
                    [tempData(:,:,centralSlice,:), explainedFraction, fullEigenValues]=imlook4d('generateImage',imlook4d_current_handles, centralSlice, 1);
                    numberOfFrames=size(tempData,4);
                    indecesToROI=find(imlook4d_ROI(:,:,centralSlice)==15);
                    tempData2=tempData(:,:,centralSlice);
                    roiPixelValues=tempData2(indecesToROI);
                    ROIout.Spheres(2,3)=mean( reshape(roiPixelValues,[],numberOfFrames),1 ); % Mean value of each column
            
                Xc=round(centres(4,2));
                Yc=round(centres(4,1));
                imlook4d_ROINames{16}=['ROI 16'];
                imlook4d_ROI(:,:,centralSlice)=circleROI(imlook4d_ROI(:,:,centralSlice), 16, Xc, Yc, radie(4));
            
                    % Calculate activity concentration in ROI
                    [tempData(:,:,centralSlice,:), explainedFraction, fullEigenValues]=imlook4d('generateImage',imlook4d_current_handles, centralSlice, 1);
                    numberOfFrames=size(tempData,4);
                    indecesToROI=find(imlook4d_ROI(:,:,centralSlice)==16);
                    tempData2=tempData(:,:,centralSlice);
                    roiPixelValues=tempData2(indecesToROI);
                    ROIout.Spheres(2,4)=mean( reshape(roiPixelValues,[],numberOfFrames),1 ); % Mean value of each column
        
                    Xc=round(centres(5,2));
                    Yc=round(centres(5,1));
                    imlook4d_ROINames{17}=['ROI 17'];
                    imlook4d_ROI(:,:,centralSlice)=circleROI(imlook4d_ROI(:,:,centralSlice), 17, Xc, Yc, radie(5));
            
                        % Calculate activity concentration in ROI
                        [tempData(:,:,centralSlice,:), explainedFraction, fullEigenValues]=imlook4d('generateImage',imlook4d_current_handles, centralSlice, 1);
                        numberOfFrames=size(tempData,4);
                        indecesToROI=find(imlook4d_ROI(:,:,centralSlice)==17);
                        tempData2=tempData(:,:,centralSlice);
                        roiPixelValues=tempData2(indecesToROI);
                        ROIout.Spheres(2,5)=mean( reshape(roiPixelValues,[],numberOfFrames),1 ); % Mean value of each column
        
                    Xc=round(centres(6,2));
                    Yc=round(centres(6,1));
                    imlook4d_ROINames{18}=['ROI 18'];
                    imlook4d_ROI(:,:,centralSlice)=circleROI(imlook4d_ROI(:,:,centralSlice), 18, Xc, Yc, radie(7));
            
                        % Calculate activity concentration in ROI
                        [tempData(:,:,centralSlice,:), explainedFraction, fullEigenValues]=imlook4d('generateImage',imlook4d_current_handles, centralSlice, 1);
                        numberOfFrames=size(tempData,4);
                        indecesToROI=find(imlook4d_ROI(:,:,centralSlice)==18);
                        tempData2=tempData(:,:,centralSlice);
                        roiPixelValues=tempData2(indecesToROI);
                        ROIout.Spheres(2,6)=mean( reshape(roiPixelValues,[],numberOfFrames),1 ); % Mean value of each column
        
                    ROIout.Spheres_headings(:,1)={'Size [mm]' 'Sphere activity'};
            
                    % Place ROI in "lung" in all slices and put data in ROIout.Lung
                    ROIout.Lung_headings(1,:)={'Slice number' 'ROI value'};
                    slices=size(imlook4d_Cdata,3);
                    ROIout.Lung=zeros(slices,2);
            
                    for i=1:slices;
                        Xc=round(centralPoint(1,2));
                        Yc=round(centralPoint(1,1));
                        imlook4d_ROINames{19}=['ROI 19'];
                        imlook4d_ROI(:,:,i)=circleROI(imlook4d_ROI(:,:,i), 19, Xc, Yc, radie(6));
                
                        % Calculate activity concentration in ROI
                        [tempData(:,:,i,:), explainedFraction, fullEigenValues]=imlook4d('generateImage',imlook4d_current_handles, i, 1);
                        numberOfFrames=size(tempData,4);
                        indecesToROI=find(imlook4d_ROI(:,:,i)==19);
                        tempData2=tempData(:,:,i);
                        roiPixelValues=tempData2(indecesToROI);
                        ROIout.Lung(i,2)=mean( reshape(roiPixelValues,[],numberOfFrames),1 ); % Mean value of each column
                        ROIout.Lung(i,1)=i;
                    end
            end
        case 'No'
            msgbox('The ROIs of the hot and cold spheres will have to be placed manually');
    end
    
%     ROIout.bg_table = table(ROIout.bg(:,1),ROIout.bg(:,2),ROIout.bg(:,3),ROIout.bg(:,4),...
%         ROIout.bg(:,5),ROIout.bg(:,6),ROIout.bg(:,7),ROIout.bg(:,8),ROIout.bg(:,9),...
%         ROIout.bg(:,10),ROIout.bg(:,11),ROIout.bg(:,12),ROIout.bg(:,13),ROIout.bg(:,14),...
%         'VariableNames',{'Size_mm' 'Postion_cm' 'ROI1' 'ROI2' 'ROI3' 'ROI4' 'ROI5' 'ROI6' 'ROI7' 'ROI8' 'ROI9' 'ROI10' 'ROI11' 'ROI12'});
    
    
%   
% FINALIZE
%

    % Import into imlook4d from Workspace
    imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles); % Import from workspace to current imlook4d instance
    
    
    
    % Clear 
    clear MaxThresholdLevel MinThresholdLevel ROI_coordinates TAB X1 X1_minus1cm X1_minus2cm X1_plus1cm X1_plus2cm X2 X2_minus1cm X2_minus2cm X2_plus1cm X2_plus2cm Xc Y1 Y1_minus1cm Y1_minus2cm Y1_plus1cm Y1_plus2cm Y2 Y2_minus1cm Y2_minus2cm Y2_plus1cm Y2_plus2cm Yc
    clear activeROI activity addROI answer cent centralPoint centralSlice centralSliceMinusOneCM centralSliceMinusTwoCM centralSlicePlusOneCM centralSlicePlusTwoCM centres d dX dY dZ defaultanswer deltaSlice explainedFraction fullEigenValues i
    clear imlook4d_Cdata imlook4d_ROI imlook4d_ROINames imlook4d_ROI_number imlook4d_duration imlook4d_frame imlook4d_slice imlook4d_time imlook4d_variables_before_script indecesToROI k midPoint newROI numberOfFrames numlines prompt r radie radii roiPixelValues
    clear temp tempData tempData2 title tool slices