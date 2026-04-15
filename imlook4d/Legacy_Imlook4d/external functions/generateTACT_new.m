function [activity, NPixels, stdev]=generateTACT_new(handles,ROI3D)
%function [activity, NPixels]=generateTACT(handles,image4D,ROI3D)
    %
    % This function generates a TACT curve.
    %
    % The function uses the following internal imlook4d functions:
    % generateImage (which uses GUI data from imlook4d internally)
    %
    % inputs:
    %     handles       - used to read model (to generate image correctly if a model exists)
    %     image4D       - matrix  [x,y,slice,frame]
    %     ROI3D         - ROI matrix [x,y,slice]
    %
    % outputs:
    %    activity       - activity in ROI [roi, frame]
    %    NPixels        - number of pixels in roi [roi]
    %    stdev          - standard deviation of pixels in ROI [roi, frame]
    %
    disp('Entered generateTACT_new');
            % image4D = handles.image.Cdata
            numberOfSlices=size(handles.image.Cdata,3);
            numberOfFrames=size(handles.image.Cdata,4);
            numberOfROIs=max(ROI3D(:));   
            tempData=zeros(size(handles.image.Cdata),'single');
            
            % Determine what slices contain a ROI
            slicesWithRoi=sum(sum(ROI3D));      % zero if no roi in slice => no values for TACT
            slicesWithRoi=slicesWithRoi(:);     % row index is slice number.
            indecesWithRoi=find(slicesWithRoi>0);


            % Calculate TACT for each ROI
             for i=1:numberOfROIs
                 roiPixelValues=[];          % New ROI, start with empty pixel values

                % Find pixel values for i:th ROI, by looping slices within ROI   

                    for j=1:length(indecesWithRoi)  % Loop slices
                        
                        % Generate image for current slice 
                        % (example output: tempData [128,128,1,39] )
                        [tempData, explainedFraction, fullEigenValues]=imlook4d('generateImage',handles, indecesWithRoi(j), 1:numberOfFrames);
                        ROI2D=ROI3D(:,:,indecesWithRoi(j));
                        offset=size(ROI2D(:),1 );    % offset to next frame (number of pixels in slice)
                        
                        % Get all indeces
                        indecesToROI=find(ROI2D==i); % from ROI definition

                        % Calculate pixelValues for each frame (in current slice)
                        roiPixelValuesCurrentSlice=[];
                        for k=1:numberOfFrames
                            roiPixelValuesCurrentSlice=[roiPixelValuesCurrentSlice tempData(indecesToROI+(k-1)*offset)];
                        end
                        
                        % Add rows for current slice, to pixel values for  whole ROI
                        roiPixelValues=[roiPixelValues; roiPixelValuesCurrentSlice];

                    end
                    
                % Calculate TACT for ROI i             
                            %roiPixelValues=tempData(allIndecesToROI);  % Using original data, column is frame, row is pixel in ROI
                            
                    % Set value to zero if ROI has no pixels
                    NPixels(i)=size(roiPixelValues,1);
                    if NPixels(i)==0
                         activity(i,:)=zeros(1,numberOfFrames);;
                         stdev(i,:)=zeros(1,numberOfFrames);
                    else
                        activity(i,:)=mean( reshape(roiPixelValues,[],numberOfFrames),1 ); % Mean value of each column
                        stdev(i,:)=std( reshape(roiPixelValues,[],numberOfFrames),1 ); % Standard deviation value of each column
                   end
                    
            end %for
            
  disp('DONE generateTACT_new');
