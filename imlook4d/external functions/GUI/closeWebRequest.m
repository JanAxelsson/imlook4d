function closeWebRequest(hObject,event)

disp('Detected : You closed the Web browser');
handles = guidata(gcf); set( handles.helpToggleTool,'State','off')
