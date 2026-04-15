function P = pveMap( ROIs, PSF)
%
% This function calculates a partial-volume-map for ROIs
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
%   P       PVE map with ROI in 4th dimension
%
% Example:
%   % Export from imlook4d.
%   % Get voxelsize in mm.  Can also be specified as vector vox = [ 2 2 2 ];
%   vox = voxel_size(imlook4d_current_handles);  
%    % Convert known resolution in mm fwhm=[ 3.59, 3.40, 4.32], to fwhm in pixels
%   fwhm_pixels = pixels( [ 3.59, 3.40, 4.32], vox);  
%   % Convert from fwhm to sigma
%   sigma_pixels = fwhm_pixels / 2.35;  
%   % Create pve-map
%   P = pveMap( imlook4d_ROI, sigma_pixels);            

    roiNumbers = unique(ROIs);  % List of available ROIs (starting with ROI 0, which is empty)
    roiNumbers = roiNumbers( roiNumbers>0)'; % Remove 0, and make it a row vector (for loop below)

%
% Prepare for Gaussian PSF-matrix
%
   
    % Grid
    c = 3; % Number of sigmas to use in matrix (convolution speed depends on this)
    
    % Standard Deviation
    sigmaX = PSF(1); 
    sigmaY = PSF(2); 
    sigmaZ = PSF(3); 
    
    sx = c*sigmaX; sy = c*sigmaY; sz = c*sigmaZ;
    sx = ceil(sx);sy = ceil(sy);sz = ceil(sz); % integer values (=> range -sx:sx will be symmetric => no false gradients introduced)
    [x,y,z]=meshgrid(-sx:sx,-sy:sy,-sz:sz); 
  
%
% Create Gaussian PSF-matrix
%     
   
    % Point-spread function
    psf = ...
        exp( -(x.^2)/(2*sigmaX^2) ) .* ...
        exp( -(y.^2)/(2*sigmaY^2) ) .* ...
        exp( -(z.^2)/(2*sigmaZ^2) );
    psf = psf / sum(psf(:)); % Normalize to sum 1

    %size(psf)


%
% Spill out from all ROIs
%
    
    P = zeros( [size(ROIs), length(roiNumbers)]);  % Store each smoothed ROI here.  4th dimension is ROI.
    
    for j=roiNumbers
        thisROI = zeros( size(ROIs) );
        disp( [ 'Calculating spill-out for ROI = ' num2str(j) ]);
        thisROI( ROIs == j ) = 1;
        P(:,:,:,j) = convn( thisROI, psf, 'same');
    end   

