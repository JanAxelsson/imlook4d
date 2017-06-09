% WB_Patlak.m
%
% SCRIPT for setting up imlook4d for WB Patlak
%
% This script takes two scans:
% 1) a dynamic scan 
% 2) a number of WB scans 
% and prepares for PATLAK parametric imaging on the dynamic WB
%
% The theory is to calculate the area under the blood curve until start of scan 2).  
% This becomes an offset which will be added to the blood integral, used for Patlak x-axis.
% The data is decay-corrected to start of scan 2.
%
% This script is prepared for HTML wizard, calling the script multiple times.
% A separate part of the scipt is executed, depending on the value of the variable "wizardStep" in the matlab workspace.
% This script is called when pressing "Continue" link in HTML.
%
% Jan Axelsson
% 2010-11-30

%
% INITIALIZE
%
    % Export to workspace
    %imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace
    %activeROI=get(imlook4d_current_handles.ROINumberMenu,'Value');
if ~exist('wizardStep')    
    wizardStep=1;
end

    
% ---------------------------------
% WIZARD (in combination with html)
% ---------------------------------

switch wizardStep
%
% INPUT
%
    case 1
    % PART 1 - OPEN dynamic heart file (scan 1)       
        displayHTML('', 'Step 1 - Dynamic WB', fileread('WB_Patlak_Step1.txt'), '');
        %disp(' ');reply = input(' INSTRUCTION - Select dynamic heart file (Press keyboard to continue)', 's');

        handle1=imlook4d; 
        handles1=guidata(handle1);
        wizardStep=wizardStep+1;

    case 2
    % PART 2 - Draw blood ROI in first scan
        hObject= handles1.ROINumberMenu;
        imlook4d('ROINumberMenu_Callback', hObject,{},handles1,'blood');  % Create ROI "named blood"

        %disp(' ');reply = input(' INSTRUCTION - Draw ROI in blood pool (Press keyboard to draw)', 's');
        set(handle1, 'Visible', 'on');  % Move window to top
        displayHTML('', 'Step 2 - Dynamic WB', fileread('WB_Patlak_Step2.txt'), '');
        wizardStep=wizardStep+1;

    case 3
    % PART 3 - OPEN dynamic WB (scan 2)
        %disp(' ');reply = input(' INSTRUCTION - Select dynamic WB (Press keyboard to continue)', 's');
        displayHTML('', 'Step 3 - Dynamic WB', fileread('WB_Patlak_Step3.txt'), '');

        imlook4d('OpenFile_Callback', handles1.OpenAndMerge,{},handles1)
        handle2=gcf; 
        handles2=guidata(handle2);   
        wizardStep=wizardStep+1; 

    case 4
    % PART 4 - Draw blood ROI in second scan
        hObject= handles2.ROINumberMenu;
        imlook4d('ROINumberMenu_Callback', hObject,{},handles2,'blood');  % Create ROI "named blood"

        %disp(' '); reply = input(' INSTRUCTION - Draw ROI in blood pool (Press keyboard to draw)', 's');
        displayHTML('', 'Step 4 - Dynamic WB', fileread('WB_Patlak_Step4.txt'), '');
        set(handle2, 'Visible', 'on');  % Move window to top
        wizardStep=wizardStep+1;
        mode1=handles1.image.dirtyDICOMMode;            % DICOM explicit/implicit mode
        mode2=handles2.image.dirtyDICOMMode;

%         %
%         % TEST - use ROI from previous scan
%         %
%         
%            
%             mode1=handles1.image.dirtyDICOMMode;            % DICOM explicit/implicit mode
%             mode2=handles2.image.dirtyDICOMMode;
%             sortedHeaders1=handles1.image.dirtyDICOMHeader; % DICOM header
%             sortedHeaders2=handles2.image.dirtyDICOMHeader;
%             sliceSpacing1=handles1.image.sliceSpacing;      % Slice spacings
%             sliceSpacing2=handles2.image.sliceSpacing;
%             numberOfSlices1=size(handles1.image.Cdata,3);   % Number of slices
%             numberOfSlices2=size(handles2.image.Cdata,3);
%             
%             % Find slice location of first slice in scan 1
%           
%                 out=dirtyDICOMHeaderData(sortedHeaders1, 1, '0020', '1041',mode1);
%                 location=out.string;location=[location '               '];
%                 location1=str2num( location(1:7) );
%         
%             % Determine slice index of same slice in scan 2
%                 
%                 foundIndex=0;  % Indicates that nothing has been found
%                 for i=1:numberOfSlices2
%                     out=dirtyDICOMHeaderData(sortedHeaders2, i, '0020', '1041',mode2);
%                     location=out.string;location=[location '               '];
%                     location2=str2num( location(1:7) );
%                     if abs(location2 - location1) < sliceSpacing2/2
%                         foundIndex=i;
%                         disp(['Found position of first scan in index i=' num2str(foundIndex) '  at location=' num2str(location2)] );
%                     end
%                 end
%                 
%             % Copy ROI
%                 handles2.image.ROI(:,:, foundIndex:foundIndex+numberOfSlices1-1)=handles1.image.ROI;
%                 guidata(handle2, handles2);

    case 5
%
% PROCESS
%    
    displayHTML('', 'Step 5 - Dynamic WB', fileread('WB_Patlak_Step5.txt'), '');
    % TACT curves
        disp('Calculating TACT curves');
        handles1=guidata(handle1);  % Populate from handle, so that new ROI is added
        handles2=guidata(handle2);  % Populate from handle, so that new ROI is added
        [activity1, NPixels1, stdev1]=generateTACT(handles1, handles1.image.ROI);
        [activity2, NPixels2, stdev2]=generateTACT(handles2, handles2.image.ROI);
   
    %
    % Times
    %
        disp('Calculating times');
        % Scan 1 start time
        temp=dirtyDICOMHeaderData(handles1.image.dirtyDICOMHeader, 1, '0008', '0031',mode1); 
        startTime=temp.string;
        startTimeInSeconds1=str2num(startTime(1:2))*3600 + str2num(startTime(3:4))*60 + str2num(startTime(5:6));
        
        % Scan 2 start time
        temp=dirtyDICOMHeaderData(handles2.image.dirtyDICOMHeader, 1, '0008', '0031',mode2); 
        startTime=temp.string;
        startTimeInSeconds2=str2num(startTime(1:2))*3600 + str2num(startTime(3:4))*60 + str2num(startTime(5:6));
        
        % Time shift between scan 1 and scan 2
        decayTime=startTimeInSeconds2-startTimeInSeconds1;
        
    %   
    % Decay correct
    %
        disp('Calculating decay correction factor for TACT curves of first scan');

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
        disp('Calculating area under blood curve (scan 1)');

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
        disp('Calculating area under blood curve (between scans)');   
    
        % Length between end of scan 1 and start of scan 2
        pauseTimeBetweenScans=startTimeInSeconds2 - (startTimeInSeconds1+scan1_length );
        
        % The area under curve between scan1_end and scan2_start
        areaBetweenScans=( activity1(end)-activity2(1) )/2 * pauseTimeBetweenScans;
        
    %
    % Patlak offset
    %
        patlakIntegralOffset=scan1_integral + areaBetweenScans;
        
%
% FINALIZE
% 
    disp('Setting Patlak model parameters');  
        
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
    
    % Show patlak control
    patlak_control(handle2)
    
    
    wizardStep=wizardStep+1;
    
case 6 
   clear wizardStep
   % clear verify1 i j prompt numlines defaultanswer answer filterHandle
   
otherwise
        disp('hej')
        wizardStep=1;    
end % switch statement
