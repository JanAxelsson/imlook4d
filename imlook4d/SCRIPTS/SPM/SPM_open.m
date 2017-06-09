StoreVariables;

[file,path] = uigetfile( ...
    { ...
    '*.nii','Nifti Files (*.nii)'; ...
    '*',  'All Files'; ...
    }, ...
   'Select one file to open');

fullPath=[path file];

% SPM routines
V = spm_vol(fullPath);
Y = spm_read_vols(V);
h = imlook4d(Y);

% Set Y-direction
newhandles = guidata(h);
set(newhandles.axes1, 'YDir', 'normal');   

% Set Title
WindowTitle(file);

% Remember path
newhandles.image.folder = path;

% Store struct
newhandles.image.spm=V;

guidata(h,newhandles)

ClearVariables;