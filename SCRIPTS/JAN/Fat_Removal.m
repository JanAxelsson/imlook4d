% Fat_Removal.m
%
% SCRIPT for removing fat pixels in PET
%
% This script takes two scans:
% 1) a CTAC with same number of slices as in PET
% 2) a PET 
% and removes the fat pixels
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
    % PART 1 - OPEN CTAC (scan 1)       
        displayHTML('', 'Step 1 - Open CTAC', fileread('Fat_Removal_Step1.txt'), '');
        %disp(' ');reply = input(' INSTRUCTION - Select dynamic heart file (Press keyboard to continue)', 's');

        imlook4d_current_handle=imlook4d; 
        imlook4d_current_handles=guidata(imlook4d_current_handle);
        wizardStep=wizardStep+1;

    case 2
    % PART 2 - Find fat pixels from CTAC
        hObject= imlook4d_current_handles.ROINumberMenu;
        imlook4d('ROINumberMenu_Callback', hObject,{},imlook4d_current_handles,'fat');  % Create ROI "named fat"
    
        displayHTML('', 'Step 2 - Dynamic WB', fileread('Fat_Removal_Step2.txt'), '');
            
        % Prepare open dialog
        defaultanswer={'0','-250', '1' , 'end'};
        
        % Threshold_ROI (operates on imlook4d_current_handles)
        Threshold_ROI
        
        % Save ROI definition
        imlook4d('SaveRoiPushbutton_Callback', imlook4d_current_handles.SaveROI,{} ,imlook4d_current_handles)
        
        
        set(imlook4d_current_handle, 'Visible', 'on');  % Move window to top
        wizardStep=wizardStep+1;

    case 3
    % PART 3 - OPEN PET scan (scan 2)
        displayHTML('', 'Step 3 - Open PET', fileread('Fat_Removal_Step3.txt'), '');

        imlook4d('OpenFile_Callback', imlook4d_current_handles.OpenFile,{} ,imlook4d_current_handles)
        handle2=gcf; 
        handles2=guidata(handle2);   
        wizardStep=wizardStep+1; 

    case 4
    % PART 4 - TO DO : write this 

case 5
   clear wizardStep
   % clear verify1 i j prompt numlines defaultanswer answer filterHandle
   
otherwise
        disp('hej')
        wizardStep=1;    
end % switch statement
