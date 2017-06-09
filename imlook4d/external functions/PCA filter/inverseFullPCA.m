% inverseFullPCA.m
%
% The inverse of Principal Component Analysis on column data.
%
% inputs:  sortedEigenValues      2D matrix, one column per slice, slices 
%                                 sorted in descending order  
%                                 (these values is the key for sorting
%                                 of eigenvectors and PCVectors)
%                                 [frame, slice]     
%
%          eigenvectors           weight factors used to create the different
%                                 principal components (PCs)
%                                 3D matrix [frame, PC, slice]
%
%          originalData           4D matrix [x, y, z , frame]
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
%          explainedFraction      1D matrix [z]  of filtered data
%
% This concept was originally developed for dynamic PET images.
%
% Jan Axelsson
%

    
function [matrix, explainedFraction]=inverseFullPCA(sortedEigenValues, eigenvectors, originalData, firstComponent, lastComponent)




%function [sortedEigenValues, sortedEigenVectors, PCMatrix]=fullPCA(matrix)
    %
    % Initialize
    %

        %Define constants
        IMAGESIDEx=size(originalData,1);
        IMAGESIDEy=size(originalData,2);
        numberOfPixels=IMAGESIDEx*IMAGESIDEy;
        numberOfSlices=size(originalData,3);
        numberOfFrames=size(originalData,4);


        % Allocate memory for matrices
        %sortedEigenValues=zeros(numberOfPCs, numberOfSlices);                      % Stores eigenvalues for each slice
        %sortedEigenVectors=zeros(numberOfPCs, numberOfPCs, numberOfSlices);     % Stores eigenvectors for each slice   
        %JANdataVectors=zeros(numberOfPixels, numberOfPCs,numberOfSlices );              % Stores inage vectors for each slice
        dataVectors=zeros(numberOfPixels,numberOfSlices, numberOfFrames );              % Stores inage vectors for each slice

        originalDataVectors=zeros(numberOfPixels, numberOfFrames);                                % Data from a single slice 
        explainedFraction=zeros(numberOfSlices,1);
    
    %
    % inverse PCA on feature vector
    %

       %JAN featureVector=selectComponents(eigenvectors, firstComponent, lastComponent);    % Remove components we don't want to use

        % inverse PCA for each slice
        for i=1:numberOfSlices
             % Reshape PC image to columns
             temp=originalData(:,:,i,:);  % [128,128,1,17]
             originalDataVectors=reshape(temp, numberOfPixels,numberOfFrames);    % principal components one in each column



             % inverse PCA on single slice
            %JANdataVectors(:,i,:)=quickInverseColumnPCA(featureVector(:,:, i), PCVectors, firstComponent, lastComponent);
             dataVectors(:,i,:)=inverseColumnPCA(eigenvectors(:,firstComponent:lastComponent, i), originalDataVectors);

             % calculate explained fraction 
             % Calculate explanation factors for PC component
             explainedFraction(i)=sum( sortedEigenValues(firstComponent:lastComponent,i) )/sum(sortedEigenValues(:, i));

        end

        % Reshape to images (more efficient to do this here, outside loop)
        matrix=reshape(dataVectors, IMAGESIDEx, IMAGESIDEy, numberOfSlices, numberOfFrames);

  
     