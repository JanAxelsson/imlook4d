if ~verifySpmExists()
    return
end
StoreVariables;

file = [imlook4d_current_handles.image.folder imlook4d_current_handles.image.file];
[filepath,name,ext] = fileparts(file);
newFile = [ filepath filesep name '_centered' ext];
copyfile( file, newFile);

% http://www.nemotos.net/scripts/setorigin_center.m
%
% set origin of image files to the center of xyz dimensions using spm
% functions
% Fumio Yamashita 2014.1.20
st.vol = spm_vol(file);
for i = 1 : size(st.vol,1)
%     newFile = [ st.vol.fname '.nii'];
%     newFile = st.vol.fname;
    stvol = st.vol(i);
    vs = stvol.mat\eye(4);
    vs(1:3,4) = (stvol.dim+1)/2;
end

spm_get_space(newFile ,inv(vs)); % Writes new file
% Open file
imlook4d(newFile)


    
ClearVariables;