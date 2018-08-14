
spm('defaults', 'PET');

Reslice_mni_matrix_to_tpm_space_job;
fileToReslice = which( atlasFileName );
matlabbatch{1}.spm.spatial.coreg.write.source = {fileToReslice};
spm_jobman('run',matlabbatch);

% Copy from directory of fileToReslice to 