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