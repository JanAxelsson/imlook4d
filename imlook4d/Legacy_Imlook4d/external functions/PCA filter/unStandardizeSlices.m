% unStandardizeSlices.m
%
% Return standardized variables to unscaled variables
%
% inputs: averageMatrix          2D matrix [slice, frame]
%
%          stdevMatrix            2D matrix [slice, frame]
%
%          matrix                 4D matrix [x, y, z ,frames], standardized data
%
%
% outputs: matrix                 4D matrix [x, y, z ,frames], standardization inversed 
%
% This concept was originally developed for dynamic PET images.
%
% Jan Axelsson
%

function matrix=unStandardizeSlices(averageMatrix, stdevMatrix, matrix)
    %
    % Initialize
    %
    
    %Define constants
    numberOfSlices=size(matrix,3);
    numberOfFrames=size(matrix,4);
     
    % Allocate memory
    %unScaledMatrix=zeros(size(scaledMatrix));
    
    %
    % un-Scale data
    %

    for j=1:numberOfFrames    
         for i=1:numberOfSlices  

           matrix(:,:,i,j)=matrix(:,:, i,j)*stdevMatrix(i,j) +averageMatrix(i,j);

        end % LOOP slices i
   end % LOOP frames j
    
    