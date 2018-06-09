StoreVariables
tic

aliveChecker = imlook4d_alive('spm'); % Print '.' while 'spm' in call stack (meaning that it is running). Stop-command: delete(aliveChecker)

if ~exist('atlasFileName')
    % Defaults
    atlasFileName = 'labels_Neuromorphometrics.nii'
    atlasLUT = 'labels_Neuromorphometrics.txt';
end
    
% atlasFileName = 'AAL2.nii';
% atlasLUT = 'AAL2.txt';
% 
% atlasFileName = 'labels_Neuromorphometrics.nii'
% atlasLUT = 'labels_Neuromorphometrics.txt';

%% Segment
file = [imlook4d_current_handles.image.folder imlook4d_current_handles.image.file];
[folder,name,ext] = fileparts(file);

% Setup segment job
General_segment_job; % Setup segmentation and match
matlabbatch{1}.spm.spatial.preproc.channel.vols = { file };
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 5; % Smoothing FWHM (about 5 for PET and SPECT, 0 for fMRI)

mniToNativeTransform = [ folder filesep 'iy_' name ext]; % Output deformation file MNI -> Native
nativeToMniTransform = [ folder filesep 'y_' name ext]; % Output deformation file MNI -> Native

% List files involved
disp( 'Generate transforms MNI <-> Native :' );
dispOpenWithImlook4d( '   input  : native image              = ', file  );
for i = 1: length( matlabbatch{1}.spm.spatial.preproc.tissue)
    dispOpenWithImlook4d( '   input  : tissue probability map    = ', matlabbatch{1}.spm.spatial.preproc.tissue(i).tpm{1}  );
end
dispOpenWithImlook4d( '   output : transform (MNI -> Native) = ', mniToNativeTransform  );
dispOpenWithImlook4d( '   output : transform (Native -> MNI) = ', nativeToMniTransform  ); % Stored as a convenience, to allow for conversion Native images to MNI

% Run segment job
disp(' ')
disp('This will take a number of minutes!')

spm_jobman('run',matlabbatch);

%% Deform atlas to original space
clear matlabbatch;
spm('defaults', 'PET');

% Setup deformation job
atlasFile = which( atlasFileName );

Defortmation_AAL_job; % Setup deformation
matlabbatch{1}.spm.util.defs.comp{1}.def = { mniToNativeTransform }; % Deformation file: MNI->Native
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = { atlasFile }; % Atlas in MNI
prefix = matlabbatch{1}.spm.util.defs.out{1}.pull.prefix; % As defined in matlabbatch
outRoiFile = [  folder filesep prefix atlasFileName ]

% List files involved
disp( 'Atlas to native space :' );
dispOpenWithImlook4d( '   input : transform (MNI -> Native) = ', mniToNativeTransform  );
dispOpenWithImlook4d( '   input : atlas in MNI-space        = ', atlasFile  );
dispOpenWithImlook4d( '   output: atlas in native-space     = ', outRoiFile);

% Run deformation job
spm_jobman('run',matlabbatch);

%% Load native-space ROI

LoadROI( outRoiFile );
%% Load ROI-names
ROI_naming_from_file( atlasLUT);

%% Copy LUT to folder (ROI-file already created)

prefix = matlabbatch{1}.spm.util.defs.out{1}.pull.prefix; % = 'native_' from Defortmation_AAL_job;
newFile = [ prefix atlasLUT ];
copyfile( which(atlasLUT), [ folder filesep newFile ] );
dispOpenWithImlook4d( 'Write native ROI names file = ', [ folder filesep newFile ]  );

%% Copy MNI ROI file and LUT to  folder
prefix = 'mni_';
% ROI file
newFile = [ prefix atlasFileName ];
copyfile( which(atlasFileName), [ folder filesep newFile ] );
dispOpenWithImlook4d( 'Write MNI ROI names file    = ', [ folder filesep newFile ]  );

% LUT file
newFile = [ prefix atlasLUT ];
copyfile( which(atlasLUT), [ folder filesep newFile ] );
dispOpenWithImlook4d( 'Write MNI ROI file          = ', [ folder filesep newFile ]  );

%% Clear 
clear matlabbatch;
stop(aliveChecker);
delete(aliveChecker); 
toc
ClearVariables;