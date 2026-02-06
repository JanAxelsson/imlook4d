function closeWebRequest(hObject,event)

disp('Detected : You closed the Web browser');
handles = guidata(gcf); set( handles.helpToggleTool,'State','off')

%topLevelAncestor = get(hObject,'TopLevelAncestor');
%set(topLevelAncestor, 'DefaultCloseOperation', 0);
