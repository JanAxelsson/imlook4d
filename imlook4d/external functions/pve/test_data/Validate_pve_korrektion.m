% Script recording started at : 15-Jan-2016 17:14:03

fullPath = which('pveCorrection');
[BASE, name, ext] = fileparts( fullPath);
TESTDATA = [ BASE filesep 'test_data' filesep];

INPUTS = Parameters( {[ TESTDATA 'Test_puck_gaussian3D_FWHM=11.75mm.mat']} );
imlook4d_current_handle = Open(INPUTS{1}); % Handle to imlook4d window

%INPUTS = Parameters( {[ TESTDATA 'Test_puck.roi' ]} );
INPUTS = Parameters( {[ TESTDATA 'ROIs.roi' ]} );
Menu('Load ROI')

Export
ROI_data_to_workspace

sigma_pixels = [ 5 5  5];

% On images

    % PVE corrections General (takes lots of memory if many ROIs)
    [C, P, TACT] = pveCorrection( 'MTC',imlook4d_Cdata, imlook4d_ROI, sigma_pixels);
    imlook4d(C); % PVE-corrected matrix
    WindowTitle('PVE-corrected matrix')
    Menu('Interpolate x2')

    disp('  before,   after correction ');
    disp([  imlook4d_ROI_data.mean' TACT' ])

% On TACTS
    % Corrected TACTS
    measTACT = tactFromMatrix(imlook4d_Cdata,imlook4d_ROI)';
    W = pveWeights( imlook4d_ROI, sigma_pixels);

    disp('  before,   after correction ');
    disp([  imlook4d_ROI_data.mean' (W' \ imlook4d_ROI_data.mean')  ])    


