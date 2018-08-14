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
%      
%      % Move window slightly offset to original
%      dx = 30;
%      dy = 30;
%      oldPos = get( imlook4d_current_handle, 'Position')
%      newPos = [ oldPos(1) + dx, oldPos(2) - dy, oldPos(3), oldPos(4) ];
%      set( newHandle, 'Position', newPos);
%      
     
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
     
     % Copy interpolation preferences
     set(newHandles.interpolate2,'Checked', get( imlook4d_current_handles.interpolate2, 'Checked') );
     set(newHandles.interpolate4,'Checked', get( imlook4d_current_handles.interpolate4, 'Checked') );
     
     % Copy sliders from first GUI
         set(newHandles.SliceNumSlider,'Value',get(imlook4d_current_handles.SliceNumSlider,'Value') );  
         set(newHandles.FrameNumSlider,'Value',get(imlook4d_current_handles.FrameNumSlider,'Value') );   
        set(newHandles.ROINumberMenu,'Value',get(imlook4d_current_handles.ROINumberMenu,'Value') );  
        
     % Copy window title
         set(newHandle, 'Name', ...
             get(imlook4d_current_handle,'Name') ...
             );   
         
      % Set colorscale according to modality
        % imlook4d('imlook4d_set_colorscale_from_modality', newHandle,{},newHandles);% Call function
      
        
      % Set y-direction as in original
      set(newHandles.axes1, 'YDir', get( imlook4d_current_handles.axes1,'YDir'));   
    

 %   
 % Set GUI-component same as original
 %
        
    % Copy colorscale
    newHandles.image.ColormapName = imlook4d_current_handles.image.ColormapName;
    imlook4d('Color',newHandle, {}, newHandles,newHandles.image.ColormapName );
     
    % Copy window levels 
    limits = get(imlook4d_current_handles.ColorBar,'Limits');
    INPUTS = Parameters( { num2str(limits(1)), num2str(limits(2))} );
    Menu('Edit scale');
    
    % Copy radiobuttons
    style = 'radiobutton';
    HmatchOld = findobj(imlook4d_current_handle,'Style',style);
    HmatchNew = findobj(newHandle,'Style',style);
    for i = 1: length(HmatchOld)
       set( HmatchNew(i), 'Value',  get( HmatchOld(i), 'Value') );
    end
    
    % Copy checkboxes
    style = 'checkbox';
    HmatchOld = findobj(imlook4d_current_handle,'Style',style);
    HmatchNew = findobj(newHandle,'Style',style);
    for i = 1: length(HmatchOld)
       set( HmatchNew(i), 'Value',  get( HmatchOld(i), 'Value') );
    end
    
    % Copy checkboxes
    style = 'edit';
    HmatchOld = findobj(imlook4d_current_handle,'Style',style);
    HmatchNew = findobj(newHandle,'Style',style);
    for i = 1: length(HmatchOld)
       set( HmatchNew(i), 'String',  get( HmatchOld(i), 'String') );
    end


 %   
 % FINALIZE
 %     
    %Save modified handles    
     guidata(newHandle, newHandles);
     
     imlook4d('updateImage',newHandle, {}, newHandles);
    
    clear tempHandle tempHandles
