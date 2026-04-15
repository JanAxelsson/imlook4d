% RemoveFrames.m
%
% SCRIPT for imlook4d
% Jan Axelsson

% INITIALIZE

    %  imlook4d_current_handles is updated whenever SCRIPTS menu in imlook4d is
    %  selected
    disp('SCRIPTS/RemoveFrames.m entered');
   
    % Export to workspace
    imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace

    % Get user input
    prompt={'First frame to keep',...
                'Last frame to keep'};
        title='Remove frames';
        numlines=1;
        defaultanswer={'1',num2str(size(imlook4d_Cdata,4))};
        %defaultanswer={har( mainHeader(296+1:296+32))',...
        %        char( mainHeader(434+1:434+10))'};
        answer=inputdlg(prompt,title,numlines,defaultanswer);


% 
% PROCESS
%
    % Reformat data (remove frames) 
        range=str2num(answer{1}):str2num(answer{2});
        summedData=zeros(size(imlook4d_Cdata,1),size(imlook4d_Cdata,2),size(imlook4d_Cdata,3));
        
        startTime=imlook4d_time(range(1));
        endTime=imlook4d_time(range(2));
        disp(['SCRIPTS/RemoveFrames startTime=' num2str(startTime)]);
        disp(['SCRIPTS/RemoveFrames endTime=' num2str(endTime)]);
       
        imlook4d_Cdata=imlook4d_Cdata(:,:,:,range);
        imlook4d_duration=imlook4d_duration(range);
        imlook4d_time=imlook4d_time(range);

        

    % If ECAT, update headers (Using header times)
        try
                 byte=354;length=2;mainHeader(byte+1:byte+length)=[0 numberOfFrames]; % Set number of Frames

         %
         % Modify subheader times and durations
         %

            for i=1:numberOfFrames

                % Frame start time
                hexValue=uint32_to_hex(1000*handles.image.time(i));   % Time in hexadecimal notation
                byte=50;length=1;handles.image.subHeader(byte+1:byte+length, i)=hex_to_uint8( hexValue(1:2) ); % Write each byte
                byte=byte+1;handles.image.subHeader(byte+1:byte+length, i)=hex_to_uint8( hexValue(3:4) );
                byte=byte+1;handles.image.subHeader(byte+1:byte+length, i)=hex_to_uint8( hexValue(5:6) );
                byte=byte+1;handles.image.subHeader(byte+1:byte+length, i)=hex_to_uint8( hexValue(7:8) );         


                % Duration of summed frame
                hexValue=uint32_to_hex(1000*handles.image.duration(i));    % Time in hexadecimal notation
                byte=46;length=1;handles.image.subHeader(byte+1:byte+length, i)=hex_to_uint8( hexValue(1:2) ); % Write each byte
                byte=byte+1;handles.image.subHeader(byte+1:byte+length, i)=hex_to_uint8( hexValue(3:4) );
                byte=byte+1;handles.image.subHeader(byte+1:byte+length, i)=hex_to_uint8( hexValue(5:6) );
                byte=byte+1;handles.image.subHeader(byte+1:byte+length, i)=hex_to_uint8( hexValue(7:8) );

                disp(['ECAT subheader Frame start time=' num2str( ECAT_readHeaderInt4(handles.image.subHeader(:,i), 50)  ) 'ms']);
                disp(['ECAT subheader Frame duration=' num2str( ECAT_readHeaderInt4(handles.image.subHeader(:,i), 46)  ) 'ms']);
            end
        
        catch
            disp('SCRIPTS/RemoveFrames WARNING:  Not ECAT data');
        end

        
    % Import into imlook4d
        imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles); % Import from workspace to current imlook4d instance


        
    %   
    % FINALIZE
    %
    
            
        % Set window name    
            oldName=get(imlook4d_current_handle,'Name');
            set(imlook4d_current_handle,'Name', [oldName ' (Using frames' answer{1} '-' answer{2} ')' ]); 
            
        clear range Data

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
