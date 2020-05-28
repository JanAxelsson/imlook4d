pveFactors = [];
StoreVariables;
ExportUntouched;

% Calculate pve factors for all combination of ROIs
% using the Geometric Transfer Matrix (GTM) method 
% (Rousset OG, Ma Y, Evans AC, J Nucl Med. 1998 May;39(5):904-11).


% Dialog
prompt={'x FWHM [mm]', 'y FWHM [mm]', 'z FWHM [mm]'};
title='Define PSF';
numlines=1;
defaultanswer={ '5', '5', '5' };
%answer=inputdlg(prompt,title,numlines,defaultanswer);
answer=ModelDialog(imlook4d_current_handles, 'PVE', prompt,defaultanswer);

% FWHM
fwhm = [ str2num(answer{1}) str2num(answer{2}) str2num(answer{3}) ];

% Voxel size
vox = voxel_size(imlook4d_current_handles);

% Convert known resolution in mm fwhm=[ 3.59, 3.40, 4.32], to fwhm in pixels
fwhm_pixels = pixels( fwhm, vox);

% Convert from fwhm to sigma
sigma_pixels = fwhm_pixels / 2.35



measTACT = tactFromMatrix(imlook4d_Cdata,imlook4d_ROI)';
pveFactors = pveWeights( imlook4d_ROI, sigma_pixels);

ClearVariables;
