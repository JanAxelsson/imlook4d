atlasFileName = 'AAL2.nii';
atlasLUT = 'AAL2.txt';

%% Segment
Segment_CT_sav_deform_job; % Setup segmentation and match
file = [imlook4d_current_handles.image.folder imlook4d_current_handles.image.file];
[folder,name,ext] = fileparts(file);

matlabbatch{1}.spm.spatial.preproc.channel.vols = { file };
spm_jobman('run',matlabbatch);
%returnedDeformationMatrix = [folder filesep name '_seg8.mat'];

%% AAL2 atlas to original space
fileInAtlasSpace = [ folder filesep 'iy_' name ext]; 
atlasFile = which( atlasFileName );

clear matlabbatch;
spm('defaults', 'PET');
Defortmation_AAL_job; % Setup deformation
matlabbatch{1}.spm.util.defs.comp{1}.def = { fileInAtlasSpace };
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = { atlasFile };
spm_jobman('run',matlabbatch);

%% Load native-space ROI
prefix = matlabbatch{1}.spm.util.defs.out{1}.pull.prefix; % As defined in matlabbatch
outRoiFile = [  folder filesep prefix atlasFileName ]
LoadROI( outRoiFile );
%% Load ROI-names
ROI_naming_from_file( atlasLUT)