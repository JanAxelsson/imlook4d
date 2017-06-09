% Script recording started at : 15-Jan-2016 17:14:03


INPUTS = Parameters( {'C:\Users\Jan\Documents\programmering\imlook4d_DEVELOP\external functions\pve\test_data\Test_puck_gaussian3D_FWHM=11.75mm.mat'} );
imlook4d_current_handle = Open(INPUTS{1}); % Handle to imlook4d window

INPUTS = Parameters( {'C:\Users\Jan\Documents\programmering\imlook4d_DEVELOP\external functions\pve\test_data\Test_puck.roi'} );
Menu('Load ROI')

Export
ROI_data_to_workspace

sigma_pixels = [ 5 5  5];
[C, P, TACT] = pveCorrection( 'MTC',imlook4d_Cdata, imlook4d_ROI, sigma_pixels);imlook4d(C)

Menu('Interpolate x2')
