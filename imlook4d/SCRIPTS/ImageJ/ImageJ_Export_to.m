% Export to ImageJ
%
% 
% REQUIRED: MIJ (ImageJ Matlab interface  http://bigwww.epfl.ch/sage/soft/mij/#desc) 
%           ImageJ
% INSTALL PROCEDURE
%           1) Copy ij.jar (from ImageJ) and mij.jar (from MIJ) to directory:  imlook4d\external functions\ImageJ
%           2) Increase java heap memory to 1 GB (Matlab menu > File > Preferences > General >  Java Heap Memory )
%
% See https://imagej.net/MATLAB_Scripting


    % Store variables (so we can clear all variables created in this script)
StoreVariables;
Export % Export variables from current imlook4d instance

    % Initialize
        javaaddpath(which('ij.jar'));
        javaaddpath(which('mij.jar'));

    % Export to workspace

    % Start imageJ
        MIJ.start();
        
    % Export to imageJ
        
        dim = size(imlook4d_Cdata);
        Z = num2str(dim(3));
        try
            T = num2str(dim(4));
        catch
            dim(4) = 1;
            T = '1';
        end
        
        % Display as in imlook4d
        M =imlook4d_fliplr(rot90(imlook4d_Cdata,3));
        
        M2 = reshape( M, dim(1), dim(2), dim(3)*dim(4) ); % Make 3D
        M3 = flipud(M2);
        
        image1=MIJ.createImage('image1', M3 , true );
      
        % Make 4D in ImageJ
        MIJ.run('Stack to Hyperstack...', ['order=xyczt(default) channels=1 slices=' Z ' frames=' T ' display=Color']);
                
        

    % Clean up
       % clear image1 imlook4d_Cdata  imlook4d_ROI  imlook4d_ROINames  imlook4d_current_handle  imlook4d_current_handles  imlook4d_duration  imlook4d_frame  imlook4d_slice  imlook4d_time

    ClearVariables
