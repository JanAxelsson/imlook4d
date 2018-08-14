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
    dispRed('You need to start with a DICOM file');
    return
end

[folder file extension] = fileparts(fullPath);
disp(['Input folder DICOM files = ' folder ]);

% Save to this file
[dummy folderAbove extension] = fileparts(folder);
outputFile = [ folder filesep  strrep( folderAbove, ' ','_') '.nii'] ;
[file,path] = uiputfile(['*.nii'] ,'Save as .hdr AND .img file', outputFile);   
outFilePath = [ path file ];
if file == 0
    disp('Cancelled by user');
    return
end


disp(['Output folder Nifti file = ' folder ]);


outFile = imlook4d_spm_dicom_to_4D_nifti( folder, outFilePath);

disp(['Saved converted Nifti to file = ' outFile]);

%
% SIF-file if dynamic
%
if (size(imlook4d_current_handles.image.Cdata,4)>1) % Dynamic
    [folder file extension] = fileparts(outFilePath);
    sifFilePath = [ folder filesep file '.sif'];
    write_sif( imlook4d_current_handles, sifFilePath); 
end


%
% Open converted file
%

% From recorded script:
INPUTS = Parameters( {outFile} );
imlook4d_current_handle = Open(INPUTS{1}); % Handle to imlook4d window

ClearVariables;