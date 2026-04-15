function [C, P] = pve( TACT, ROIs, M, P)
%
% This function calculates a partial-volume-corrected image.
% Assumptions are:
% - neighboring regions can be treated as homogenous
% - scanner resolutions in x,y,z directions are.
%
% INPUT:
%   TACT    true ROI values [frame, roi].  1D if static scan.  2D if dynamic scan.
%   ROIs    3D matrix with ROI indeces
%   M       3D or 4D matrix
%   P       Recovery map, pixel by pixle.  Create by pveMap command
%
% OUTPUT:
%   C       PVE-corrected matrix
%   P       PVE map with ROI in 4th dimension
%
% Example:
%   % Export, and ROI_data_to_workspace from imlook4d.
%
%   % Get voxelsize in mm.  Can also be specified as vector vox = [ 2 2 2 ];
%   vox = voxel_size(imlook4d_current_handles);    
%   % Convert known resolution in mm fwhm=[ 3.59, 3.40, 4.32], to fwhm in pixels
%   fwhm_pixels = pixels( [ 3.59, 3.40, 4.32], vox); 
%   % Convert from fwhm to sigma
%   sigma_pixels = fwhm_pixels / 2.35;  
%   % Create pve-map
%   P = pveMap( imlook4d_ROI, sigma_pixels);
%   % Create pve-corrected image
%   C=pve( imlook4d_ROI_data.mean, imlook4d_ROI, imlook4d_Cdata, P); imlook4d(C);

    numberOfFrames = size(M,4); % Number of frames
    roiNumbers = unique(ROIs);  % List of available ROIs (starting with ROI 0, which is empty)
    roiNumbers = roiNumbers( roiNumbers>0)'; % Remove 0, and make it a row vector (for loop below)


%
% Subtract spill-in from all images
%
    
    C = zeros( size(M) );     % Corrected for all frames

    for n=1:numberOfFrames
        R = TACT(n,:);  % ROI values R(k) (within frame n)
        A = M(:,:,:,n); % Work on measured volume A (at frame n)
        B = zeros( size(ROIs) );  % Measured minus spill-in
        CC= zeros( size(ROIs) );  % Corrected per frame
        PP= zeros( size(ROIs) );  % Temporary storage: one smoothed ROI
        
        % Loop ROIs
        for j=roiNumbers  

            % Calculate spill in into ROI=j frame=n,  from all other ROIs
            spillIn = zeros( size(ROIs) );
            for k=roiNumbers  
                if ( k ~= j)
                    spillIn = spillIn + P(:,:,:,k) * R(k);
                end
            end
            
            indeces = find(ROIs==j);  % Pixel indeces to this ROI
            
            % Subtract spill-in from measured in ROI
            B(indeces) = A(indeces) - spillIn(indeces);
            
            % PVE-correct within this ROI
            PP = P(:,:,:,j);
            CC(indeces) = B(indeces) ./ PP(indeces);
        end
        C(:,:,:,n) = CC;  % Store each frame
    end
    
