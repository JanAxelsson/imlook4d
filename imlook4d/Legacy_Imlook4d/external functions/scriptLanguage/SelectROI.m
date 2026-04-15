function SelectROI( number)
% SelectROI(string)
%
% Select a roi in current imlook4d instance
%
% The input can be either:
% - ROI number, for instance: 2
% - ROI name, for instance: 'ROI 2'


% Import from workspace
 try  
     imlook4d_current_handle=evalin('base', 'imlook4d_current_handle');
 catch
     warning('failed importing imlook4d_imlook4d_current_handle');
     return
 end;
 
% Get handles 
imlook4d_current_handles=guidata(imlook4d_current_handle);

 % Alt 1) Find ROI from name
 if ischar(number)
     try
         names = get(imlook4d_current_handles.ROINumberMenu,'String');
         indexC = strcmp( names, number);
         index = find(indexC==1);
     catch
         warning(['SelectROI did not find string = ' number ]);
     end
 end

 
 % Al 2) Find ROI from number
 if isnumeric(number)
    index=number; 
 end 
 
 
 % Bail out if ROI was not found
 if isempty(index)
      warning(['SelectROI did not find string = ' number ]);  
      return
 end
 
 
% Set ROI if index within range of existing ROIs 
     try
         lastROI = size( get(imlook4d_current_handles.ROINumberMenu,'String'),1 ) - 1;
         if ( index >= 1) & ( index <= lastROI)  
            % Set menu to selected ROI
            set(imlook4d_current_handles.ROINumberMenu,'Value',index)
            % Callback, updates imlook4d of change
            imlook4d('ROINumberMenu_Callback', imlook4d_current_handles.ROINumberMenu,{},imlook4d_current_handles);  % Create ROI with name from string variable
         else
            warning(['SelectROI index = ' num2str( index ) '.  Should be between 1 and ' num2str(lastROI) ]);
         end
     catch
         disp('useage:');
         help SelectROI( number)
     end
 end


