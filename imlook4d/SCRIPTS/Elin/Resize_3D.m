
    % Store variables (so we can clear all but these)
    StoreVariables;
    
    historyDescriptor='reformatted'; % Make a descriptor to prefix new window title with
    
    % Spara undan nuvarande bild och information 
    % Nuvarande bild heter image1_handles.image.Cdata
    image1_handles=imlook4d_current_handles;
    image1_handle=imlook4d_current_handle;
    
    % Läs in en bild som fungerar som mall för koordinat-transformationer
    imlook4d_current_handle=imlook4d;
    
    % Exportera variabler ur mall-bild
    Export

    % Processa image1 efter mall-bild
    x1size=image1_handles.image.pixelSizeX*image1_handles.imSize(1);
    y1size=image1_handles.image.pixelSizeY*image1_handles.imSize(2);
    z1size=image1_handles.image.sliceSpacing*image1_handles.imSize(3);
    
    x1=single(linspace(0, x1size, image1_handles.imSize(1)));
    y1=single(linspace(0, y1size, image1_handles.imSize(2)));
    z1=single(linspace(0, z1size, image1_handles.imSize(3)));
    
    [X1 ,Y1, Z1]=ndgrid(x1, y1, z1);
    clear x1 y1 z1
    
    x2size=imlook4d_current_handles.image.pixelSizeX*imlook4d_current_handles.imSize(1);
    y2size=imlook4d_current_handles.image.pixelSizeY*imlook4d_current_handles.imSize(2);
    z2size=imlook4d_current_handles.image.sliceSpacing*imlook4d_current_handles.imSize(3);
    
    x2=single(linspace(x1size/2-x2size/2, x1size/2+x2size/2, imlook4d_current_handles.imSize(1)));
    y2=single(linspace(y1size/2-y2size/2, y1size/2+y2size/2, imlook4d_current_handles.imSize(2)));
    z2=single(linspace(z1size/2-z2size/2, z1size/2+z2size/2, imlook4d_current_handles.imSize(3)));
    
    [X2 ,Y2, Z2]=ndgrid(x2, y2, z2);
    clear x2 y2 z2
    
    imlook4d_Cdata=interpn(X1, Y1, Z1, image1_handles.image.Cdata, X2, Y2, Z2, 'linear');

    % Stoppa in processad image1 i mallbild

    
    % Import data (variables, and imlook4d_current_handles)
    Title                    % Set new window title
    Import
    
    % Clean up  variables created in this script
    ClearVariables



