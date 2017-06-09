% fullPCA.m
%
% Principal Component Analysis on all individual slices.  
%
% inputs:  matrix                 4D matrix [x, y, z ,frames]
%
% outputs: sortedEigenValues      2D matrix, one column per slice, slices 
%                                 sorted in descending order  
%                                 (these values is the key for sorting
%                                 of eigenvectors and PCVectors)
%                                 [PC, slice]
%
%          sortedEigenVectors     3D matrix [frame, PC, slice],
%                                 one 2D matrix per slice, 
%                                 weight factors used to create the principal
%                                 component pixel-values from input frames  
%                                 (components ordered in columns in order of
%                                 importance) 
%
%          PCMatrix               4D matrix [x, y, z , PC]
%                                 the principal component pixel images 
%                                 
%
% This concept was originally developed for dynamic PET images.
%
% Jan Axelsson
%

function [sortedEigenValues, sortedEigenVectors, PCMatrix]=fullPCA(matrix)
    %
    % Initialize
    %
    
    %Define constants
    IMAGESIDEx=size(matrix,1);
    IMAGESIDEy=size(matrix,2);
    numberOfPixels=IMAGESIDEx*IMAGESIDEy;
    numberOfSlices=size(matrix,3);
    numberOfFrames=size(matrix,4);
    numberOfPCs=numberOfFrames;
    
    
    % Allocate memory for matrices
    sortedEigenValues=zeros(numberOfPCs, numberOfSlices);                      % Stores eigenvalues for each slice
    sortedEigenVectors=zeros(numberOfFrames, numberOfPCs, numberOfSlices);     % Stores eigenvectors for each slice   
    PCVectors=zeros(numberOfPixels,numberOfSlices , numberOfPCs, 'single');              % Stores PC vectors for each slice [pixel, PC, z]
    
    data=zeros(numberOfPixels, numberOfFrames);                                % Data from a single slice 

    %PCMatrix=zeros(size(matrix));
    PCMatrix=zeros(size(matrix),'single');      %JAN 080125
    
    %
    % PCA on images
    %
    
    % Do PCA for each slice
    for i=1:numberOfSlices
         % Reshape image to columns
         temp=matrix(:,:,i,:);  % [128,128,1,17]
         data=reshape(temp, numberOfPixels, numberOfFrames);    % [16384,17]
         
         % PCA on single slice (with data in columns in first dimension)
         % [PC, slice], [frames, PC, slice], [pixels, slice, PC]=columnPCA( [frames, PC] )
         [sortedEigenValues(:,i), sortedEigenVectors(:,:,i), PCVectors(:,i,:)]=columnPCA(data); 
          %[sortedEigenValues(:,i), sortedEigenVectors(:,:,i),PCVectors(:,:,i)]=columnPCA(data); 
          
         %PCMatrix(:,:,i,:)=reshape(PCVectors, IMAGESIDEx, IMAGESIDEy, 1, numberOfPCs);
    end

    % Reshape to PC images (more efficient to do this here, outside loop)
    PCMatrix=reshape(PCVectors, IMAGESIDEx, IMAGESIDEy, numberOfSlices, numberOfPCs);
    
  
     