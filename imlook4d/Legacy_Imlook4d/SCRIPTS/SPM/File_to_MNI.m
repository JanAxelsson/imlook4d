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
if ~verifySpmExists()
    return
end

if ~exist('atlas','var')
    % Defaults
    atlas.atlasDefinitionFile = 'labels_Neuromorphometrics';
    run( atlas.atlasDefinitionFile );
end

StoreVariables; % Start a script and open a new instance of imlook4d to play with

file = [imlook4d_current_handles.image.folder imlook4d_current_handles.image.file];
[folder,name,ext] = fileparts(file);
% Transformation native -> MNI
%transformToMNISpace = [ folder filesep 'y_' name ext]; % TODO : Select deformation file
[f,p] = uigetfile('y*.nii','Select an atlas file');
transformToMNISpace = [ p f ];

% Image to MNI space
newFileInMNISpace = [folder filesep 'mni_' name ext] ;


disp( 'Convert native image ->  MNI  :' );
dispOpenWithImlook4d( 'input : transform          = ', transformToMNISpace  );
dispOpenWithImlook4d( 'input : native-space file  = ', file  );
dispOpenWithImlook4d( 'output: MNI-space file     = ', newFileInMNISpace);

%% Deform image Native->MNI
clear matlabbatch;
spm('defaults', 'PET');
run( atlas.deformationScript) ; % Setup deformation
matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 1; % Trilinear
matlabbatch{1}.spm.util.defs.comp{1}.def = { transformToMNISpace }; % Deformation file: Nativ -> MNI
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = { file }; % file in native
prefix = 'mni_';
matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = prefix;
spm_jobman('run',matlabbatch);

Open(newFileInMNISpace);

%% Copy MNI ROI file and LUT to  folder
prefix = 'mni_';
% ROI file
roiFile = [ prefix atlas.atlasFileName ];
copyfile( which( atlas.atlasFileName), roiFile );
dispOpenWithImlook4d( 'Write MNI ROI names file    = ', [ folder filesep roiFile ] );

% LUT file
newFile = [ prefix atlas.atlasLUT ];
copyfile( which( atlas.atlasLUT), [ folder filesep newFile ] );
dispOpenWithImlook4d( 'Write MNI ROI file          = ', [ folder filesep newFile ]  );


%% TODO:  Reslice ROI file from original Matrix to TPM matrix (which defines our
% MNI matrix)


%% Open ROI
fullRoiFile = [ folder filesep roiFile ];
LoadROI( fullRoiFile );

%% Load ROI-names
ROI_naming_from_file( which( atlas.atlasLUT));


ClearVariables
