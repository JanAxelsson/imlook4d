StoreVariables  % Remember variables

disp( [ 'Determining latest available version ']);


ID='13mGVhbnZYUyr6BWq4mXTTo12PvM7gykJ';
latestFileListURL = ['https://drive.google.com/uc?export=download&id=' ID ]; 

latestFileListURL = 'https://raw.githubusercontent.com/JanAxelsson/imlook4d/master/imlook4d/latest_releases.txt';

% Test to fix error behind firewall
%text = webread( latestFileListURL);
%o = weboptions('CertificateFilename','');
o = weboptions('Timeout', 30);
text = webread(latestFileListURL,o);

data = strsplit( text);
ver = data{1}; % Latest version
url = data{2}; % URL for latest version

disp( [ 'Latest available version = ' ver ]);


urlToLatestImlook4d = url;

%% Define Paths


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


%% Compare if already at latest version
try
    version=getImlook4dVersion();
    if strcmp( version, ver)
        disp([ 'You already run the latest version = ' ver ]);
        disp(['<a href="matlab:savepath;disp(''DONE!'')">Click to make version "imlook4d ' ver '" default </a>' ])
        return
    end
catch
    % Continue and download (probably failed because getImlook4dVersion did
    % not exist in old imlook4d)
end

%%
% Download if folder is not already in place
%
    
    
    [parentFolder,name,ext] = fileparts(unzipFolderPath);
    newFolderName = [ parentFolder filesep  'imlook4d_' ver  ];
    
%if ~isfolder(newFolderName)  % isfolder only from 2017bm replace with :
if ~exist(newFolderName, 'dir')    
    % Get file
    options = weboptions('RequestMethod','get');
    options = weboptions('Timeout',Inf);
    
    % Download latest imlook4d
    disp( [ 'Downloading version = ' ver ]);
    disp( [ 'from = ' url ]);
    zipFilePath = websave(zipFilePath, urlToLatestImlook4d,options);
    

    % unzip
    disp(' ');
    disp( [ 'Unzipping' ]);
    
    folderName = unzip(zipFilePath, unzipFolderPath);
    [parentFolder,name,ext] = fileparts(unzipFolderPath);
    newFolderName = [ parentFolder filesep  'imlook4d_' ver  ];
    
    delete( zipFilePath)
    
    % Change name of folder
    [parentFolder,name,ext] = fileparts(unzipFolderPath);
    disp( [ 'Installing to folder = ' newFolderName ]);
    movefile( unzipFolderPath, newFolderName);
    
else
    disp( [ 'The latest version already on disk, no need to download again = ' newFolderName]);
end

%% Set Matlab path
disp( [ 'Removing old imlook4d from matlab path = ' folder]);

a = path;
b = strsplit(a,':'); % Cell array of paths

% Remove old imlook4d paths
for i = 1:length(b)
    if ~isempty(strfind( b{i}, folder)) % Remove everything containing path to imlook4d installation
        rmpath( b{i} );
    end
end

% Add new imlook4d to path
disp( [ 'Setting new imlook4d matlab path = ' newFolderName]);
addpath(genpath( newFolderName ));



%% Save path
%disp(['Temporary running new version until set as default.' ])
%disp(['If this version works well for you, please click below link, or do Update again to get another chance to set this as default version.' ])

%disp(['<a href="matlab:savepath;disp(''DONE!'')">Click to make new version "imlook4d ' ver '" default </a>' ])

disp(['Saving as default path' ])
savepath

disp(' ');
disp( [ 'Installation DONE!  Old version remains on disk']);
disp( [ ' ']);

ClearVariables  % Clear remembered variables