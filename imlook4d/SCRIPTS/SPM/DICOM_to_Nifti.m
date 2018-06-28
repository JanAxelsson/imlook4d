StoreVariables;
% 
% [file,path] = uigetfile( ...
%      { '*',  'All Files'; ...
%        '*.dcm',  'DICOM files (*.dcm)'; ...
%      } ...
%      ,'Select one file to open');
% fullPath=[path file];

if strcmp( imlook4d_current_handles.image.fileType, 'DICOM')
    fullPath = [ imlook4d_current_handles.image.folder  imlook4d_current_handles.image.file ];
else
    warning('The current path is not a DICOM file');
    return
end

[folder file extension] = fileparts(fullPath);
disp(['Input folder DICOM files = ' folder ]);

[file,path] = uiputfile(['*.nii'] ,'Save as .hdr AND .img file', [folder filesep 'out.nii']);   
outFilePath = [ path file ];
% 
% answer = inputdlg('Set output file name (or full file path):', ...
%     'Set Nifti output file name',...
%     [1, 100], ...
%     {[folder filesep 'out.nii']} ...
%     );
% 
% outFilePath = answer{1};

disp(['Output folder Nifti file = ' folder ]);


outFile = imlook4d_spm_dicom_to_4D_nifti( folder, outFilePath);

disp(['Saved converted Nifti to file = ' outFile]);

%
% Open converted file
%

% From recorded script:
INPUTS = Parameters( {outFile} );
imlook4d_current_handle = Open(INPUTS{1}); % Handle to imlook4d window

ClearVariables;