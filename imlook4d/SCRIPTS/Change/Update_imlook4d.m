disp( [ 'Determining latest available version ']);


ID='13mGVhbnZYUyr6BWq4mXTTo12PvM7gykJ';
latestFileListURL = ['https://drive.google.com/uc?export=download&id=' ID ];

text = webread( latestFileListURL);
data = strsplit( text);
ver = data{1}; % Latest version
url = data{2}; % URL for latest version

disp( [ 'Latest available version = ' ver ]);

%% Compare if already at latest version
try
    version=getImlook4dVersion();
    if strcmp( version, ver)
        disp([ 'You already have the latest version = ' ver ]);
        return
    end
catch
    % Continue and download (probably failed because getImlook4dVersion did
    % not exist in old imlook4d)
end

urlToLatestImlook4d = url;

%% Download latest imlook4d


disp( [ 'Downloading version = ' ver ]);

% /aaa/bbb/ccc/imlook4d/imlook4d.m
% /aaa/bbb/ccc/imlook4d/
% 
imlook4dFilePath = which('imlook4d.m'); % imlook4dFilePath = /aaa/bbb/ccc/imlook4d/imlook4d.m
if isempty(imlook4dFilePath)
    warning('imlook4d is not in path -- cannot install');
    warning('Please download and install manually from ');
    warning(urlToLatestImlook4d)
    return
end


[folder,file,ext] = fileparts(imlook4dFilePath); % folder = /aaa/bbb/ccc/imlook4d

[zipFileFolder,file,ext] = fileparts(folder); % zipFileFolder = /aaa/bbb/ccc
zipFilePath = [ zipFileFolder filesep 'latestImlook4d.zip']; % zipFilePath = /aaa/bbb/ccc/latestImlook4d.zip

unzipFolderPath = [ zipFileFolder filesep 'latestImlook4d']; % unzipFolderPath = /aaa/bbb/ccc/latestImlook4d

% Get file
options = weboptions('RequestMethod','get');
options = weboptions('Timeout',Inf);
zipFilePath = websave(zipFilePath, urlToLatestImlook4d,options);

%% unzip
disp( [ 'Unzipping' ]);

folderName = unzip(zipFilePath, unzipFolderPath);
delete( zipFilePath)

%% Change name of folder
[parentFolder,name,ext] = fileparts(unzipFolderPath);

newFolderName = [ parentFolder filesep  'imlook4d_' ver  ];

disp( [ 'Installing to folder = ' newFolderName ]);
movefile( unzipFolderPath, newFolderName);

%% Set Matlab path
disp( [ 'Remove old imlook4d from matlab path = ' folder]);

a = path;
b = strsplit(a,':'); % Cell array of paths

% Remove old imlook4d paths
for i = 1:length(b)
    if ~isempty(strfind( b{i}, folder)) % Remove everything containing path to imlook4d installation
        %disp (b{i});
        rmpath( b{i} );
    end
end

% Add new imlook4d to path
disp( [ 'Set new imlook4d matlab path = ' newFolderName]);
addpath(genpath( newFolderName ));


disp( [ 'Installation DONE!  Old version remains on disk']);
disp( [ ' ']);

%% TODO : Save path
disp('<a href="matlab:savepath">Click to save path (makes new version default) </a>')
