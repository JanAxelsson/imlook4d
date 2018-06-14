atlas=[];
StoreVariables 
oldFolder = cd();
folder = fileparts(which('labels_Neuromorphometrics.m') );  % Identify folder by file that I know exists
cd(folder);

[atlasDefinitionFile,path] = uigetfile('*.m','Select an atlas file');

if atlasNotAvailable( atlasDefinitionFile)
    dispRed( 'ERROR : atlas file is not on Matlab path');
    dispRed( [ 'Did not find atlas file :' atlasFileName ] );
    dispRed( 'You may have to download this atlas and "add with subfolders" to the Matlab path');
    
    switch atlasDefinitionFile
        case 'AAL2.m'
            url = 'http://www.gin.cnrs.fr/en/tools/aal-aal2/';
            dispRed( ['Link to <a href="' url '">' url '</a>.'])
            
        case 'ATTbasedFlowTerritories.m'            
            url = 'https://www.researchgate.net/post/Does_anyone_know_of_an_brain_atlas_of_arterial_territories_that_is_registered_to_MNI_or_talaraich_or_some_common_space'
            dispRed( ['Link to <a href="' url '">' url '</a>.'])
            
            url = 'https://figshare.com/articles/ATT_based_flow_territories/1488674'
            dispRed( ['Link to <a href="' url '">' url '</a>.'])

        case 'labels_Neuromorphometrics.m'
            dispRed('This atlas is part of the SPM packet');
            

    end
    return % Bail out
end

atlas.atlasDefinitionFile = atlasDefinitionFile;
run(atlasDefinitionFile);

disp( [ 'Atlas file set to : ' atlasDefinitionFile ]);

% Clean up
cd(oldFolder)
ClearVariables;

function isNotAvailable = atlasNotAvailable( atlas)
    isNotAvailable = isempty( which( atlas ) );
end