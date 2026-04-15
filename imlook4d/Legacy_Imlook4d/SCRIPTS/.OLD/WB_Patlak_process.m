%WB_Patlak_process.m
%
% PROCESS
%    

    % TACT curves
        handles1=guidata(handle1);  % Populate from handle, so that new ROI is added
        handles2=guidata(handle2);  % Populate from handle, so that new ROI is added
        [activity1, NPixels1, stdev1]=generateTACT(handles1, handles1.image.ROI);
        [activity2, NPixels2, stdev2]=generateTACT(handles2, handles2.image.ROI);
   
    %
    % Times
    %
        % Scan 1 start time
        mode=handles1.image.dirtyDICOMMode;
        temp=dirtyDICOMHeaderData(handles1.image.dirtyDICOMHeader, 1, '0008', '0031',mode); 
        startTime=temp.string;
        startTimeInSeconds1=str2num(startTime(1:2))*3600 + str2num(startTime(3:4))*60 + str2num(startTime(5:6));
        
        % Scan 2 start time
        temp=dirtyDICOMHeaderData(handles2.image.dirtyDICOMHeader, 1, '0008', '0031',mode); 
        startTime=temp.string;
        startTimeInSeconds2=str2num(startTime(1:2))*3600 + str2num(startTime(3:4))*60 + str2num(startTime(5:6));
        
        % Time shift between scan 1 and scan 2
        decayTime=startTimeInSeconds2-startTimeInSeconds1;
        
    %   
    % Decay correct
    %
        halflife=handles1.image.halflife;
        decayFactor=2^(-decayTime/halflife);
        activity1=activity1*decayFactor;        % Decay correct from scan 1 to scan 2
        
        disp(' '); disp(['Decay correct scan 1 to time of scan 2']);
        disp(['   (Time between scan starts=' num2str(decayTime) ...
            ' [s]   HalfLife=' num2str(halflife) ...
            ' [s]   decayFactor=' num2str(decayFactor) ')']);
        
    %   
    % Area 1:  Integral of blood curve over whole first scan
    %
        duration=handles1.image.duration;
        scan1_integral=0;
        scan1_length=0;
        
        for i=1:length(activity1) 
            % integral{C(a)}, over whole scan
            scan1_integral=scan1_integral+activity1(i)*duration(i);   % Counts= C(a)*duration
            scan1_length=scan1_length+duration(i);
        end

    %    
    % Area 2:  Area under curve between scans
    %    
    
        % Length between end of scan 1 and start of scan 2
        pauseTimeBetweenScans=startTimeInSeconds2 - (startTimeInSeconds1+scan1_length );
        
        % The area under curve between scan1_end and scan2_start
        areaBetweenScans=( activity1(end)-activity2(1) )/2 * pauseTimeBetweenScans;
        
    %
    % Patlak offset
    %
        patlakIntegralOffset=scan1_integral + areaBetweenScans;
        

% FINALIZE
% 
    % Set Patlak parameters
    handles2.model.Patlak.integralOffset=patlakIntegralOffset;
    handles2.model.Patlak.startFrame=1;
    handles2.model.Patlak.endFrame=length(activity2);
    handles2.model.Patlak.type='slope';
    handles2.model.Patlak.referenceData=activity2;
    
    handles2.model.functionHandle='@patlak';  % set Patlak model
    
    % Update
    guidata(handle2,handles2);
    set(handle2, 'Visible', 'on');  % Move window to top