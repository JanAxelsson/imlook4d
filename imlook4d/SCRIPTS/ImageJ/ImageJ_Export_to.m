% Export to ImageJ
%
% 
% REQUIRED: MIJ (ImageJ Matlab interface  http://bigwww.epfl.ch/sage/soft/mij/#desc) 
%           ImageJ
% INSTALL PROCEDURE
%           1) Copy ij.jar (from ImageJ) and mij.jar (from MIJ) to directory:  imlook4d\external functions\ImageJ
%           2) Increase java heap memory to 1 GB (Matlab menu > File > Preferences > General >  Java Heap Memory )

    % Store variables (so we can clear all variables created in this script)
StoreVariables;
Export % Export variables from current imlook4d instance

    % Initialize
        javaaddpath(which('ij.jar'));
        javaaddpath(which('mij.jar'));

    % Export to workspace
        %imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace

    % Start imageJ
        MIJ.start();
        
    % Export to imageJ
        image1=MIJ.createImage('image1', imlook4d_Cdata(:,:,:,imlook4d_frame),true);
       

    % Clean up
       % clear image1 imlook4d_Cdata  imlook4d_ROI  imlook4d_ROINames  imlook4d_current_handle  imlook4d_current_handles  imlook4d_duration  imlook4d_frame  imlook4d_slice  imlook4d_time

    ClearVariables
