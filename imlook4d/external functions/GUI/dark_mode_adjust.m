function dark_mode_adjust(hObject, eventdata, handles)
% Fix to make menu text visible in dark mode for Mac

    if ~ismac()
        return
    end

    jFrame = get(handle(hObject),'JavaFrame')
    jMenuBar = jFrame.fHG2Client.getMenuBar()

    for menuIdx = 1 : jMenuBar.getComponentCount
        jMenu = jMenuBar.getComponent(menuIdx-1);
        set(jMenu,'Text',  [ '<HTML><BODY color="#666666">' ...
            get(jMenu,'Text')  ...
            '</BODY></HTML>' ])
    end