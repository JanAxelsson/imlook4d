if ~verifySpmExists()
    return
end

StoreVariables
tic

aliveChecker = imlook4d_alive('spm'); % Print '.' while 'spm' in call stack (meaning that it is running). Stop-command: delete(aliveChecker)

if ~exist('atlas','var')
    % Defaults
    atlas.atlasDefinitionFile = 'labels_Neuromorphometrics';
end
    
% Set variables from atlasDefinitionFile:
run(atlas.atlasDefinitionFile); 

%% Segment
file = [imlook4d_current_handles.image.folder imlook4d_current_handles.image.file];
[folder,name,ext] = fileparts(file);

% Setup file to use (handle dynamic)
ISDYNAMIC = ( length( size(imlook4d_current_handles.image.Cdata) ) >3 ); % More than 3 dimensions
if ISDYNAMIC
   % Will create a mean image (sum image, actually), which will be used for registration.
   % Later, the transforms (y_ and iy_ files) are copied so that
   % registration files with original file names (without "mean" in the name) will exist
    
%     % SPM routines
%     V = spm_vol(file);
%     Y = spm_read_vols(V);
%     
%     % Mean image
%     Y = mean(Y,4);
%     Vnew = V(1);
%     
%     meanImagePath = [ folder filesep 'mean' name ext];
%     
%     Vnew.dim = size(Y);
%     Vnew.fname = meanImagePath;
%     spm_write_vol(Vnew, Y);

    [Y, V] = jan_read_nii_niigz(file);
    Y = mean(Y,4);
    Vnew = V(1);
    meanImagePath = [ folder filesep 'mean' name ext];
    jan_save_nii( Y, Vnew, meanImagePath)
    
    matlabbatch{1}.spm.spatial.preproc.channel.vols = { meanImagePath }; 
else
    matlabbatch{1}.spm.spatial.preproc.channel.vols = { file }; 
end


% Setup segment job
run( atlas.segmentationScript); % Setup segmentation and match
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 5; % Smoothing FWHM (about 5 for PET and SPECT, 0 for fMRI)

mniToNativeTransform = [ folder filesep 'iy_' name ext]; % Output deformation file MNI -> Native
nativeToMniTransform = [ folder filesep 'y_' name ext]; % Output deformation file MNI -> Native

actuallyUsedMniToNativeTransform = [ folder filesep 'iy_mean' name ext]; % Output deformation file MNI -> Native
actuallyUsedNativeToMniTransform = [ folder filesep 'y_mean' name ext]; % Output deformation file MNI -> Native

% List files involved
disp( 'Generate transforms MNI <-> Native :' );
dispOpenWithImlook4d( '   input  : native image              = ', file  );
for i = 1: length( matlabbatch{1}.spm.spatial.preproc.tissue)
    dispOpenWithImlook4d( '   input  : tissue probability map    = ', matlabbatch{1}.spm.spatial.preproc.tissue(i).tpm{1}  );
end
dispOpenWithImlook4d( '   output : transform (MNI -> Native) = ', mniToNativeTransform  );
dispOpenWithImlook4d( '   output : transform (Native -> MNI) = ', nativeToMniTransform  ); % Stored as a convenience, to allow for conversion Native images to MNI

% Run segment job
if exist( mniToNativeTransform, 'file') == 2
    disp(' ')
    disp('Transform (MNI -> Native) already exists')
    dispOpenWithImlook4d( 'Using existing transform  (MNI -> Native) = ', mniToNativeTransform  ); % Stored as a convenience, to allow for conversion Native images to MNI
    disp(' ')
    disp('NOTE!  If you want new transforms :  click the two links below,  and run this script again) :')
    disp(['  1) <a href="matlab:delete(''' mniToNativeTransform ''')">Click here to remove transform (MNI -> Native) </a>'])
    disp(['  2) <a href="matlab:delete(''' nativeToMniTransform ''')">Click here to remove transform (Native -> MNI) </a>'])
    disp(' ')
else
    disp(' ')
    disp('This will take a number of minutes!')
    
    spm_jobman('run',matlabbatch);
end

% Rename files (so that Dyn have original file names instead of "mean", which it was registered with)
try
    copyfile(actuallyUsedMniToNativeTransform, mniToNativeTransform)
catch
    disp( [ 'Failed moving files from : ' actuallyUsedMniToNativeTransform '  to  ' mniToNativeTransform]);
end
try
    copyfile(actuallyUsedNativeToMniTransform, nativeToMniTransform)
catch
    disp( [ 'Failed moving files from : ' actuallyUsedNativeToMniTransform '  to  ' nativeToMniTransform]);
end

%% Deform atlas to original space
clear matlabbatch;
spm('defaults', 'PET');

% Setup deformation job
atlasFile = which( atlas.atlasFileName );

run( atlas.deformationScript); % Setup deformation
matlabbatch{1}.spm.util.defs.comp{1}.def = { mniToNativeTransform }; % Deformation file: MNI->Native
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = { atlasFile }; % Atlas in MNI
prefix = matlabbatch{1}.spm.util.defs.out{1}.pull.prefix; % As defined in matlabbatch
outRoiFile = [  folder filesep prefix atlas.atlasFileName ];

% List files involved
disp( 'Transforming atlas to native space :' );

dispOpenWithImlook4d( '   input : transform (MNI -> Native) = ', mniToNativeTransform  );
dispOpenWithImlook4d( '   input : atlas in MNI-space        = ', atlasFile  );
dispOpenWithImlook4d( '   output: atlas in native-space     = ', outRoiFile);

% Run deformation job
spm_jobman('run',matlabbatch);

%% Load native-space ROI

LoadROI( outRoiFile );
%% Load ROI-names
ROI_naming_from_file( which( atlas.atlasLUT));

%% Copy LUT to folder (ROI-file already created)

prefix = matlabbatch{1}.spm.util.defs.out{1}.pull.prefix; % = 'native_' from Defortmation_AAL_job;
newFile = [ prefix atlas.atlasLUT ];
copyfile( which( atlas.atlasLUT), [ folder filesep newFile ] );
dispOpenWithImlook4d( 'Write native ROI names file = ', [ folder filesep newFile ]  );


%% Clear 
clear matlabbatch;
stop(aliveChecker);
delete(aliveChecker); 
toc
ClearVariables;