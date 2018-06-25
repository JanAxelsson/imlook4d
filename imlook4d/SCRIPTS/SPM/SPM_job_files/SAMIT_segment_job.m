%-----------------------------------------------------------------------
% Job saved on 29-May-2018 16:34:37 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
NONE = [0 0];
NATIVE_TISSUE_CLASS_IMAGE = [1 0]; % No = [0 0] ; Native = [ 1 0 ]; Dartel Import [ 0 1]; Both [1 1]


%matlabbatch{1}.spm.spatial.preproc.channel.vols = { [imlook4d_current_handles.image.folder imlook4d_current_handles.image.file] };
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = Inf;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = { [which('Schwarz_brain.nii') ',1']}; % Gray matter
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = NATIVE_TISSUE_CLASS_IMAGE;
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = NONE;
% matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[which('TPM.nii') ',1']};  % White matter
% matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
% matlabbatch{1}.spm.spatial.preproc.tissue(2).native = NATIVE_TISSUE_CLASS_IMAGE;
% matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = NONE;
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[which('Schwarz_csf.nii') ',1']};  % CSF
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = NATIVE_TISSUE_CLASS_IMAGE;
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = NONE;
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[which('Schwarz_bg.nii') ',1']};  % Background
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = NATIVE_TISSUE_CLASS_IMAGE;
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = NONE;
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[which('Schwarz_muscle.nii') ',1']};  % Soft tissue
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = NATIVE_TISSUE_CLASS_IMAGE;
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = NONE;
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[which('Schwarz_other.nii') ',1']};  % Other
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = NATIVE_TISSUE_CLASS_IMAGE;
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = NONE;
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 0;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 0;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'subj';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 1;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 1; % TODO: Optimera ?  Was 1
matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1]; % Write inverse = [1 0]; Write forward = [0 1]; Write both = [1 1]
