% Threshold.m
%
% SCRIPT for imlook4d to obtain ROI from pixels above threshold.
%
% Pixels in the currently selected frame are compared to the threshold.
%
% Threshold is specified in percent of maximum in each slice.
%
% 
%
%
% Jan Axelsson

% INITIALIZE

    %  imlook4d_current_handles is updated whenever SCRIPTS menu in imlook4d is
    %  selected
    %disp('SCRIPTS/Threshold.m entered');
    
    
    % Export to workspace
    StoreVariables
    Export
    
    % Calculate max level in current frame (if not defined outside the script)
    if ( ~exist('maxLevel') )
        maxLevel=max(reshape(imlook4d_Cdata(:,:,:,imlook4d_frame), 1,size(imlook4d_Cdata,1)*size(imlook4d_Cdata,2)*size(imlook4d_Cdata,3)  ) );
    end
    
    % Get user input
    prompt={'Max value(for instance 12345  or 40%)',...
                'Threshold level (for instance 12345  or 40%)',...
                'First slice',...
                'Last slice (number or "end")'};
        title='Threshold levels';
        numlines=1;
    if ~exist('defaultanswer')  % If variable defaultanswer is not predefined outside script, set values
    	defaultanswer={'100%','40%', '1' , 'end'};
    end    
        

    answer=inputdlg(prompt,title,numlines,defaultanswer);
    answer(3:4)=makeAbsoluteSliceNumber(answer(3:4), imlook4d_slice, size(imlook4d_Cdata,3)); % Handle Relative or Absolute positions
        
    maxThresholdLevel=answer{1} ;
    minThresholdLevel=answer{2} ;
    firstSlice=str2num(answer{3});
    lastSlice=str2num(answer{4});
    % Handle if lastSlice='end'
    if strcmp('end', strtrim(answer{4}) )
        lastSlice=size(imlook4d_Cdata,3)
    end

    activeROI=get(imlook4d_current_handles.ROINumberMenu,'Value');


% 
% PROCESS
%
    newROI=zeros(size(imlook4d_ROI),'uint8');
    
    % Define pixels in new ROI
    for i=firstSlice:lastSlice
        
        % Get temporary image, and threshold levels
        temp=imlook4d_Cdata(:,:,i,imlook4d_frame);                   % Current Image, defined by current slice and frame
%         currentThreshold=0.01*thresholdLevelInPercent*max(temp(:) ); % Threshold of current image
%         
%         % New ROI
%         newROI(:,:,i)=  int8( activeROI*(temp>currentThreshold )) ;    % new ROI  

%     
%         % Assume absolute threshold values 
%             currentMaxThresholdLevel=maxThresholdLevel;
%             currentMinThresholdLevel=minThresholdLevel;

        % If percent threshold,  calculate threshold value (as percent of max in this frame)
            
            
            if strcmp( maxThresholdLevel(end), '%')
                currentMaxThresholdLevel=0.01*maxLevel * str2num(maxThresholdLevel(1:end-1)) ;
            else
                currentMaxThresholdLevel=  eval(maxThresholdLevel) ;  % If not percent, then whole string is a number
            end
            
            if strcmp( minThresholdLevel(end), '%')
                currentMinThresholdLevel=0.01*maxLevel * str2num(minThresholdLevel(1:end-1)) ;
            else
                currentMinThresholdLevel= eval(minThresholdLevel) ;
                %currentMinThresholdLevel= ( eval( minThresholdLevel) );
            end
             
        % New ROI (new algorithm)
            newROI(:,:,i)=  uint8( activeROI*( (temp>currentMinThresholdLevel) & (temp<=currentMaxThresholdLevel) ) ) ;       
        
    end
    
    % Add pixels to new ROI
    imlook4d_ROI=imlook4d_ROI - uint8(newROI>0).*imlook4d_ROI ;   % Remove existing ROI pixels that overlap new ROI
    imlook4d_ROI=imlook4d_ROI + uint8(newROI>0).*newROI;          % Add new ROI pixels
    
 

%   
% FINALIZE
%
       
    % Import into imlook4d from Workspace
   % imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles); % Import from workspace to current imlook4d instance
    %ImportUntouched
    Import % Adds ROI to handles in import function


    
    % Clear 
   clear i title  prompt  numlines  defaultanswer  answer  thresholdLevelInPercent  firstSlice  lastSlice  
   clear activeROI  newROI  temp  currentThreshold
   clear currentMaxThresholdLevel currentMinThresholdLevel maxLevel maxThresholdLevel minThresholdLevel
   
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
