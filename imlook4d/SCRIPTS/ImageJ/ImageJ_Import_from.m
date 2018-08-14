% Import from ImageJ into a duplicate of the current imlook4d
% Note: here the user can screw up, if the current imlook4d is not the same
% as the one that exported to ImageJ.
%
% 
% REQUIRED: MIJ (ImageJ Matlab interface  http://bigwww.epfl.ch/sage/soft/mij/#desc) 
%           ImageJ
%
% INSTALL PROCEDURE
%           1) Copy ij.jar (from ImageJ) and mij.jar (from MIJ) to directory:  imlook4d\external functions\ImageJ
%           2) Increase java heap memory to 1 GB (Matlab menu > File > Preferences > General >  Java Heap Memory )


StartScript
        
    % Dimensions, assuming you import from same window as exporting
        dim = size(imlook4d_Cdata);

    % Import from ImageJ
        MIJ.run('Hyperstack to Stack'); % Make 3D
        M3=MIJ.getCurrentImage();
        
    % Display as in imlook4d
        M2 = flipud(M3);
        %M2=M3;
        M =imlook4d_fliplr(rot90(M2,3)); % flip and rotate 270 degrees
        
        imlook4d_Cdata = reshape( M, dim(1), dim(2), dim(3), []); % Make 4D

        
    % Record history (what this image has been through)
        historyDescriptor='From ImageJ - ';
        imlook4d_current_handles.image.history=[historyDescriptor '-' imlook4d_current_handles.image.history  ];
        guidata(imlook4d_current_handle, imlook4d_current_handles);
        Title
    
        imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Import from workspace

       

    % Clean up
       % clear imlook4d_Cdata  imlook4d_ROI  imlook4d_ROINames   imlook4d_duration  imlook4d_frame  imlook4d_slice  imlook4d_time historyDescriptor


EndScript