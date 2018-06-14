%% Download latest imlook4d
imlook4dFilePath = which('imlook4d.m');
[folder,file,ext] = fileparts(imlook4dFilePath);
zipFilePath = [ folder filesep '..' filesep 'latestImlook4d.zip'];
unzipFolderPath = [ folder filesep '..' filesep 'latestImlook4d'];

% TODO : url to latest path
urlToLatestImlook4d = 'https://drive.google.com/uc?export=download&id=12uG7-vkIFHpvWtMohuo3O-oszpjFGL98';
filename = '/Users/jan/Downloads/imlook4d.zip';

% Get file
zipFilePath = websave(zipFilePath, urlToLatestImlook4d)

%% unzip
output = unzip(zipFilePath, unzipFolderPath);
delete zipFilePath

%% Set Matlab path
a = path;
b = strsplit(a,':'); % Cell array of paths

% Remove old imlook4d paths
for i = 1:length(b)
    if ~isempty(strfind( b{i}, folder))
        disp (b{i});
        rmpath( b{i} );
    end
end

% Add new imlook4d to path
addpath(genpath( unzipFolderPath ));


% TODO : Save path