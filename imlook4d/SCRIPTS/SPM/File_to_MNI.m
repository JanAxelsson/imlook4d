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

if ~exist('atlasFileName')
    select_atlas
end

StoreVariables; % Start a script and open a new instance of imlook4d to play with

file = [imlook4d_current_handles.image.folder imlook4d_current_handles.image.file];
[folder,name,ext] = fileparts(file);
% Image to MNI space
transformToMNISpace = [ folder filesep 'y_' name ext]; 
newFileInMNISpace = [folder filesep 'mni_' name ext] ;

dispOpenWithImlook4d( 'Convert with transform  = ', transformToMNISpace  );
dispOpenWithImlook4d( 'from native-space file  = ', file  );
dispOpenWithImlook4d( 'to MNI-space file       = ', newFileInMNISpace);

%% Deform image Native->MNI
clear matlabbatch;
spm('defaults', 'PET');
Defortmation_AAL_job; % Setup deformation
matlabbatch{1}.spm.util.defs.comp{1}.def = { transformToMNISpace }; % Deformation file: Nativ -> MNI
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = { file }; % file in native
prefix = 'mni_';
matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = prefix;
spm_jobman('run',matlabbatch);

%% Copy LUT file 
newatlasLUT = [ folder filesep prefix atlasLUT ];
copyfile( which(atlasLUT), newatlasLUT  );

Open( newFileInMNISpace);

% TODO:  Reslice ROI file from original Matrix to TPM matrix (which defines our
% MNI matrix)


% Open ROI
newAtlasFile = [ folder filesep prefix atlasFileName ];
LoadROI( newAtlasFile );


ClearVariables
