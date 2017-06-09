% staticPCA.m
%
% Test of single-frame PCA
%
% The underlying theory is to treat each slice as a frame.
%
% This is done using the standard PCA algorithms I developed.
% Therefore, the data is reformatted so that the slices are moved from the 3d to the
% 4th dimension of the data matrix.
%
% Data, current slice and frame are exported from imlook4d

%
% INITIALIZE
%

     disp('SCRIPTS/staticPCA.m entered');
    
     imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace
    data=imlook4d_Cdata(:,:,:,imlook4d_frame);                                                                                          %Get data
    
    test=get(imlook4d_current_handle,'Name')
    
    % New imlook4d instance
        %tempHandle=imlook4d;
        tempHandle=imlook4d(data);
        tempHandles=guidata(tempHandle);

    % SET GUI on new imlook4d    
        set(tempHandles.FrameText, 'String', 'Slice');  % Set Slider title to 'Slice'
        
    % Set window name    
        oldName=get(imlook4d_current_handle,'Name')
        set(tempHandle,'Name', [oldName ' (Frame' num2str(imlook4d_frame) ')' ]);    
% 
% PROCESS
%
    % Reformat data (place slice in frame dimension)
        imlook4d_Cdata=reshape(data,size(data,1),size(data,2),1,size(data,3));
        disp( size(imlook4d_Cdata) );

    % Put data in new imlook4d
        imlook4d('importFromWorkspace_Callback', tempHandle,{},tempHandles);        % Import from workspace

    
%   
% FINALIZE
%
    clear tempHandle tempHandles
    
    
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
