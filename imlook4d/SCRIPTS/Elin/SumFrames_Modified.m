% SumFrames.m
%
% This script sums frames with decay correction applied, 
% so that the summed frame is equivalent to the frame a long acquisition would get.
%
% For ECAT the headers are updated for start time and duration.
% This is not the case for DICOM.
%
%
% SCRIPT for imlook4d
% Jan Axelsson

% INITIALIZE

    %  imlook4d_current_handles is updated whenever SCRIPTS menu in imlook4d is
    %  selected
    disp('SCRIPTS/SumFrames.m entered');
   
    % Export to workspace
    imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace

    % Get user input
    prompt={'Number of frames to sum'};
        title='Sum frames';
        numlines=1;
        defaultanswer={'2'};
        %defaultanswer={har( mainHeader(296+1:296+32))',...
        %        char( mainHeader(434+1:434+10))'};
        answer=inputdlg(prompt,title,numlines,defaultanswer);


% 
% PROCESS
%
    % Reformat data (sum frames) 
        no_frames=size(imlook4d_Cdata, 4)/str2num(answer{1});
        sumed_frames=str2num(answer{1});
        summedData=zeros(size(imlook4d_Cdata,1),size(imlook4d_Cdata,2),size(imlook4d_Cdata,3), no_frames);
        
        startTime=imlook4d_time(1);
        disp(['SCRIPTS/SumFrames startTime=' num2str(startTime)]);

%         try                     
%            %  Integrate decay-corrected data 
% 
%            summedDuration=0;
%            for j=range
%                 summedData=summedData+imlook4d_Cdata(:,:,:,j)*imlook4d_duration(j);
%                 summedDuration=summedDuration+imlook4d_duration(j);
%                 %disp(j);
%             end
%             summedData=summedData/summedDuration;
%             disp(['SCRIPTS/SumFrames duration=' num2str(summedDuration)]);
% 
%         catch
%             disp(['SUM ERROR']);
%         end

        
        % SUM FRAMES
        
        time=imlook4d_time;
        duration=imlook4d_duration;
        
        %summedData=zeros(size(Data,1), size(Data,2),size(Data,3));

        % Sum frames over range
        Data=imlook4d_Cdata;
        
        halflife=imlook4d_current_handles.image.halflife;
        
                                        
           disp('Summing Method 4');
           summedDuration=zeros(1, no_frames);
           DecayCorrectionFactor=zeros(1, no_frames);
           for k=1:size(Data, 4)
               for l = 1:sumed_frames
                   for j=1:sumed_frames
                        Data(:,:,:,k)=Data(:,:,:,k)*(2^(-( time +0.5*duration(k)) /halflife));  % Undo decay-correction to start of scan OBS! SE ÖVER TIDEN!
                        %Data(:,:,:,j)=Data(:,:,:,j)*(2^(-( time(j) +0.0*duration(j)) /halflife));  % Undo decay-correction
                        summedData(:, :, :, l)=summedData(:, :, :, l)+Data(:,:,:,j)*duration(j); 
                        summedDuration(l)=summedDuration(l)+duration(j);
                        summedData(:, :, :, l)=summedData(:, :, :, l)/summedDuration(l);  % summedData is now mean value in mid frame
                        DecayCorrectionFactor(l)=2^(( time+ 0.5*summedDuration(l))/halflife); %OBS! SE ÖVER TIDEN
                        summedData(:, :, :, l)=summedData(:, :, :, l)*DecayCorrectionFactor(l);   %Decay corrected summedData
                   end
               end
            

            
           end
            
            


        
        

%     % If ECAT, update headers (Using header times)
%         try
%             % put first selected subheader into first subheader
%                 %imlook4d_current_handles.image.subHeader=imlook4d_current_handles.image.subHeader(:,range(1));
%             
%             % Make static
%                 %byte=328;length=2;imlook4d_current_handles.image.mainHeader(byte+1:byte+length)=[0 3]; % Set static mode
%                 %byte=354;length=2;imlook4d_current_handles.image.mainHeader(byte+1:byte+length)=[0 1]; % Set 1 frame
%                 %imlook4d_current_handles.image.ECATDirStruct(9:end)=0; % Make directory structure reflect one frame
%             
%             % Calculate times for new frame
%                 startTime=ECAT_readHeaderInt4(imlook4d_current_handles.image.subHeader(:,range(1)), 50);
%                 disp(['SCRIPTS/SumFrames ECAT header startTime=' num2str(startTime)]);
%                 endTime=ECAT_readHeaderInt4(imlook4d_current_handles.image.subHeader(:,range(end)), 50)+ECAT_readHeaderInt4(imlook4d_current_handles.image.subHeader(:,range(end)), 46);
%                 summedFrameDuration=endTime-startTime;
%                 disp(['SCRIPTS/SumFrames ECAT header duration=' num2str(summedFrameDuration)]);
%                 
%            % Start time for summed frame
%                 byte=50;length=4;imlook4d_current_handles.image.subHeader(byte+1:byte+length, 1)=imlook4d_current_handles.image.subHeader(byte+1:byte+length, range(1)); % Copy from first frame in range
%                 
%            % Duration of summed frame
%                 hexValue=uint32_to_hex(summedFrameDuration);    % Time in hexadecimal notation
%                 byte=46;length=1;imlook4d_current_handles.image.subHeader(byte+1:byte+length, 1)=hex_to_uint8( hexValue(1:2) ); % Write each byte
%                 byte=byte+1;imlook4d_current_handles.image.subHeader(byte+1:byte+length, 1)=hex_to_uint8( hexValue(3:4) );
%                 byte=byte+1;imlook4d_current_handles.image.subHeader(byte+1:byte+length, 1)=hex_to_uint8( hexValue(5:6) );
%                 byte=byte+1;imlook4d_current_handles.image.subHeader(byte+1:byte+length, 1)=hex_to_uint8( hexValue(7:8) );
%                 
%                 disp(['SCRIPTS/SumFrames ECAT header Frame start time=' num2str( ECAT_readHeaderInt4(imlook4d_current_handles.image.subHeader(:,1), 50)  ) 'ms']);
%                 disp(['SCRIPTS/SumFrames ECAT header Frame duration=' num2str( ECAT_readHeaderInt4(imlook4d_current_handles.image.subHeader(:,1), 46)  ) 'ms']);
% 
%         catch
%             disp('SCRIPTS/SumFrames WARNING:  Not ECAT data');
%         end
                
    % Update frame times
        imlook4d_time=imlook4d_time(1);
        imlook4d_duration=summedDuration;
        
    % Import into imlook4d
        imlook4d_Cdata=summedData;
        imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles); % Import from workspace to current imlook4d instance


        
    %   
    % FINALIZE
    %
    
            
        % Set window name    
            oldName=get(imlook4d_current_handle,'Name');
            set(imlook4d_current_handle,'Name', [oldName ' (Sum frames)' ]); 
            
        % Clear variables created by this script. 
        % Find this list by "clear all" before running script.  Then: 
        %   1) removing imlook4d* by using: clear imlook4d*
        %   2) list remaining variables using who 
        clear Data title
        
        clear DecayCorrectionFactor     hexValue                  prompt     ...               
            answer                    startTime        ...         
            byte                      summedData          ...      
            defaultanswer             j                         summedDuration         ...   
            duration                  length                    summedFrameDuration       ...
            endTime                   numlines                  time                      ...
            halflife                  oldName

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
