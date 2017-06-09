% Coronal_View.m
%
% SCRIPT for imlook4d
% Jan Axelsson

% INITIALIZE

    disp('SCRIPTS/Coronal_View.m entered');
    StartScript

    % Reformat  
    
        % Change matrix
        imlook4d_Cdata=flipdim(imlook4d_Cdata,3); % Flip upside down in z-direction
        imlook4d_Cdata=permute(imlook4d_Cdata, [1 3 2 4]);  % Image
        imlook4d_ROI=flipdim(imlook4d_ROI,3); % Flip upside down in z-direction
        imlook4d_ROI=permute(imlook4d_ROI, [1 3 2 4]);      % ROI
        
        % Set pixel dimensions
        try
            pixelSizeX=imlook4d_current_handles.image.pixelSizeX;
            pixelSizeY=imlook4d_current_handles.image.pixelSizeY;
            sliceSpacing=imlook4d_current_handles.image.sliceSpacing;
        catch
            disp('ERROR - pixelsizes undefined, setting them to 1');
            pixelSizeX=1;
            pixelSizeY=1;
            sliceSpacing=1;
        end
        
        % Set scale in X and Y direction
        set(imlook4d_current_handles.axes1, 'XLim', [1 size(imlook4d_Cdata,1)])
        set(imlook4d_current_handles.axes1, 'YLim', [1 size(imlook4d_Cdata,2)])
        
         imlook4d_current_handles.image.pixelSizeY=sliceSpacing;
         imlook4d_current_handles.image.sliceSpacing=pixelSizeY;
         imlook4d_current_handles.image.pixelSizeX=pixelSizeX;
        
    % Store view type
        imlook4d_current_handles.image.plane='Coronal';
        
    % Set title
        WindowTitle(['(' imlook4d_current_handles.image.plane ')'],'append') 

    % Record history (what this image has been through)
        imlook4d_current_handles.image.history=['COR' '-' imlook4d_current_handles.image.history  ];
    
    % Finish
        %clear imlook4d_time2 imlook4d_duration2 imlook4dWindowTitle x y z newHandle newHandles
        EndScript
        disp('SCRIPTS/Coronal_View.m DONE');
    
% 
% GUIDANCE ON HOW TO CONTROL AN IMLOOK4D INSTANCE FROM SCRIPTS
% ------------------------------------------------------------
%  
% WORK WITH IMLOOK4D INSTANCE IN MATLAB - THE SIMPLE WAY
%
%   1a) imlook4d/SCRIPT menu to make active window handles in workspace:
%       imlook4d_current_handle     handle to imlook4d equivalent to hObject in imlook4d callback functions
%       imlook4d_current_handles    equivalent to handles in this code (This is what you work with)
%
%   1b) imlook4d/Workspace/Export or Import menu to push active window data to workspace or pull from workspace:
%
%         This method applies to common data.  Otherwise methods 2) and 3)
%         below must be used.
%
%         imlook4d_time        vector of frame times (exists only when time data exists)
%         imlook4d_duration    vector of frame duration (exists only when duration data exists)
%         imlook4d_Cdata       4D matrix of image data [x, y, slice,frame]
%         imlook4d_ROI         3D matrix of ROI data [x, y, slice] where the pixel value equals the ROI number (thus, only one ROI possible in each pixel)
%         imlook4d_ROINames    ROI names
%
%         NOT IMPORTED:  imlook4d_frame       current frame
%         NOT IMPORTED:  imlook4d_slice       current slice
%         NOT IMPORTED:  imlook4d_current_handle     handle to imlook4d equivalent to hObject in imlook4d callback functions
%         NOT IMPORTED:  imlook4d_current_handles    equivalent to handles in this code (This is what you work with)
%
%   2) Example:  Modify handles.image.CachedImage from matlab workspace
%       imlook4d_current_handles.image.CachedImage=1000;
%
%   3) Save changed handles to current Imlook4d instance.  This call
%      attaches the modified imlook4d_current_handles to the current imlook4d
%      instance: 
%       guidata(imlook4d_current_handle, imlook4d_current_handles)
%
%
% CALL FUNCTIONS FROM SCRIPT
%
% This applies to calling a function in the current imlook4d instance.
% Relevant examples are calling the Export and Imports from workspace via
% their respective menu callback functions.
%
% EXPORT from current imlook4d
%    imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles); % Exports to workspace from current imlook4d instance
%
% IMPORT to new imlook4d  
%     tempHandle=imlook4d;  % New imlook4d instance
%     tempHandles=guidata(tempHandle);
%     imlook4d('importFromWorkspace_Callback', tempHandle,{},tempHandles);   % Import from workspace
%
