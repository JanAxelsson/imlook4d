% RemovePixels.m
%
% SCRIPT for imlook4d to remove pixels that are within a ROI
%
%
% Jan Axelsson

% INITIALIZE

%     button = questdlg('Do your really want to remove pixels?','Warning','Yes','No','No')
%     if (strcmp(button,'No'))
%         return
%     end
StoreVariables
    
    
    prompt = {'Set ROI pixels to value:'};
    dlg_title = 'Remove ROI pixels';
    num_lines = 1;
    def = {'0'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    
    newValue=str2num(answer{1});


    % Export to workspace
    %imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace
    Export
    activeROI=get(imlook4d_current_handles.ROINumberMenu,'Value');
    
%
%  PROCESS
%

    % Loop frames
    for i=1:size(imlook4d_Cdata,4)
        temp=imlook4d_Cdata(:,:,:, i);
        %temp=temp-temp.*( imlook4d_ROI==activeROI );
        temp(imlook4d_ROI==activeROI)=newValue;
        imlook4d_Cdata(:,:,:, i)=temp;
    end

%
% FINALIZE
% 
    
    %imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Import from workspace
    Import
    
    %clear i activeROI temp
    ClearVariables
    
