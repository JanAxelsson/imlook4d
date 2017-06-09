function trueTACT = gtm( measTACT, ROIs, P)
%
% This function calculate true uptake values using the geometric transfer
% matrix (GTM) method, by Rousset (1998). 
% 
%
% INPUT:
%   measTACT measured ROI values [frame, roi].  1D if static scan.  2D if dynamic scan.
%   ROIs    3D matrix with ROI indeces
%   P       Recovery map, pixel by pixle.  Create by pveMap command
%
% OUTPUT:
%   trueTACT   PVE-corrected true TACT values
%
% Example:
%   % Export, and ROI_data_to_workspace from imlook4d.
%   %
%   % Get voxelsize in mm.  Can also be specified as vector vox = [ 2 2 2 ];
%   vox = voxel_size(imlook4d_current_handles)
%   %Convert known resolution in mm fwhm=[ 3.59, 3.40, 4.32], to fwhm in pixels
%   fwhm_pixels = pixels( [ 3.59, 3.40, 4.32], vox);
%   % Convert from fwhm to sigma
%   sigma_pixels = fwhm_pixels / 2.35; 
%   % Create pve-map
%   P = pveMap( imlook4d_ROI, sigma_pixels);  
%   % Get pve-corrected ROI values
%   TACT = gtm( imlook4d_ROI_data.mean, imlook4d_ROI, P);  

    numberOfFrames = size(measTACT,1); % Number of frames
    roiNumbers = unique(ROIs);  % List of available ROIs (starting with ROI 0, which is empty)
    roiNumbers = roiNumbers( roiNumbers>0)'; % Remove 0, and make it a row vector (for loop below)
    numberOfROIs = length(roiNumbers);
    
    trueTACT = zeros(size(measTACT));

    
% The idea is to calculate cross talk factors W
% so that the measured value B can be described as
% an equation with true values A and cross talks W.  Thus
% B = WA can be solved for A, giving the true values
% A = inv(W) x B   ,using the inverse of W.

% MATHEMATICAL THEORY:
%
% B(1) = W(1,1)A(1) + W(1,2)A(2) + .... + W(1,N)A(N)
% ...
% B(i) = W(i,1)A(1) + W(i,2)A(2) + .... + W(i,N)A(N)
% ...
% B(N) = W(N,1)A(1) + N,2)A(2) + .... + W(N,N)A(N)
%
% These equations can be written in matrix form W A = B
% where
%    | A(1) |     | W(1,1) ...   W(1,N)   |      | B(1) |
% A= | ...  |   W=| ...           ...     |   B= | ...  |
%    | A(N) |     | W(N,1) ...   W(N,N)   |      | B(N) |
% which is solved for A by 
% inv(W)*W*A = inv(W)*B => A = inv(W)*B
% by using the left matrix divide (\)
% which is roughly the same as multiplying by inverse matrix from left.
% Thus A = W\B

%
% Solve for each frame (reduce problem to 3D)
%

    for n=1:numberOfFrames
        
        % Cross-talk factors
        W = zeros(numberOfROIs); % Square matrix
        B = measTACT(n,:);   % Measured ROI values A(k) (within frame n)
        B=B'; % B should be vertical vector
        
        % Loop static ROI
        for i=roiNumbers
    
            % Find signal from each ROI that goes into static ROI
            for j=roiNumbers
                PP = P(:,:,:,j); % 3D pve map of this ROI
                indeces = find(ROIs==i);        % Pixel indeces to static ROI
                W(i,j) = mean( PP(indeces) );   % Cross talk (from ROI j to ROI i)
            end
            
        end
        
        % Solve for A
        A = W\B;

        trueTACT(n,:)=A;
    end

