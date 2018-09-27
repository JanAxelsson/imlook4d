atlas=[]; % Make variable, so it will be available after ClearVariables
StoreVariables 
oldFolder = cd();
folder = fileparts(which('labels_Neuromorphometrics.m') );  % Identify folder by file that I know exists
cd(folder);

[atlasDefinitionFile,path] = uigetfile('*.m','Select an atlas file');
atlas.atlasDefinitionFile = atlasDefinitionFile; % Add this to atlas struct, so it will be available for later scripts
run(atlasDefinitionFile);

if atlasNotAvailable( atlas.atlasFileName)
    dispRed( 'ERROR : atlas file is not on Matlab path');
    dispRed( [ 'Did not find atlas file :' atlas.atlasFileName ] );
    dispRed( 'You may have to download this atlas and "add with subfolders" to the Matlab path');
    dispRed( ['Link to atlas: <a href="' atlas.url '">' atlas.url '</a>.'])
    
%     msgbox({ ...
%         'Atlas not in Matlab path', ...
%         'See matlab command window for more details,', ...
%         'and how to obtain atlas' ...
%     })

    dialogTitle = 'Atlas not in Matlab path';
    button1 = 'Select atlas folder';
    cancelButton = 'Cancel';
    defaultButton = cancelButton;
    dialogText = { ...
        'Atlas not in Matlab path.', ...
        'See matlab command window for more details,', ...
        'and how to obtain atlas', ...
        ' ', ...
        'If you have an atlas already, press "Select atlas" button to add atlas folder to path, otherwise "Cancel".' ...
        };
    answer = questdlg( dialogText, dialogTitle, button1, cancelButton, defaultButton);
    
    if strcmp( answer, cancelButton)
        cd( oldFolder); % Keep Matlab's current directory
        return % Bail out
    else
        % Add to path
        newPath=java_uigetdir(oldFolder,'Select folder containing atlas nifti files'); % Use java directory open dialog (nicer than windows)
        if newPath == 0
            disp('Cancelled by user');
            cd( oldFolder); % Keep Matlab's current directory
            return
        end
        
        [folderName,name,ext] = fileparts(newPath);
        p = genpath(folderName);
        addpath(p);
        savepath;
        
        cd( oldFolder); % Keep Matlab's current directory
%         
%         % run again
%         ClearVariables
%         StoreVariables
%         select_atlas
    end
end


disp( [ 'Atlas file set to : ' atlasDefinitionFile ]);


% Clean up
cd(oldFolder)
ClearVariables;

function isNotAvailable = atlasNotAvailable( atlas)
    isNotAvailable = isempty( which( atlas ) );
end