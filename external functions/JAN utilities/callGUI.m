function callGUI(name, inputString)
% Makes a callback to the imlook4d instance in imlook4d_current_handles in the Matlab workspace
%
% inputs:
%   - name          name of GUI component
%   - inputString   string to set component

% Initialize
    imlook4d_current_handles=evalin('base', 'imlook4d_current_handles');


% Define hObject
    hObjectName=['imlook4d_current_handles' '.' name];
    hObject=eval(hObjectName);



% Set string or value
    if strcmp(get(hObject,'Style'),'edit')
        % String if Edit
        try 
            disp('String');
            set(hObject,'String', inputString);
        catch
        end
    else
        % Value otherwise
        try get(hObject,'Value')
            disp('Value');
            set(hObject,'Value', str2num(inputString));
        catch
        end        
    end


% Callback
    % Extract callback name
    %    on format:   @(hObject,eventdata)imlook4d('FrameNumSlider_Callback',hObject,eventdata,guidata(hObject))
        eventdata=[];
        callbackName=char( get(hObject,'Callback'));
        [token, remain] = strtok(callbackName,'''');  % Split on first ' 
        callbackName=['imlook4d(' remain];            % Add first part, ie, imlook4d(
    % Callback
        eval(callbackName);
    











% 
% 
% % Set value
% set(imlook4d_current_handles.FrameNumEdit,'String', '55');
% 
% % Callback
% imlook4d('FrameNumEdit_Callback', imlook4d_current_handles.FrameNumEdit,{},imlook4d_current_handles);
