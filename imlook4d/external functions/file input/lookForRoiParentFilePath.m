function newFullPath = lookForRoiParentFilePath( roiFolder, parentVolume)

% Example :
% wrong DICOM file location :      parentVolume = C:\Users\gami0003\Desktop\NY DATA-FLTGLIOM\ID-9\ID-9 (2016-JAN-31) - 295202\<PETinGdspace>\5
% known .roi file location  :      roiFolder =  /Users/jan/Downloads/ID-9_test-2/<PETinGdspace>
%
% unknown DICOM file location I want to find :  /Users/jan/Downloads/ID-9_test-2/<PETinGdspace>/5
%
% Common ground : <PETinGdspace>
%


% Search from where .roi file was open (path)
cd(roiFolder)
folderPointer = roiFolder;

disp([ 'Trying to identify new location of parentVolume = ' parentVolume ])

splitParent = split( split(parentVolume,'/'), '\'); % Allow both Windows and Mac file separators in stored string


% PLAN A : Try to identify relative path from folders within same folder as ROI-file  (=ROI-folder)
disp('Plan A : look for subfolders with correct name -- in same folder as .roi file');
folderList = dir(roiFolder);
firstFolder = length(splitParent)-1; % First folder - assuming last part in parentVolume is a file
for i = 1 : length(folderList)
    if strcmp(folderList(i).name, splitParent{firstFolder})
        newFullPath = [roiFolder folderList(i).name filesep splitParent{firstFolder+1} ];
        disp([ '  newFullPath = ' newFullPath ]);
        return
    end
end


% PLAN B : Try to identify relative path from ROI-folder and upwards
% Algorithm : 
% 1) Eat parentVolume from back until name of last folder exists in roiFolder => commonFolder
% 2) Add part after common folder to beginning of roiFolder
disp('Plan B : look for common folder going upwards from parentVolume path');
j = length(splitParent);
while ( j > 0 )
    if contains(roiFolder,splitParent{j} )
        commonFolderName = splitParent{j};
        position = strfind(roiFolder,commonFolderName );
        
        % Path from roiFolder
        commonFolderPath = [roiFolder(1 : position - 1) commonFolderName];
        
        % Build path after common folder
        newFullPath = commonFolderPath;
        for i = (j + 1) : length(splitParent)
            newFullPath = [ newFullPath filesep splitParent{i} ];
        end
        
        % Verify file exists and bail out
        if isfile( newFullPath)
            disp([ '  newFullPath = ' newFullPath ]);
            return
        else
            disp([ '  newFullPath = ' newFullPath ' ( NOT A FILE )']);
            newFullPath = '';
        end
    end
    j = j - 1;
end

% This point reached only if no file found
dispRed([ 'Failed finding relative path' ]);
dispRed([ 'Select image file manually' ]);

% Select file
[file,path,indx] = uigetfile( ...
    {'*',  'All Files'} ...
   ,'FALLBACK - Select image file to open');

newFullPath = [path file];



