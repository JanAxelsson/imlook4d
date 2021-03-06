% Exchange_Slices_to_Frames.m
%
% SCRIPT for imlook4d
% Jan Axelsson

% INITIALIZE

    %  imlook4d_current_handles is updated whenever SCRIPTS menu in imlook4d is
    %  selected
    disp('SCRIPTS/Exchange_Slices_to_Frames.m entered');
    StartScript
    

    % Export to workspace
   % imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace
    
    % Reformat image
    x=size(imlook4d_Cdata,1);
    y=size(imlook4d_Cdata,2);
    z=size(imlook4d_Cdata,4);      % New number of slices (was frames)
    frames=size(imlook4d_Cdata,3); % New number of frames (was slices)
        
    imlook4d_Cdata=permute(imlook4d_Cdata,[1 2 4 3]);
        
    % Empty ROIs
    imlook4d_ROI=zeros(x,y,z);

    %
    % Display in new imlook4d window
    %

    imlook4dWindowTitle=get(imlook4d_current_handles.figure1,'Name');
    %Duplicate;  % Call SCRIPTS/Duplicate  (handle to new imlook4d instance in newHandle)

    %imlook4d('importFromWorkspace_Callback', newHandle,{},newHandles);  % Import from workspace to new imlook4d instance 
    disp('DONE importing results');

    % Set title
    %set(newHandles.figure1,'Name', [imlook4dWindowTitle '(slices/frames exchanged)']);
    WindowTitle([imlook4dWindowTitle '(slices/frames exchanged)']);


    %clear imlook4d_time2 imlook4d_duration2 imlook4dWindowTitle newHandle newHandles
    
    EndScript

    disp('SCRIPTS/Exchange_Slices_to_Frames.m DONE');
    
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
