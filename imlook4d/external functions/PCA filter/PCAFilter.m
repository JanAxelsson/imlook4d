% PCAFilter.m
%
% This filter performs principal component (pc) transform, zeros component
% outside defined range, and does an inverse pc transform.
%
% inputs:  Data                   Data 4D matrix 
%
%          firstComponent         first component to keep (numbering
%                                 starts on 1)
%
%          lastComponent          last component to keep (numbering
%                                 starts on 1)
%
%
% outputs: matrix                 4D matrix [x, y, z ,frames] of filtered data
%
% outputs (expert mode, optional)
%         explainedFraction       1D matrix [z]  giving fraction of
%                                 variance in data being explained by the
%                                 selected components.  1 means 100%.
%
%         fullEigenValues         2D matrix [PC, slice], 
%                                 one column per slice, slices 
%                                 sorted in descending order  
%                                 
%         fullEigenVectors        3D matrix [frame, PC, slice],
%                                 one 2D matrix per slice, 
%                                 weight factors used to create the
%                                 principal
%                                 component pixel-values from input frames  
%                                 (components ordered in columns in order of
%                                 importance) 
%
%         PCMatrix                4D matrix [x, y, z ,PC component]
%
%
% Example 1:
%    PCImages=PCAFilter( Data, 1, 4);
%
% Example 2:
%    [matrix, explainedFraction, fullEigenValues,fullEigenVectors,PCMatrix]=PCAFilter( Data, firstComponent, lastComponent);
%
% This concept was originally developed for dynamic PET images.
%
% Jan Axelsson
%
% 



function [Data, explainedFraction, fullEigenValues, fullEigenVectors, PCMatrix]=PCAFilter( Data, firstComponent, lastComponent)
%function [matrix, explainedFraction, fullEigenValues, fullEigenVectors, PCMatrix]=PCAFilter( Data, firstComponent, lastComponent)

% If you set this to 3, you may discard principal
%components 1-2.  If commented, principal components 1 to lastComponent is
%used
%firstComponent = 3  

%tic

%disp('PCA-filter');
    %
    %  Initialize
    %

        % Label x=1,y=1 with value 0 (so that we can subtract using
        % "subtract outside FOV" in imlook4d).  This is important only if
        % first components are removed (filter using for instance
        % components 2-4)
        %Data(1,1,:,:)=0;
    
    %
    % Filter
    %
        
        [averageMatrix, stdevMatrix, Data]=standardizeSlices(Data);                        % scale data prior to PCA
        [fullEigenValues, fullEigenVectors, PCMatrix]=fullPCA(Data);                        % perform fullPCA
        [Data, explainedFraction]= quickInverseFullPCA(fullEigenValues, fullEigenVectors, PCMatrix, firstComponent, lastComponent);  % perform inverseFullPCA
        %matrix=unStandardizeSlices(averageMatrix, stdevMatrix, scaledMatrix);                       % scale back data post inverse PCA
        Data=unStandardizeSlices(averageMatrix, stdevMatrix, Data);                       % scale back data post inverse PCA
        
        % Display filter times larger than 1 second (imlook4d single images
        % should not display)
        %stopTime=toc;
        %if(stopTime>1)
            %disp(['Time for filter=' num2str(toc)]);tic;
        %end
        
    %
    % Finish
    %
%         if ~QuietMode()     % If SETTINGS.QUIET==false, then display
% 
%             % Display Original Images
%             h=imlook4d(single(Data));set(h,'Name', ['Original "'  '"']);
% 
%             % Display Principal Components
%             h=imlook4d(single(PCMatrix));set(h,'Name', ['Principal Components "'  '"']);
% 
%             % Display Filtered images
%             h=imlook4d(single(matrix));set(h,'Name', ['Filtered "'  '" (PC=' num2str(firstComponent) '-' num2str(lastComponent) ')']);
% 
%             % Display Reminder images
%             h=imlook4d(single(Data)-single(matrix));set(h,'Name', ['Reminder "'  '" (PC=' num2str(firstComponent) '-' num2str(lastComponent) ')']);
%         end




