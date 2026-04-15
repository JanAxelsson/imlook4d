    % End a typical script and import modified data
    %
    % The variable historyDescriptor must be set to a descriptive string.
    % The script must have been started with command StartScript


    % Set new window title 
    %(set historyDescriptor infront of existing  window title)
    Title    
    
    % Import data (variables, and imlook4d_current_handles)
    Import
                           
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