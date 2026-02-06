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
StartScript;
    %  imlook4d_current_handles is updated whenever SCRIPTS menu in imlook4d is
    %  selected
    disp('SCRIPTS/SumFrames.m entered');
   
    % Export to workspace
    imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace

    % Get user input
    prompt={'First frame to sum',...
                'Last frame to sum'};
        title='Sum frames';
        numlines=1;
        defaultanswer={'1',num2str(size(imlook4d_Cdata,4))};
        %defaultanswer={har( mainHeader(296+1:296+32))',...
        %        char( mainHeader(434+1:434+10))'};
        answer=inputdlg(prompt,title,numlines,defaultanswer);


   % Set constants
        numberOfSlices=size(imlook4d_Cdata,3);
        
% 
% PROCESS
%
    % Reformat data (sum frames) 
        range=str2num(answer{1}):str2num(answer{2});
        summedData=zeros(size(imlook4d_Cdata,1),size(imlook4d_Cdata,2),size(imlook4d_Cdata,3));
       
        
        try
            startTime=imlook4d_time(range(1));
            time=imlook4d_time;
            duration=imlook4d_duration;
            disp(['SCRIPTS/SumFrames startTime=' num2str(startTime)]);
        catch
            % Set times and duration to 1
            duration=ones(size(imlook4d_Cdata,4));
            time=duration;  % 
        end
        
        % If duration not set, set it to 1
%         if sum(max(duration)) == 0
%             duration=ones(size(imlook4d_Cdata,4));
%             time=duration;  % 
%         end

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
        

        %summedData=zeros(size(Data,1), size(Data,2),size(Data,3));

        % Sum frames over range
        Data=imlook4d_Cdata;
        
        try 
            halflife=imlook4d_current_handles.image.halflife;
        catch
            halflife=1;
        end

        try                                         
           disp('Summing Method 4');
           summedDuration=0;
           
           % Sum in loop
           for j=range
               if (halflife==1)
                    % Data is not decay corrected - leave as is!
               else
                    Data(:,:,:,j)=Data(:,:,:,j)*(2^(-( time(j) +0.5*duration(j)) /halflife));  % Undo decay-correction to start of scan
               end
                %Data(:,:,:,j)=Data(:,:,:,j)*(2^(-( time(j) +0.0*duration(j)) /halflife));  % Undo decay-correction
                summedData=summedData+Data(:,:,:,j)*duration(j); 
                summedDuration=summedDuration+duration(j);
                disp(j);
           end
            
           if (halflife==1)
                % Data is not decay corrected - leave as is!
                DecayCorrectionFactor=1;
           else
                DecayCorrectionFactor=2^(( time(range(1))+ 0.5*summedDuration)/halflife);
           end
           disp(['DecayCorrectionFactor = ' num2str(DecayCorrectionFactor) ]);
           
           summedData=summedData/summedDuration;  % summedData is now mean value in mid frame
           summedData=summedData*DecayCorrectionFactor;   %Decay corrected summedData
            
           imlook4d_Cdata=Data;
        catch
            disp(['SUM ERROR - Try summing directly, ignoring frame time and halflifes' ]);
            summedData=sum(Data,4)/size(Data,4);
            
        end

    % If DICOM, update headers  
    try
        imlook4d_current_handles.image=truncateDICOM(imlook4d_current_handles.image, 1:numberOfSlices, 1); % Use return range for slices and frames (=1)
    catch
    end

    % If ECAT, update headers (Using header times)
        try
            % put first selected subheader into first subheader
                %imlook4d_current_handles.image.subHeader=imlook4d_current_handles.image.subHeader(:,range(1));
            
            % Make static
                %byte=328;length=2;imlook4d_current_handles.image.mainHeader(byte+1:byte+length)=[0 3]; % Set static mode
                %byte=354;length=2;imlook4d_current_handles.image.mainHeader(byte+1:byte+length)=[0 1]; % Set 1 frame
                %imlook4d_current_handles.image.ECATDirStruct(9:end)=0; % Make directory structure reflect one frame
            
            % Calculate times for new frame
                startTime=ECAT_readHeaderInt4(imlook4d_current_handles.image.subHeader(:,range(1)), 50);
                disp(['SCRIPTS/SumFrames ECAT header startTime=' num2str(startTime)]);
                endTime=ECAT_readHeaderInt4(imlook4d_current_handles.image.subHeader(:,range(end)), 50)+ECAT_readHeaderInt4(imlook4d_current_handles.image.subHeader(:,range(end)), 46);
                summedFrameDuration=endTime-startTime;
                disp(['SCRIPTS/SumFrames ECAT header duration=' num2str(summedFrameDuration)]);
                
           % Start time for summed frame
                byte=50;length=4;imlook4d_current_handles.image.subHeader(byte+1:byte+length, 1)=imlook4d_current_handles.image.subHeader(byte+1:byte+length, range(1)); % Copy from first frame in range
                
           % Duration of summed frame
                hexValue=uint32_to_hex(summedFrameDuration);    % Time in hexadecimal notation
                byte=46;length=1;imlook4d_current_handles.image.subHeader(byte+1:byte+length, 1)=hex_to_uint8( hexValue(1:2) ); % Write each byte
                byte=byte+1;imlook4d_current_handles.image.subHeader(byte+1:byte+length, 1)=hex_to_uint8( hexValue(3:4) );
                byte=byte+1;imlook4d_current_handles.image.subHeader(byte+1:byte+length, 1)=hex_to_uint8( hexValue(5:6) );
                byte=byte+1;imlook4d_current_handles.image.subHeader(byte+1:byte+length, 1)=hex_to_uint8( hexValue(7:8) );
                
                disp(['SCRIPTS/SumFrames ECAT header Frame start time=' num2str( ECAT_readHeaderInt4(imlook4d_current_handles.image.subHeader(:,1), 50)  ) 'ms']);
                disp(['SCRIPTS/SumFrames ECAT header Frame duration=' num2str( ECAT_readHeaderInt4(imlook4d_current_handles.image.subHeader(:,1), 46)  ) 'ms']);

        catch
            disp('SCRIPTS/SumFrames WARNING:  Not ECAT data');
        end
                
    % Update frame times (if existing)
        try
             imlook4d_time=imlook4d_time(range(1));
             imlook4d_duration=summedDuration
        catch
        end
        
    % Import into imlook4d
        imlook4d_Cdata=summedData;
        imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles); % Import from workspace to current imlook4d instance


        
    %   
    % FINALIZE
    %
    
            
        % Set window name    
            oldName=get(imlook4d_current_handle,'Name');
            set(imlook4d_current_handle,'Name', [oldName ' (Sum frames' answer{1} '-' answer{2} ')' ]); 
            
        % Clear variables created by this script. 
        % Find this list by "clear all" before running script.  Then: 
        %   1) removing imlook4d* by using: clear imlook4d*
        %   2) list remaining variables using who 
%         clear range Data title
%         
%         clear DecayCorrectionFactor     hexValue                  prompt     ...               
%             answer                    startTime        ...         
%             byte                      summedData          ...      
%             defaultanswer             j                         summedDuration         ...   
%             duration                  length                    summedFrameDuration       ...
%             endTime                   numlines                  time                      ...
%             halflife                  oldName
EndScript

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
