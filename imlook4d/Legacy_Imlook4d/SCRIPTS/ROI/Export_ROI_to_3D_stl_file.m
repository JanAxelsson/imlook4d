% YOUR SCRIPT NAME HERE
% ---------------------
% This is a template for an imlook4d script that runs your code and puts the results into a new imlook4d window.
% For documentation:  a) imlook4d menu "/HELP/Help",   or 
%                     b) type in matlab:   open('Scripting-imlook4d.pdf')  
%
% 1) Edit your own code, and save it in the folder USER_SCRIPTS 
%    (File naming: use "_" instead of space, and only alpha-numeric characters. File name must start with a character)
%    (Example file name: "My_First_Script.m", which will be visible in menu "/SCRIPTS/USER/My First Script")
%
% 2) Open a new imlook4d and the code can be executed on your own data from
%    the menu /SCRIPTS/USER

%StartScript; % Start a script and open a new instance of imlook4d to play with
StoreVariables;
Export

% Data fields that can be modified in your own code:
% --------------------------------------------------
% imlook4d_Cdata      - 3D, or 4D data matrix with indeces to (x, y, z, time) coordinates
% imlook4d_ROI        - 3D ROI matrix (pixels from ROI 1 has value 1, ROI2 value 2, ...)
% imlook4d_slice      - current slice number
% imlook4d_frame      - current frame number
% imlook4d_ROI_number - current ROI number
% imlook4d_ROINames   - cell with ROI names

% --------------------------------------------------
% START OWN CODE:
% --------------------------------------------------

    % REQUIRES: stlwrite
    
      % File dialog
      [file,path] = uiputfile(['*.stl'] ,'Save as .stl file');
      fullPath=[path file];

      % Write binary STL from face/vertex data
      tmpvol = false(20,20,20);      % Empty voxel volume
      tmpvol(8:12,8:12,5:15) = 1;    % Turn some voxels on
      
      tmpvol = (imlook4d_ROI==1);
      fv = isosurface(~tmpvol, 0.5); % Make patch w. faces "out"
      
      % Voxel dimensions
      x = imlook4d_current_handles.image.pixelSizeX;
      y = imlook4d_current_handles.image.pixelSizeY;
      z = imlook4d_current_handles.image.sliceSpacing;
      
      transform =  ...
         [x 0 0 
          0 y 0
          0 0 z ];

      
      fv.vertices = ( fv.vertices * transform ); % Scale to voxel dimensions
      
      disp(['Writing binary stl file to ' fullPath]);
      stlwrite(fullPath,fv)        % Save to binary .stl


% --------------------------------------------------
% END OF OWN CODE
% --------------------------------------------------

%EndScript; % Import your changes into new instance and clean up your variables
ClearVariables

