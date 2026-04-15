    % End a typical script and import modified data 
    % EXCEPT imlook4d_Cdata which is ignore
    %
    % Same as EndScript, but uses ImportUntouched instead of Import
    %
    % The variable historyDescriptor must be set to a descriptive string.
    % The script must have been started with command StartScript


    % Set new window title 
    %(set historyDescriptor infront of existing  window title)
    Title    
    
    % Import data (variables, and imlook4d_current_handles)
    ImportUntouched
                           
    % Set scale in X and Y direction
    set(imlook4d_current_handles.axes1, 'XLim', [1 size(imlook4d_Cdata,1)])
    set(imlook4d_current_handles.axes1, 'YLim', [1 size(imlook4d_Cdata,2)])
    
    % Move window to top
    %set(imlook4d_current_handle, 'Visible', 'on');  
    figure(imlook4d_current_handle)
        
    % Clean up  variables created in this script
    ClearVariables
    
    % Clean variables typically set before StartScript is called
    clear historyDescriptor
    
    displayMessageRow( 'Done')