function newVolInfo = jan_save_nii( matrix, volInfo, filename)
% save nifti using SPM
% matrix = matrix (3D or 4D)
% volInfo = SPM volinfo for matrix of same size (typical use, modify nifty
% from file, then reuse the volInfo from original file)
% filename = file to save to

newVolInfo = volInfo; % Use as template
for i=1:size(matrix,4)
    newVolInfo(i).fname = filename;
    file3d{i} = filename;
    newVolInfo(i).dim = volInfo(i).dim(1:3); % Make 3D
    spm_write_vol( newVolInfo(i), matrix(:,:,:,i));
end