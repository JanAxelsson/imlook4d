% Fill_Hole.m
%
% SCRIPT for imlook4d to Fill hole in ROI .
%
%
% Inputs :
% - output ROI number, "new" or "current"
%
%
% Jan Axelsson



if (~areTheseToolboxesInstalled({'Image Processing Toolbox'}) )
    warndlg('Missing the required toolbox:  Image Processing Toolbox');
    return
end



% INITIALIZE

    %  imlook4d_current_handles is updated whenever SCRIPTS menu in imlook4d is
    %  selected
        
    % Export to workspace
    StoreVariables
    Export
    % Read default if exists, or apply these as default
    defaultanswer = RetriveEarlierValues('Fill', {'new', '15'} ); 
    
  
    
    % Get user input
    prompt={'Output ROI (number or "new" or "current")', 'Filter size (pixels)'};
        title='Fill ROI hole';
        numlines=1;
    answer=inputdlg(prompt,title,numlines,defaultanswer);
    if isempty(answer)  % cancelled inputdlg and clean up
        ClearVariables
        return
    end

    activeROI = get(imlook4d_current_handles.ROINumberMenu,'Value');
    outputROI = str2num(answer{1});
    filterSize = str2num(answer{2});

    % outputROI ='new'
    if strcmp('new', strtrim(answer{1}) )
        outputROI = length(imlook4d_ROINames); % After last
        
        newROIName = [ 'Inside ' imlook4d_ROINames{imlook4d_ROI_number} ];
        INPUTS = Parameters( {newROIName} );
        MakeROI
    end

    % outputROI='current'
    if strcmp('current', strtrim(answer{1}) )
        outputROI = activeROI;
    end
    
    % Store answer as new dialog default
    StoreValues('Fill', answer ); 

% 
% PROCESS
%

    zRange = find( sum(imlook4d_ROI,[1 2]) > 0 ); %% Look only in z where ROI exists

    newROI=zeros(size(imlook4d_ROI),'uint8');
    
    % Add pixels in new ROI
    waitBar = waitbar(0, 'Starting');
    i=0;
    N = max(zRange) - min(zRange);
    for iz = min(zRange):max(zRange)
        
        mask = imlook4d_ROI(:,:,iz) == activeROI ;
        
        se = strel('disk', filterSize, 0);
        newMask = imclose(mask, se);
        newMask = imfill(newMask, 'holes'); % Will contain original ROI (mask)
        newMask( mask == 1) = 0; % Remove original ROI (mask) from newMask
        
        newROI(:,:,iz) = newMask * outputROI;  
        
        i = i + 1;
        waitbar( i/N, waitBar, 'Filling holes');
        
    end
    close(waitBar)
    
    
    
    % Make matrix of locked pixels
    lockedMatrix = zeros( size(imlook4d_ROI) ,'logical'); % Assume all locked
    numberOfROIs = length( imlook4d_current_handles.image.LockedROIs );
    for i=1:numberOfROIs
        lockedMatrix(imlook4d_ROI == i ) = imlook4d_current_handles.image.LockedROIs(i); % Pixels = 0 if locked, 1 if not locked
    end
    
    newROI( lockedMatrix) = 0; % Remove pixels that are locked from newROI
    
    
%     % Add pixels to new ROI
    imlook4d_ROI=imlook4d_ROI - uint8(newROI>0).*imlook4d_ROI ;   % Remove existing ROI pixels that overlap new ROI
    imlook4d_ROI=imlook4d_ROI + uint8(newROI>0).*newROI;          % Add new ROI pixels

%   
% FINALIZE
%
       
    % Import into imlook4d from Workspace
   % imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles); % Import from workspace to current imlook4d instance
    ImportUntouched
    %Import % Adds ROI to handles in import function

    % Store default until next tim
    %imlook4d_store.Threshold.inputs =  answer;
   
   ClearVariables
    %disp('SCRIPTS/Threshold.m DONE');

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
