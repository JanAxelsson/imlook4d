StoreVariables;

[file,path] = uigetfile( ...
     { '*',  'All Files'; ...
       '*.dcm',  'DICOM files (*.dcm)'; ...
     } ...
     ,'Select one file to open');

fullPath=[path file];
[folder file extension] = fileparts(fullPath);

disp(['Input folder DICOM files = ' folder ]);

answer = inputdlg('Set output file name (or full file path):', ...
    'Set Nifti output file name',...
    [1, 100], ...
    {[folder filesep 'out.nii']} ...
    );

outFilePath = answer{1};

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