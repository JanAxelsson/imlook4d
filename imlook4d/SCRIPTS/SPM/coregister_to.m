% SPM_coregister
% ---------------------
% This script uses SPM coregistration for Dynamic PET.
% Input : mean image of the dynamic PET, acting as source
%         T1 MR image, acting as REF
%         Dynamic PET, acting as OTHER
% Output: coregisterd Dynamic PET to T1 image, saved as Nifti file (same file name but prefix 'r')
%
% If .sif file exists with time information, that is copied.
%
% NOTE: Realingment must be performed before!

StoreVariables;
aliveChecker = imlook4d_alive('spm'); % Print '.' while 'spm' in call stack (meaning that it is running). Stop-command: delete(aliveChecker)
Export;

% From image 
% (realinged image, but could also be original without realingment -- 
% prefix=r if realigned,   no prefix otherwise)
realingedPath = [ imlook4d_current_handles.image.folder  imlook4d_current_handles.image.file ];

% meanImagePath -- depending on if starting from realinged PET, or skipping realigned PET
if strcmp( imlook4d_current_handles.image.file(1), 'r') % starts with 'r'?
    % 3D Image used as source in registration (mean image from realingment, which is in same space as
    meanImagePath = [ imlook4d_current_handles.image.folder  'mean' imlook4d_current_handles.image.file(2:end) ]; % remove 'r' in 'rSharp.nii', make it 'meanSharp.nii'   
else
    meanImagePath = [ imlook4d_current_handles.image.folder  'mean' imlook4d_current_handles.image.file(1:end) ]; % make it 'meanSharp.nii' (it does not exist yet)     
end

% TODO : if 3D image, then there is no need to create a mean image.  Use
% existing 3D image as meanImage

% If mean image does not exist : Create mean image of dynamic PET (called realingedPath)
if ~exist(meanImagePath, 'file')
    % SPM routines
    V = spm_vol(realingedPath);
    Y = spm_read_vols(V);
    
    % Mean image
    Y = mean(Y,4);
    Vnew = V(1);
    
    Vnew.dim = size(Y);
    Vnew.fname = meanImagePath;
    spm_write_vol(Vnew, Y);

end




% Output Dynamic Image
newFilePrefix = 'r';
newPath = [ imlook4d_current_handles.image.folder newFilePrefix imlook4d_current_handles.image.file ];

numberOfFrames = size(imlook4d_Cdata,4);

% Get Reference Image
[fileRef,pathRef] = uigetfile( ...
    { ...
    '*.nii','Nifti Files (*.nii)'; ...
    '*',  'All Files'; ...
    }, ...
   'Select Reference 4D Nifti File');

RefPath=[pathRef fileRef];

% Data fields that can be modified in your own code:
% --------------------------------------------------
% imlook4d_Cdata      - 3D, or 4D data matrix with indeces to (x, y, z, time) coordinates
% imlook4d_ROI        - 3D ROI matrix (pixels from ROI 1 has value 1, ROI2 value 2, ...)
% imlook4d_slice      - current slice number
% imlook4d_frame      - current frame number
% imlook4d_ROI_number - current ROI number
% imlook4d_ROINames   - cell with ROI names

% --------------------------------------------------
% START OWN CODE:
% --------------------------------------------------

spm('defaults','pet');
spm_jobman('initcfg');

matlabbatch{1}.spm.util.exp_frames.files = { [realingedPath ',1']};
%matlabbatch{1}.spm.util.exp_frames.files = {'/Users/jan/Desktop/IMAGES/DAD-tests/D34/native/Sharp.nii,1'};
matlabbatch{1}.spm.util.exp_frames.frames = [1 : numberOfFrames];
%matlabbatch{1}.spm.util.exp_frames.frames = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18];


matlabbatch{2}.spm.spatial.coreg.estwrite.ref = {RefPath};
%matlabbatch{2}.spm.spatial.coreg.estwrite.ref = {'/Users/jan/Desktop/IMAGES/DAD-tests/D34/native/T1w.nii,1'};

%matlabbatch{2}.spm.spatial.coreg.estwrite.source(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.spatial.coreg.estwrite.source = { [ meanImagePath ',1'] };

matlabbatch{2}.spm.spatial.coreg.estwrite.other = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
%matlabbatch{2}.spm.spatial.coreg.estwrite.other = {'/Users/jan/Desktop/IMAGES/DAD-tests/D34/native/atlas_D34.nii,1'};

matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.interp = 1;
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.prefix = newFilePrefix;

spm_jobman('run',matlabbatch);



% Copy .sif file if exists
try
    oldSif = strrep(realingedPath, 'nii','sif');
    newSif = strrep(newPath, 'nii','sif');
    copyfile(oldSif, newSif)
catch
end


% Display
imlook4d(newPath);

% --------------------------------------------------
% END OF OWN CODE
% --------------------------------------------------

% Clean up  variables created in this script
clear matlabbatch;
delete(aliveChecker); 
ClearVariables

