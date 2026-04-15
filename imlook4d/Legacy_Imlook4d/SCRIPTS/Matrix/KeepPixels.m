% KeepPixels.m   
%
% SCRIPT for imlook4d to keep only pixels that are within a ROI
% Builds on RemovePixels script
%
%
% Jan Axelsson

% INITIALIZE
StoreVariables

%     button = questdlg('Do your really want to remove pixels outside ROI?','Warning','Yes','No','No')
%     if (strcmp(button,'No'))
%         return
%     end
    
    % Export to workspace
    imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace
    activeROI=get(imlook4d_current_handles.ROINumberMenu,'Value');
    
%
%  PROCESS
%

    % Loop frames
    for i=1:size(imlook4d_Cdata,4)
        temp=imlook4d_Cdata(:,:,:, i);
        temp=temp.*( imlook4d_ROI==activeROI );   % Difference from RemovePixels.m
        imlook4d_Cdata(:,:,:, i)=temp;
    end

%
% FINALIZE
% 
    
    imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Import from workspace
    
    %clear i activeROI temp
ClearVariables    
