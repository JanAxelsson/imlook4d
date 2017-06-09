% ImageJ_Bone_Edge_filter.m
%
% Calculates an outline image of the bone to soft tissue interface
% 
% REQUIRED: MIJ (ImageJ Matlab interface  http://bigwww.epfl.ch/sage/soft/mij/#desc) 
%           ImageJ
%
% INSTALL PROCEDURE
%           1) Copy ij.jar (from ImageJ) and mij.jar (from MIJ) to directory:  imlook4d\external functions\ImageJ
%           2) Increase java heap memory to 1 GB (Matlab menu > File > Preferences > General >  Java Heap Memory )

    % Settings
        lowLimit=0;     % Pixels outside interval lowLimit<x<highLimit are set to zero
        highLimit=200;
        
    % Initialize
        javaaddpath(which('ij.jar'));
        javaaddpath(which('mij.jar'));
    

    % Export to workspace
        imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace
        
    % Keep soft tissue (limiting range of values helps finding edges)
        mask=(imlook4d_Cdata>lowLimit)&(imlook4d_Cdata<highLimit);    
        imlook4d_Cdata=imlook4d_Cdata.*mask;     % Zero pixels outside interval  lowLimit<x<highLimit

    % Edge-filter with ImageJ
        image1=MIJ.createImage('image1', imlook4d_Cdata, true );
        MIJ.run('Find Edges');
        MIJ.run('Make Binary');
        out=MIJ.getCurrentImage();
        image1.close();

    % Normalize
        %out=100*out/max(out(:));  % Set a useful range for CT
        %out=out>100;


    % Import
        imlook4d_Cdata=out;
        % Record history (what this image has been through)
        historyDescriptor='Edge';
        imlook4d_current_handles.image.history=[historyDescriptor '-' imlook4d_current_handles.image.history  ];
        guidata(imlook4d_current_handle, imlook4d_current_handles);
    
        imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Import from workspace


    % Clean up
        clear historyDescriptor imlook4d_Cdata imlook4d_ROI imlook4d_ROINames imlook4d_current_handle imlook4d_current_handles imlook4d_frame imlook4d_slice out
        clear highLimit  image1  imlook4d_duration  imlook4d_time  lowLimit  mask


