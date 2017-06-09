    % Duplicates the imlook4d that was current when calling StartScript
    
    % Retrieve the original imlook4d 
    imlook4d_current_handle=handleToOriginal;

    % Make a duplicate to work on
    Duplicate           % Make a copy of imlook4d instance
    MakeCurrent         % Rename newHandle to imlook4d_current_handle
    %Export              % Export variables
    ExportUntouched
