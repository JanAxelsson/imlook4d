function newHandle=duplicateImlook4d(imlook4d_current_handle)
%
% Duplicate imlook4d instance
%
% Input:   imlook4d_current_handle  handle to the imlook4d instance we want to copy
% Output:  newHandle                handle to new instance

%
% INITIALIZE
%

     %disp('SCRIPTS/Duplicate.m entered');

     % Create imlook4d
     imlook4d_current_handles=guidata(imlook4d_current_handle);
     newHandle=imlook4d(imlook4d_current_handles.image.Cdata);  % Create new imlook4d instance with image matrix only
     newHandles=guidata(newHandle);                             % Get handles
     
     % Copy handles.image
     newHandles.image=imlook4d_current_handles.image;           
     
     % Copy handles.model
     newHandles.model=imlook4d_current_handles.model;           
     
     % Copy ROI names
     set(newHandles.ROINumberMenu,'String',...
         get(imlook4d_current_handles.ROINumberMenu,'String') ...
         );
     
     % Copy window title
         set(newHandle, 'Name', ...
             get(imlook4d_current_handle,'Name') ...
             );   
         
      % Set colorscale according to modality
       imlook4d('imlook4d_set_colorscale', newHandle,{},newHandles);% Call function

       %imlook4d('updateImage', newHandle, [], newHandles);  % Update image
       %imlook4d('drawROI', newHandle, [], newHandles);  % Update image
       

 %   
 % FINALIZE
 %
 
    %Save modified handles    
    guidata(newHandle, newHandles);
    
    
    
    %clear tempHandle tempHandles
