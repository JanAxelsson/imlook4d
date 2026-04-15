% inverseColumnPCA.m
%
% The inverse of Principal Component Analysis on column data.
%
% inputs:  featureVector          weight factors used to create the different
%                                 principal components (same as eigenvectors
%                                 if we do not manipulate eigenvectors from
%                                 columnPCA).  Typically the feature vector
%                                 consists of a selection of the pricipal
%                                 components that we want to keep.  This
%                                 function applied to a selection of the
%                                 eigenvectors acts as a filter.
%                                 
%
%          originalDataVectors    original data, 2D matrix [pixelIndex, frameIndex]
%
% outputs: dataVectors            2D matrix [pixelIndex, frameIndex] of
%                                 filtered data
%
% This concept was originally developed for dynamic PET images.
%
% Jan Axelsson
%

    
function dataVectors=inverseColumnPCA(featureVector, originalDataVectors)
    
    finalData= (featureVector'*originalDataVectors'  )';   % Prinicipal component data 
    dataVectors=(featureVector*finalData')';               % Image domain data in vector form, but scaled as before