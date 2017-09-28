% Duplicate.m
%
% Duplicate imlook4d instance (as stored in imlook4d_current_handle)
%
% newHandle is handle to new imlook4d instance
% newHandles are handles

%
% INITIALIZE
%
     disp('SCRIPTS/Duplicate.m entered');
     
     imlook4d_current_handles=guidata(imlook4d_current_handle);

     % Create imlook4d
     newHandle=imlook4d(imlook4d_current_handles.image.Cdata);  % Create new imlook4d instance with image matrix only
     newHandles=guidata(newHandle);                             % Get handles
     
     % Copy handles.image
     newHandles.image=imlook4d_current_handles.image;           
     
     % Copy handles.record
     newHandles.record=imlook4d_current_handles.record;   
     
     % Copy handles.model
     newHandles.model=imlook4d_current_handles.model;           
     
     % Copy ROI names
     set(newHandles.ROINumberMenu,'String',...
         get(imlook4d_current_handles.ROINumberMenu,'String') ...
         );
     
     % Copy Orientation (Ax,Cor,Sag) to GUI
     set(newHandles.orientationMenu,'Value',get(imlook4d_current_handles.orientationMenu,'Value') );  
     
     % Copy settings from first GUI
        set(newHandles.SliceNumSlider,'Value',get(imlook4d_current_handles.SliceNumSlider,'Value') );  
        set(newHandles.FrameNumSlider,'Value',get(imlook4d_current_handles.FrameNumSlider,'Value') );  
        set(newHandles.ROINumberMenu,'Value',get(imlook4d_current_handles.ROINumberMenu,'Value') );  
     % Copy window title
         set(newHandle, 'Name', ...
             get(imlook4d_current_handle,'Name') ...
             );   
         
      % Set colorscale according to modality
        imlook4d('imlook4d_set_colorscale_from_modality', newHandle,{},newHandles);% Call function
        
      % Set y-direction as in original
      set(newHandles.axes1, 'YDir', get( imlook4d_current_handles.axes1,'YDir'));   

 %   
 % FINALIZE
 %
 
    %Save modified handles    
    guidata(newHandle, newHandles);
    
    
    
    clear tempHandle tempHandles
