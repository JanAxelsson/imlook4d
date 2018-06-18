
ID='13mGVhbnZYUyr6BWq4mXTTo12PvM7gykJ';
latestFileListURL = ['https://drive.google.com/uc?export=download&id=' ID ];

text = webread( latestFileListURL);
data = strsplit( text);
ver = data{1}; % Latest version
url = data{2}; % URL for latest version

%% Compare if already at latest version
try
    version=getImlook4dVersion();
    if strcmp( version, ver)
        disp([ 'You already have the latest version' ver ]);
        return
    end
catch
    % Continue and download (probably failed because getImlook4dVersion did
    % not exist in old imlook4d)
end

urlToLatestImlook4d = url;

%% Download latest imlook4d
imlook4dFilePath = which('imlook4d.m');
[folder,file,ext] = fileparts(imlook4dFilePath);
zipFilePath = [ folder filesep '..' filesep 'latestImlook4d.zip'];
unzipFolderPath = [ folder filesep '..' filesep 'latestImlook4d'];

% TODO : url to latest path
%urlToLatestImlook4d = 'https://drive.google.com/uc?export=download&id=12uG7-vkIFHpvWtMohuo3O-oszpjFGL98';
%zipFilePath = '/Users/jan/Downloads/imlook4d.zip';

% Get file
options = weboptions('RequestMethod','get');
options = weboptions('Timeout',Inf);
zipFilePath = websave(zipFilePath, urlToLatestImlook4d,options)

%% unzip
folderName = unzip(zipFilePath, unzipFolderPath);
delete( zipFilePath)

%% Change name of folder
[parentFolder,name,ext] = fileparts(unzipFolderPath);

newFolderName = [ parentFolder filesep  'imlook4d_' ver  ];
movefile( unzipFolderPath, newFolderName);

%% Set Matlab path
a = path;
b = strsplit(a,':'); % Cell array of paths

% Remove old imlook4d paths
for i = 1:length(b)
    if ~isempty(strfind( b{i}, folder)) % Remove everything containing path to imlook4d installation
        disp (b{i});
        rmpath( b{i} );
    end
end

% Add new imlook4d to path
addpath(genpath( newFolderName ));


%% TODO : Save path
disp('<a href="matlab:savepath">Save path (make this downloaded version default) </a>')
