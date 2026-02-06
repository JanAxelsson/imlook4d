% quickInverseColumnPCA.m
%
% The inverse of Principal Component Analysis on column data.
%
% inputs:  sortedEigenvectors     weight factors used to create the different
%                                 principal components (PCs)
%                                 3D matrix [frame, PC, slice]    
%                                 
%
%           PCVectors             the principal component pixel values 
%                                 (components ordered in columns in order of
%                                 importance) 
%                                 2D matrix [pixelIndex, columnIndex]
%
%           firstComponent        first component to keep (numbering
%                                 starts on 1)
%
%           lastComponent         last component to keep (numbering
%                                 starts on 1)
%
%
% outputs: dataVectors            2D matrix [pixelIndex, columnIndex] of
%                                 filtered data
%
% This concept was originally developed for dynamic PET images.
%
% Jan Axelsson
%

    
function dataVectors=quickInverseColumnPCA(sortedEigenVectors, PCVectors, firstComponent, lastComponent)
    % In inverseColumnPCA the pca components are calculated as:
    % finalData= (featureVector'*originalColumnMatrix'  )';    
    %
    % This is an unneccessary matrix multiplication, when we can instead
    % remove the components directly from the PCVectors.

    % Remove components
    %featureVector=selectComponents(sortedEigenValues, firstComponent, lastComponent);  
    featureVector=sortedEigenVectors(:, firstComponent:lastComponent, :); 
    finalData=PCVectors(:, firstComponent:lastComponent);
    % Inverse PCA
    dataVectors=(featureVector*finalData')';               % Image domain data in vector form, but scaled as before
    %dataVectors=(finalData*featureVector');                %Equivalent way 
    
     % dataVectors=x'    in Gonzalez nomenclature
     % featureVector'=A  in Gonzalez nomenclature
     % finalData=y'      in Gonzalez nomenclature
     % =>
     % My in Gonzalez vocabulary:  x'=(A'*y)'  
     % =>  x=(A'*y)''=A'*y
     % Which is exactly what Gonzalez writes