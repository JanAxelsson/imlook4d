function [activity, NPixels, stdev, maxActivity, roisToCalculate ]=generateTACT(handles,ROI3D, roisToCalculate)
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
    %     roisToCalculate - OPTIONAL; A ROI number or range.  If left out, all ROIs are calculated.  Examples: 2, 1:10
    %
    % outputs:
    %    activity       - activity conc in ROI [roi, frame]
    %    NPixels        - number of pixels in roi [roi]
    %    stdev            - standard deviation of pixels in ROI [roi, frame]
    %    maxActivity    - max activity in ROI
    %    roisToCalculate - report back one of: 
    %       a) input argument roisToCalculate from the input argument
    %       b) roi values that existed in ROI matrix
    %
    %disp('Entered generateTACT');
            % image4D = handles.image.Cdata
            numberOfSlices=size(handles.image.Cdata,3);
            numberOfFrames=size(handles.image.Cdata,4);
            
            try
                numberOfROIs=length( get(handles.ROINumberMenu,'String'))-1;
            catch
                roinumbers =  unique(ROI3D(:));
                roinumbers =  roinumbers( roinumbers ~= 0 ); % Exclude 0
                numberOfROIs = length(roinumbers);
            end
            
                        
            if nargin < 3
                roinumbers =  unique(ROI3D(:));
                roinumbers =  roinumbers( roinumbers ~= 0 ); % Exclude 0
                roisToCalculate = roinumbers;
            end
            
            
            tempData=zeros(size(handles.image.Cdata),'single');
            
            % Determine what slices contain a ROI
            slicesWithRoi=sum(sum(ROI3D));      % zero if no roi in slice => no values for TACT
            slicesWithRoi=slicesWithRoi(:);     % row index is slice number.
            indecesWithRoi=find(slicesWithRoi>0);

            
            % Determine mode of operation
                    IsNormalImage = get(handles.ImageRadioButton,'Value');
                    IsPCAFilter = not( (get(handles.PC_low_slider, 'Value')==1) &&  (get(handles.PC_high_slider, 'Value')==numberOfFrames) ); % PCA-filter selected with sliders
                    IsPCImage = get(handles.PCImageRadioButton,'Value');      % PC images radio button selected
                    
                    IsModel =  isa(handles.model.functionHandle, 'function_handle');
                   
                    IsDynamic = (numberOfFrames>1);

                        
            % Generate 4D image ONLY for slices with ROIs (zero for other slices)
            % This is to speed up calculations!


             % NEW Version
             
             % Fix that generateImage puts a single slice into a matrix of dimensions [:,:,1,:]
             % by putting generated image back into correct slice
             if ( IsNormalImage && ~IsModel && ~IsPCAFilter)
                 % Quick
                tempData = handles.image.Cdata;
             else
                 % Slow, if PCA-filter or model
                 if (size(indecesWithRoi(:))==1)
                     % Single slice, put into slice 1 by generateImage
                     [tempData(:,:,indecesWithRoi,:), explainedFraction, fullEigenValues]=imlook4d('generateImage',handles, indecesWithRoi, 1:numberOfFrames);
                     %[tempData, explainedFraction, fullEigenValues]=imlook4d('generateImage',handles, indecesWithRoi, 1:numberOfFrames);
                 else
                     % Multiple slices with ROI, correct dimensions of tempData
                     % matrix
                     [tempData, explainedFraction, fullEigenValues]=imlook4d('generateImage',handles, indecesWithRoi, 1:numberOfFrames);
                     
                     % Above was slow in imlook4d/generateImage -- this is faster for many ROIs
                     %tempData = handles.image.Cdata;
                     
                 end
              end

             numberOfFrames=size(tempData,4);
             

            % Calculate TACT for each ROI
             for i= 1:length(roisToCalculate)
                 roiValue = roisToCalculate(i);
                 %disp(i)
                    % Determine indeces to Cdata matrix for this ROI 
                    indecesToROI=find(ROI3D==roiValue);        % from ROI definition
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
            
            
