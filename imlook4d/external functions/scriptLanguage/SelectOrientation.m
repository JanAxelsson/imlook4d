function SelectOrientation( number)
% SelectOrientation(string)
%
% Select an orientation in current imlook4d instance
%
% The input can be either:
% - number, for instance: 2
% - name, for instance: 'Cor'


% Import from workspace
 try  
     imlook4d_current_handle=evalin('base', 'imlook4d_current_handle');
 catch
     warning('failed importing imlook4d_imlook4d_current_handle');
     return
 end;


 
% Get handles 
imlook4d_current_handles=guidata(imlook4d_current_handle);

 % Alt 1) Find Orientation from name
 if ischar(number)
     try
         names = get(imlook4d_current_handles.orientationMenu,'String');
         indexC = strcmp( names, number);
         index = find(indexC==1);
     catch
         warning(['SelectOrientation did not find string = ' number ]);
     end
 end

 
 % Al 2) Find Orientation from number
 if isnumeric(number)
    index=number; 
 end 
 
 
 % Bail out if Orientation was not found
 if isempty(index)
      warning(['SelectOrientation did not find string = ' number ]);  
      return
 end
 
 
% Set Orientation if index within range of existing ROIs 
     try
         last = size( get(imlook4d_current_handles.ROINumberMenu,'String'),1 ) - 1;
         if ( index >= 1) & ( index <= last)  
            % Set menu to selected ROI
            set(imlook4d_current_handles.orientationMenu,'Value',index)
            % Callback, updates imlook4d of change
            imlook4d('orientationMenu_Callback', imlook4d_current_handles.orientationMenu,{},imlook4d_current_handles);  % Create ROI with name from string variable
         else
            warning(['SelectOrientation index = ' num2str( index ) '.  Should be between 1 and ' num2str(lastROI) ]);
         end
     catch
         disp('useage:');
         help SelectOrientation( number)
     end
 end


