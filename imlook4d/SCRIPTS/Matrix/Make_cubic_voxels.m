StartScript

    historyDescriptor='isotropic_'; % Make a descriptor to prefix new window title with
    

    % Orginalbild pixel positions
    s = size(imlook4d_Cdata);
    x1size= imlook4d_current_handles.image.pixelSizeX * s(1); % Size in mm
    y1size= imlook4d_current_handles.image.pixelSizeY * s(2);
    z1size= imlook4d_current_handles.image.sliceSpacing * s(3);
    
    x1 = single( linspace(0, x1size, s(1) ) ); % positions in mm
    y1 = single( linspace(0, y1size, s(2) ) );
    z1 = single( linspace(0, z1size, s(3) ) );
    
    [X1 ,Y1, Z1]=ndgrid(x1, y1, z1); % Grid of positions

    
    % New image pixel positions (use smallest pixel dimension)
    isotropicPixelSize = min( [ imlook4d_current_handles.image.pixelSizeX, ...
        imlook4d_current_handles.image.pixelSizeY, ...
        imlook4d_current_handles.image.sliceSpacing ] );
    
    % User input, allow to change size of voxels
        prompt={'Voxel side (mm) ' };
        title='Resize image matrix';
        numlines=1;
        defaultanswer={ num2str(isotropicPixelSize) };
        answer=inputdlg(prompt,title,numlines,defaultanswer);
        isotropicPixelSize=(str2num(answer{1}));
    
    
    % New number of pixels
    xPixels = round( x1size / isotropicPixelSize); % Image size / number of pixels
    yPixels = round( y1size / isotropicPixelSize);
    zPixels = round( z1size / isotropicPixelSize);
    
    % New image size as close as possible to old image size
    x2size = isotropicPixelSize * xPixels;
    y2size = isotropicPixelSize * yPixels;
    z2size = isotropicPixelSize * zPixels;
    
    x2=single( linspace( 0, x2size, xPixels ) );
    y2=single( linspace( 0, y2size, yPixels ) );
    z2=single( linspace( 0, z2size, zPixels ) );
    
    [X2 ,Y2, Z2]=ndgrid(x2, y2, z2);
    clear x2 y2 z2
    
    imlook4d_Cdata = interpn(X1, Y1, Z1, imlook4d_Cdata, X2, Y2, Z2, 'linear');

    % Set new pixel sizes
    imlook4d_current_handles.image.pixelSizeX = isotropicPixelSize;
    imlook4d_current_handles.image.pixelSizeY = isotropicPixelSize;
    imlook4d_current_handles.image.sliceSpacing = isotropicPixelSize;

    
    % Fix ROI dimensions
    %imlook4d_ROI = zeros( xPixels, yPixels, zPixels);
    imlook4d_ROI = interpn(X1, Y1, Z1, imlook4d_ROI, X2, Y2, Z2, 'nearest');


EndScript

