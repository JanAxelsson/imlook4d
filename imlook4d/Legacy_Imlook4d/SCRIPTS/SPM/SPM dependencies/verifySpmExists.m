function ok = verifySpmExists()


    oldFolder = cd;
    
    % Check if SPM12 installed
    ok = false;
    try
        ok = strcmp('SPM12', spm('ver') );
        disp(['[OK] -- SPM 12 exists in path  ('  fileparts( which('spm')) ')'] )
    catch
    end
   
    % Bail out if SPM exists
    if ok
        return
    end
    
    %
    % From here, SPM does not exist
    %
    dispRed( 'ERROR : SPM 12  is not on Matlab path');
    dispRed( 'Did not find spm in a folder with name "spm12"' );
    dispRed( 'You may have to download SPM and "add with subfolders" to the Matlab path');
    dispRed( ['Link to atlas: <a href="http://www.fil.ion.ucl.ac.uk/spm/software/download.html">http://www.fil.ion.ucl.ac.uk/spm/software/download.html</a>.'])

    dialogTitle = 'SPM12 not in Matlab path';
    button1 = 'Select SPM12 folder';
    cancelButton = 'Cancel';
    defaultButton = cancelButton;
    dialogText = { ...
        'spm12 not in Matlab path', ...
        'See matlab command window for more details,', ...
        'and how to obtain SPM', ...
        ' ', ...
        'If you have SPM already, press "Select SPM" button to add SPM folder to path, otherwise "Cancel".' ...
        };
    answer = questdlg( dialogText, dialogTitle, button1, cancelButton, defaultButton);
    
    if strcmp( answer, cancelButton)
        cd( oldFolder); % Keep Matlab's current directory
        return % Bail out
    else
        % Add to path
        newPath=java_uigetdir(oldFolder,'Select folder containing SPM ', false); % Use java directory open dialog (nicer than windows)
        if newPath == 0
            disp('Cancelled by user');
            cd( oldFolder); % Keep Matlab's current directory
            return
        end
        
        p = genpath( newPath );
        addpath(p);
        savepath;
        
        cd( oldFolder); % Keep Matlab's current directory
        ok = true;
        disp('SPM added to Matlab path');
        
        % Fix imlook4d incompatibilities with SPM
        fix_SPM_Incompatibilities;
    end