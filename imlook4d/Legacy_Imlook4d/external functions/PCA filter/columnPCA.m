% columnPCA.m
%
% Principal Component Analysis on column data.  
%
% inputs:  originalDataVectors    original data, 2D matrix [pixelIndex, frame index]
%
% outputs: sortedEigenValues      sorted in descending order  
%                                 (these values is the key for sorting
%                                 of eigenvectors and PCVectors)
%
%          sortedEigenVectors     weight factors used to create the principal
%                                 component pixel-values from input frames  
%                                 (components ordered in columns in order of
%                                 importance) 
%
%          PCVectors              the principal component pixel values 
%                                 (components ordered in columns in order of
%                                 importance) 
%                                 2D matrix [pixelIndex, PC index]
%
% This concept was originally developed for dynamic PET images.
%
% 081218  Added feature: pixels that are set to zero in all frames are omitted.
%
% Jan Axelsson
%

function [sortedEigenValues, sortedEigenVectors, PCVectors]=columnPCA(originalDataVectors)

     %COMMENTED 081218 C=cov(originalDataVectors); % Covariance matrix
     
     
     % Work only on nonzero pixels
     summedOverFrames=(sum(originalDataVectors,2));  
     indexToNonZeroPixels=nonzeros(summedOverFrames~=0);  % Pixels being zero for all frames
     indexToNonZeroPixels=find(summedOverFrames~=0);
     %disp(size(indexToNonZeroPixels));
     %%disp([ 'Number of nonzero pixels=' size(indexToNonZeroPixels,1)]);                  % Display number of pixels not zero
     newDataVectors=zeros( size(indexToNonZeroPixels,1), size(originalDataVectors,2));

     for i=1:size(originalDataVectors,2)
         newDataVectors(:,i)=originalDataVectors(indexToNonZeroPixels,i );
     end

%      
%      % TEST new distribution by adding mirrored distribution to original
%      N=size(indexToNonZeroPixels,1);
%      newDataVectors=zeros( 2*size(indexToNonZeroPixels,1), size(originalDataVectors,2));
%      for i=1:size(originalDataVectors,2)
%          newDataVectors(1:N,i)=originalDataVectors(indexToNonZeroPixels,i );
%          newDataVectors(N+1:end,i)=-originalDataVectors(indexToNonZeroPixels,i );
%      end  
%      %
     
     
     if length(newDataVectors)==0
         %Use original data vectors if all pixels were zero
         C=cov(originalDataVectors);
     else
         %Use non-zero pixels (newDataVectors)
         C=cov(newDataVectors);
     end
     
     
     % Calculate eigenvalues and unit eigenvectors from Covariance Matrix.
     [A,D]=eig(C);          % A is eigenvectors in columns, diagonal of D are eigenvalues
     d=diag(D);             % Put eigenvalues into vector d
     
     % Sort according to eigenvalues
     % by merging the column of eigenvalues to eigenvector placed in rows
     % (note transpose sign)
     dataToSort=[ d A'];
     
     % Sort ascending, according to data in first column (where eigenvalues are)
     % ( This is referred to as components in my MathCad code )
     temp=flipud( sortrows(dataToSort));          
     
     sortedEigenValues=temp(:,1);        % Get sorted eigenvalues from sorted merged matrix
     sortedEigenVectors=temp(:,2:end)';  % Get eigenvectors as column vectors (removing vector containing eigenvalues)
     
     PCVectors= (sortedEigenVectors'*originalDataVectors'  )';       % All principal components are used
     
     % originalDataVectors=x' in Gonzalez nomenclature
     % sortedEigenVectors=A'  in Gonzalez nomenclature
     % PCVectors=y'           in Gonzalez nomenclature
     % =>
     % My in Gonzalez vocabulary:  y'=(A*x)'  
     % =>  y=(A*x)''=A*x
     % Which is exactly what Gonzalez writes
     %
     % However, to extend this fully to my vocabulary,
     % all column vectors x are put together in a matrix X,
     % where X=[ x1 x2 ... xn].  s
