function outFile = imlook4d_spm_dicom_to_4D_nifti( dicomInputDirectory, outFileName)
% Example
%  imlook4d_spm_dicom_to_4D_nifti( '/home/jan/Desktop/imlook4d/imlook4d_DEVELOP/test_data/PET-Hoffman/[PT] AC Brain (2X5 min) - serie7', 'test');
cd(dicomInputDirectory);
filenames = dir( dicomInputDirectory);


% Read Dicom Headers from SPM
j=1;
for i=1:length(filenames);
  disp(i);
  try
    hdr(j) = spm_dicom_headers(filenames(i).name);
    hdr(j).Modality = 'MRI';
    j = j+1;
  catch
  end
end

% Convert to 3D Nifti using SPM
out = spm_dicom_convert(hdr, 'standard', 'flat', 'nii');

% Make 4D Nifti using SPM
V4 = spm_file_merge(out.files,outFileName,0);

% Remove temporary 3D files
delete(out.files{:});

% Return outFile path
outFile = outFileName