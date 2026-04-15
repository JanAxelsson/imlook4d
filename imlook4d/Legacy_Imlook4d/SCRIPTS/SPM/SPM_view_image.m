StoreVariables

file = [imlook4d_current_handles.image.folder imlook4d_current_handles.image.file];
[folder,name,ext] = fileparts(file);

spm_image('Display',file)
ClearVariables;