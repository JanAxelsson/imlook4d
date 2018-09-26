atlas=[];
StoreVariables 
oldFolder = cd();
folder = fileparts(which('labels_Neuromorphometrics.m') );  % Identify folder by file that I know exists
cd(folder);

[atlasDefinitionFile,path] = uigetfile('*.m','Select an atlas file');

run(atlasDefinitionFile);

if atlasNotAvailable( atlas.atlasFileName)
    dispRed( 'ERROR : atlas file is not on Matlab path');
    dispRed( [ 'Did not find atlas file :' atlas.atlasFileName ] );
    dispRed( 'You may have to download this atlas and "add with subfolders" to the Matlab path');
    dispRed( ['Link to atlas: <a href="' atlas.url '">' atlas.url '</a>.'])
    
    msgbox({ ...
        'Atlas not in Matlab path', ...
        'See matlab command window for more details,', ...
        'and how to obtain atlas' ...
    })
    return % Bail out
end


disp( [ 'Atlas file set to : ' atlasDefinitionFile ]);


% Clean up
cd(oldFolder)
ClearVariables;

function isNotAvailable = atlasNotAvailable( atlas)
    isNotAvailable = isempty( which( atlas ) );
end