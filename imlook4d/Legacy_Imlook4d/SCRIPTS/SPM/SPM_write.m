if ~verifySpmExists()
    return
end

StoreVariables;
Export;

[file,path] = uiputfile(['*.nii'] ,'Save as .nii file');

fullPath=[path file];

VolInfo = imlook4d_current_handles.image.spm;
newVolInfo = jan_save_nii( imlook4d_Cdata, VolInfo, fullPath);

% % SPM routines
% V = imlook4d_current_handles.image.spm;
% V.dim = size(imlook4d_Cdata);
% V.fname = file;
% 
% V = spm_write_vol(V, imlook4d_Cdata);
% 
ClearVariables;
