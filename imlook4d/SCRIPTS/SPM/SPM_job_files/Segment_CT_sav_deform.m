
% Segment CT
Segment_CT_sav_deform_job; % Setup segmentation and match
file = [imlook4d_current_handles.image.folder imlook4d_current_handles.image.file];
[folder,name,ext] = fileparts(file);

matlabbatch{1}.spm.spatial.preproc.channel.vols = { file };
spm_jobman('run',matlabbatch);
%returnedDeformationMatrix = [folder filesep name '_seg8.mat'];

%% AAL2 atlas to original space
fileInAtlasSpace = [ folder filesep 'iy_' name ext]; 
atlasFile = which('atlas/AAL2.nii');

clear matlabbatch;
spm('defaults', 'PET');
Defortmation_AAL_job; % Setup deformation
matlabbatch{1}.spm.util.defs.comp{1}.def = { fileInAtlasSpace };
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = { atlasFile };
spm_jobman('run',matlabbatch);