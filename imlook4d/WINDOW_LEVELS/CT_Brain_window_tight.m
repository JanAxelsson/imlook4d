function Brain_window_tight(hObject, eventdata, handles)

    window=[-75 150];

    % Display HELP and get out of callback
     if imlook4d('DisplayHelp', hObject, eventdata, handles) 
         return 
     end
     
    % Set window level
    imlook4d('setColorBar',guidata(gcf),window )