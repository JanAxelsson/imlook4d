function Lung_window(hObject, eventdata, handles)

    window=[-1500 500];

    % Display HELP and get out of callback
     if imlook4d('DisplayHelp', hObject, eventdata, handles) 
         return 
     end
     
    % Set window level
    imlook4d('setColorBar',guidata(gcf),window )