% YOUR SCRIPT NAME HERE
% ---------------------
% This is a template for an imlook4d script that runs your code and puts the results into a new imlook4d window.
% For documentation:  a) imlook4d menu "/HELP/Help",   or 
%                     b) type in matlab:   open('Scripting-imlook4d.pdf')  
%
% 1) Edit your own code, and save it in the folder USER_SCRIPTS 
%    (File naming: use "_" instead of space, and only alpha-numeric characters. File name must start with a character)
%    (Example file name: "My_First_Script.m", which will be visible in menu "/SCRIPTS/USER/My First Script")
%
% 2) Open a new imlook4d and the code can be executed on your own data from
%    the menu /SCRIPTS/USER

StartScript; % Start a script and open a new instance of imlook4d to play with

% Data fields that can be modified in your own code:
% --------------------------------------------------
% imlook4d_Cdata      - 3D, or 4D data matrix with indeces to (x, y, z, time) coordinates
% imlook4d_ROI        - 3D ROI matrix (pixels from ROI 1 has value 1, ROI2 value 2, ...)
% imlook4d_slice      - current slice number
% imlook4d_frame      - current frame number
% imlook4d_ROI_number - current ROI number
% imlook4d_ROINames   - cell with ROI names

% --------------------------------------------------
% START OWN CODE:
% --------------------------------------------------

% Probability level to use for GM (between 0 and 1)
THRESHOLD = 0.25;

% Open GM file (name c1FILE.nii); this file is called FILE
fullPath = [imlook4d_current_handles.image.folder imlook4d_current_handles.image.file];
[folder,FILE,ext] = fileparts(fullPath);

GM_ROI_file = [ folder filesep 'c1' FILE ext];

try
    nii = load_nii(GM_ROI_file);
    openingMode='load_nii';
catch
    %  Load NIFTI or ANALYZE dataset, but not applying any appropriate affine
    %  geometric transform or voxel intensity scaling.
    %warndlg({'WARNING - load_nii failed.',  'Trying load_untouch_nii.',  'The data will not go through geometrical transforms'});
    try
        nii = load_untouch_nii(GM_ROI_file)
        openingMode='load_untouch_nii';
    catch
        disp(['ERROR loading Gray Matter probability mask.  Does file '  GM_ROI_file 'exist?']);
        return
    end
end

GM = nii.img;

% Remove ROI pixels outside Gray Matter (GM)
GMmax = max(GM(:));

GMpixels = GM > THRESHOLD * GMmax;

newROI = zeros( size(GM) );
newROI(GMpixels) = imlook4d_ROI( GMpixels);

imlook4d_ROI = newROI;


% --------------------------------------------------
% END OF OWN CODE
% --------------------------------------------------

EndScript; % Import your changes into new instance and clean up your variables

