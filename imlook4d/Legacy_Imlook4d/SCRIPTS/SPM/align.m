% SPM_realing
% ---------------------
% This script uses SPM realingment for Dynamic PET.
% Input : 4D Nifti
% Output: realigned Nifti file (same file name but prefix 'r')
%
% If .sif file exists with time information, that is copied.
if ~verifySpmExists()
    return
end

StoreVariables;
aliveChecker = imlook4d_alive('spm'); % Print '.' while 'spm' in call stack (meaning that it is running). Stop-command: delete(aliveChecker)

Export;

path = [ imlook4d_current_handles.image.folder  imlook4d_current_handles.image.file ];
newPath = [ imlook4d_current_handles.image.folder 'r' imlook4d_current_handles.image.file ];

numberOfFrames = size(imlook4d_Cdata,4);

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


% First frame dialog
prompt={'First frame (noisy data does not align)'};
[answer, imlook4d_current_handles] = ModelDialog( imlook4d_current_handles, ...
    'align', ...
    prompt, ...
    { '1' } ...
    );

firstFrame = str2num(answer{1});

% Setup realignment

spm('defaults','pet');
spm_jobman('initcfg');

matlabbatch{1}.spm.util.exp_frames.files = { [path ',1']};
%matlabbatch{1}.spm.util.exp_frames.files = {'/Users/jan/Desktop/IMAGES/DAD-tests/D34/native/Sharp.nii,1'};


matlabbatch{1}.spm.util.exp_frames.frames = [firstFrame : numberOfFrames];
disp( ['Aligning frames = ' num2str(firstFrame) ' - ' num2str(numberOfFrames ) ]);

matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1; % Register to mean
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

spm_jobman('run',matlabbatch);

% Copy .sif file if exists
try
    oldSif = strrep(path, 'nii','sif');
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

