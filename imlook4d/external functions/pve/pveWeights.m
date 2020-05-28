function W = pveWeights( ROIs, PSF)
%
% This function calculates  partial-volume weights for cross talk between all ROIs
% using Geometric Transfer Matrix (GTM) method 
% (Rousset OG, Ma Y, Evans AC, J Nucl Med. 1998 May;39(5):904-11).
% Assumptions are:
% - neighboring regions can be treated as homogenous
% - scanner resolutions in x,y,z directions are.
%
% INPUT:
%   ROIs    3D matrix with ROI indeces
%   PSF     [sigmaX, sigmaY, sigmaZ] in pixels.  
%           Convert from FWHM: sigma = FWHM / 2.35
%           Convert from mm to pixels: divide by sigma(pixels) = sigma(mm) / pixelsize(mm)
%
% OUTPUT:
%   W       PVE weights between ROIs (2D matrix)
%
% Example:
%   % Export from imlook4d.
%   % Get voxelsize in mm.  Can also be specified as vector vox = [ 2 2 2 ];
%   vox = voxel_size(imlook4d_current_handles);  
%    % Convert known resolution in mm fwhm=[ 3.59, 3.40, 4.32], to fwhm in pixels
%   fwhm_pixels = pixels( [ 3.59, 3.40, 4.32], vox);  
%   % Convert from fwhm to sigma
%   sigma_pixels = fwhm_pixels / 2.35;  
%   % Create pve-weights
%   W = pveWeights( imlook4d_ROI, sigma_pixels);            

    roiNumbers = unique(ROIs);  % List of available ROIs (starting with ROI 0, which is empty)
    roiNumbers = roiNumbers( roiNumbers>0)'; % Remove 0, and make it a row vector (for loop below)


%
% Spill out from all ROIs
%
    numberOfRois = length(roiNumbers);
    P = zeros( size(ROIs));  % Store current smoothed ROI in loop here. 
    W = zeros( [numberOfRois, numberOfRois ]);
    
    % Preload indices
    disp('Preloading indices');
    for i=roiNumbers
        indeces{i} = find(ROIs==i);        % Pixel indeces to static ROI
    end
    
    % Loop static ROI
    for i=roiNumbers
        thisROI = zeros( size(ROIs) );
        disp( [ 'Calculating Weights for ROI = ' num2str(i) ]);
        thisROI( ROIs == i ) = 1;
        %PP = convn( thisROI, psf, 'same'); % 3D pve map of this ROI
        PP = pveMap( thisROI, PSF);
        
        % Find signal from each ROI that goes into static ROI
        for j=roiNumbers
            W(i,j) = mean( PP(indeces{j}) );   % Cross talk (from ROI j to ROI i)
        end
        
    end


