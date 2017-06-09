%TEST_Hotelling_on_ROIs.m

% Input dialog
    if ~exist('lastComponent')
        lastComponent=1;
    end
    answer=inputdlg({'Last PC component', 'Display non-ROI pixels'},'Set Hotelling filter strength',1,{num2str(lastComponent),'true'});
    lastComponent=str2num( answer{1} );
    displayAllPixels=answer{2};
    

    StartScript

% Read variables
    numberOfFrames=size(imlook4d_Cdata,4);
    numberOfRois=max(imlook4d_ROI(:));
    firstComponent=1;
    
    
    imlook4d_Cdata2=zeros(size(imlook4d_Cdata));
    
    

%
% Loop ROIs
%
    for i=1:numberOfRois
        disp(i);

        % Get indeces for pixels with ROI==roiNumber
        pixelVector=imlook4d_Cdata( imlook4d_ROI(:)==i);


        % Get ROI pixel indeces for all frames
        indecesToROI=find(imlook4d_ROI==i); 
        offset=size(imlook4d_ROI(:),1 ); 
        allIndecesToROI=zeros( length(indecesToROI), numberOfFrames);
        for j=1:numberOfFrames
            allIndecesToROI(:,j)=indecesToROI+(j-1)*offset;
        end

        % Get pixels in column vectors (on column per frame)
        originalDataVectors=imlook4d_Cdata(allIndecesToROI);            % Pixels in rois (column vectors)
        standardizedInputDataVectors=zeros(size(originalDataVectors));  % Standardized originalDataVectors
        standardizedFilteredDataVectors=zeros(size(originalDataVectors)); % Filtered standardizedInputDataVectors
        filteredDataVectors=zeros(size(originalDataVectors));           % Unstandardized standardizedFilteredDataVectors

        % Standardize pixel data
        %%standardizedDataVectors=originalDataVectors;
        sd=std(originalDataVectors);
        avg=mean(originalDataVectors);
        for j=1:numberOfFrames
            standardizedInputDataVectors(:,j)=(originalDataVectors(:,j)-avg(j))/sd(j);
        end

        % Hotelling filter on column data
         [sortedEigenValues, sortedEigenVectors, PCVectors]=columnPCA(standardizedInputDataVectors);
         disp('Done columnPCA');
         standardizedFilteredDataVectors=inverseColumnPCA(sortedEigenVectors(:,firstComponent:lastComponent), standardizedInputDataVectors);
         disp('Done inverseColumnPCA');

         % Undo standardization

          for j=1:numberOfFrames
            filteredDataVectors(:,j)=standardizedFilteredDataVectors(:,j)*sd(j) +avg(j);
          end   

         % Put filtered data into normal image
         imlook4d_Cdata( allIndecesToROI)=filteredDataVectors;
         imlook4d_Cdata2( allIndecesToROI)=filteredDataVectors;

    end
    
% Finalize
    if ~strcmp(displayAllPixels,'true')
        imlook4d_Cdata=imlook4d_Cdata2;
    end
    WindowTitle( [ '(roiPC=' num2str(firstComponent) '-' num2str(lastComponent) ')' ], 'prepend');
    EndScript
    clear answer
         