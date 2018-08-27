function [activity, NPixels, stdev, maxActivity]=generateTACT(handles,ROI3D)
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
    %    activity       - activity conc in ROI [roi, frame]
    %    NPixels        - number of pixels in roi [roi]
    %    stdev            - standard deviation of pixels in ROI [roi, frame]
    %    maxActivity    - max activity in ROI
    %
    %disp('Entered generateTACT');
            % image4D = handles.image.Cdata
            numberOfSlices=size(handles.image.Cdata,3);
            numberOfFrames=size(handles.image.Cdata,4);
            %numberOfROIs=max(ROI3D(:));
            numberOfROIs=length( get(handles.ROINumberMenu,'String'))-1;
            tempData=zeros(size(handles.image.Cdata),'single');
            
            % Determine what slices contain a ROI
            slicesWithRoi=sum(sum(ROI3D));      % zero if no roi in slice => no values for TACT
            slicesWithRoi=slicesWithRoi(:);     % row index is slice number.
            indecesWithRoi=find(slicesWithRoi>0);
            
            % Generate 4D image ONLY for slices with ROIs (zero for other slices)
            % This is to speed up calculations!

             
             % Generate 4D image only for slices containing ROI
             %[tempData(:,:,indecesWithRoi,1:numberOfFrames), explainedFraction, fullEigenValues]=imlook4d('generateImage',handles, indecesWithRoi, 1:numberOfFrames); 
             %[tempData, explainedFraction, fullEigenValues]=imlook4d('generateImage',handles, indecesWithRoi, 1:numberOfFrames);
             
             % Fix that generateImage puts a single slice into a matrix of dimensions [:,:,1,:]
             % by putting generated image back into correct slice
             if (size(indecesWithRoi(:))==1)
                 % Single slice, put into slice 1 by generateImage
                 [tempData(:,:,indecesWithRoi,:), explainedFraction, fullEigenValues]=imlook4d('generateImage',handles, indecesWithRoi, 1:numberOfFrames);
             else
                 % Multiple slices with ROI, correct dimensions of tempData
                 % matrix
                %[tempData, explainedFraction, fullEigenValues]=imlook4d('generateImage',handles, indecesWithRoi, 1:numberOfFrames);
                
                % Above was slow in imlook4d/generateImage -- this is faster for many ROIs
                tempData = handles.image.Cdata;
             end
             numberOfFrames=size(tempData,4);



            % Calculate TACT for each ROI
             for i=1:numberOfROIs
                 %disp(i)
                    % Determine indeces to Cdata matrix for this ROI 
                    indecesToROI=find(ROI3D==i);        % from ROI definition
                    NPixels(i)=size(indecesToROI,1);    % Number of pixels in ROI i
                    offset=size(ROI3D(:),1 );           % offset to next frame (number of pixels in volume)
                    allIndecesToROI=zeros(size(indecesToROI,1),numberOfFrames); % place for indeces in all frames
                    
                    % Get all indeces
                    for j=1:numberOfFrames
                        allIndecesToROI(:,j)=indecesToROI+(j-1)*offset;
                    end

                % Calculate TACT
                    roiPixelValues=tempData(allIndecesToROI);  % Using original data, column is frame, row is pixel in ROI
                    
                    % Set value to zero if ROI has no pixels
                    if NPixels(i)==0
                        activity(i,:)=0;
                        stdev(i,:)=0;
                        maxActivity(i,:)=0;
                    else
                        activity(i,:)=mean( reshape(roiPixelValues,[],numberOfFrames),1 ); % Mean value of each column
                        stdev(i,:)=std( reshape(roiPixelValues,[],numberOfFrames),1 ); % Standard deviation value of each column
                        maxActivity(i,:)=max( reshape(roiPixelValues,[],numberOfFrames),[],1 ); % Max pixelvalue
                    end

            end %for
            
            
