function [C, P, TACT ] = pveCorrection( method, M, ROIs, PSF, varargin)
%
%
% INPUTS
% - method one of 'MTC', 'MGM-percentile'
% - M    3D or 4D matrix 
% - ROIs 3D matrix with ROI indeces
% - PSF  Point spread function in pixels
% - extra arguments
%   for method='MTC': no extra arguments
%   for method='MGM-percentil: extra argument percentile of highest pixels.  See help percentileTACT
%
% OUTPUTS
% - C   PVE-corrected matrix
% - P   PVE map with ROI in 4th dimension
% - TACT   Time-activity curve extracted by method MTC or MGM-percentil
%
% EXAMPLE:
%   % Start with exporting matrices and ROI values from imlook4d
%   Export
%   ROI_data_to_workspace
%   % Get voxelsize in mm.  Can also be specified as vector vox = [ 2 2 2 ];
%   vox = voxel_size(imlook4d_current_handles)
%   %Convert known resolution in mm fwhm=[ 3.59, 3.40, 4.32], to fwhm in pixels
%   fwhm_pixels = pixels( [ 3.59, 3.40, 4.32], vox);
%   % Convert from fwhm to sigma
%   sigma_pixels = fwhm_pixels / 2.35; 
% 
%  % Calculate PVE-corrected using MTC 
%  %(MGM on all ROIs with GMT-corrected true ROI values)
%   [C, P, TACT] = pveCorrection( 'MTC',imlook4d_Cdata, imlook4d_ROI, sigma_pixels); 
%    % Display corrected matrix
%   imlook4d(C); 


roiNumbers = unique(ROIs);  % List of available ROIs (starting with ROI 0, which is empty)
roiNumbers = roiNumbers( roiNumbers>0)'; % Remove 0, and make it a row vector (for loop below)
numberOfROIs = length(roiNumbers);

% Make ROI numbers 1,2, ... instead of  4, 17, ...
j=0;
for i = roiNumbers
   j = j+1;
   ROIs(ROIs==i) = j; 
end



if strcmp( 'MTC', method)
    
    P = pveMap( ROIs, PSF);
    measTACT=tactFromMatrix(M,ROIs);
    TACT = gtm( measTACT, ROIs, P);
    C=pve( TACT, ROIs, M, P);
    
end


if strcmp( method, 'MGM-percentile')
    p=varargin{1};
    
    P = pveMap( ROIs, PSF);
    TACT = percentileTACT( ROIs, M, p);
    C=pve( TACT, ROIs, M, P);
    
end
