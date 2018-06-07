
atlasLUT = '';
atlasFileName = '';

StoreVariables
oldFolder = cd();
folder = fileparts(which('FreeSurferColorLUT.txt') );  % Identify folder by file that I know exists
cd(folder);

[atlasLUT,path] = uigetfile('*.txt','Select a lookup file with number in left column and names in second column');
atlasFileName = strrep( atlasLUT, '.txt', '.nii');


if atlasNotAvailable( atlasFileName)
    dispRed( 'ERROR : atlas file is not on Matlab path');
    dispRed( [ 'Did not find atlas file :' atlasFileName ] );
    dispRed( 'You may have to download this atlas and "add with subfolders" to the Matlab path');
    
    switch atlasLUT
        case 'AAL2.txt'
            url = 'http://www.gin.cnrs.fr/en/tools/aal-aal2/';
            dispRed( ['Link to <a href="' url '">' url '</a>.'])
            
        case 'FreeSurferColorLUT.txt'
            dispRed(' ');
            dispRed( 'This atlas is not available. The FreeSurferColorLUT can only be used for naming ROI files created with Freesurfer package');

        case 'labels_Neuromorphometrics.txt'
            dispRed('This atlas is part of the SPM packet');

    end
    return % Bail out
end

disp( [ 'Atlas file set to :' atlasFileName ]);

% Clean up
cd(oldFolder)
ClearVariables;

function isNotAvailable = atlasNotAvailable( atlasFileName)
    isNotAvailable = isempty( which( atlasFileName ) );
end