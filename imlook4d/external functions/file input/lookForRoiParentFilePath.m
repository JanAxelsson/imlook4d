function newFullPath = lookForRoiParentFilePath( roiFolder, parentVolume)

%roiPath = path


% Search from where .roi file was open (path)
cd(roiFolder)
folderPointer = roiFolder;

disp([ 'Trying to identify new location of parentVolume = ' parentVolume ])

splitParent = split( split(parentVolume,'/'), '\'); % Allow both Windows and Mac file separators in stored string

% Look for common folder in ROI-folder and and parentFolder -- follow upwards from ROI folder
foundPath = '';
while (length(pwd()) > 3 )
    disp(pwd())
    for j = 1 : length(splitParent)
        if ( isfolder( splitParent{j}) )
            disp(  splitParent{j} )
            foundPath = pwd();
            foundLevel = j;
            break
        end
    end

    cd ..
end

disp([ 'Found common path = ' foundPath ])
disp([ 'Next folder downwards = ' splitParent{foundLevel} ])

% Build complete path
relativeSplit =  splitParent{foundLevel:end};
newFullPath = foundPath;
for i = foundLevel : length(splitParent)
    newFullPath = [newFullPath filesep splitParent{i}];
end

disp([ 'Identified full path = ' splitParent{foundLevel} ])


