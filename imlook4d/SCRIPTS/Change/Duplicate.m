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
    if get(imlook4d_current_handles.autoColorScaleRadioButton,'Value')==0 % auto color scale = off
        limits = get(imlook4d_current_handles.ColorBar,'Limits');
        %imlook4d('EditScale_Callback',imlook4d_current_handle, [], imlook4d_current_handles, limits(1), limits(2))
        imlook4d('EditScale_Callback',newHandle, [], newHandles, limits(1), limits(2))
    end
    
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
    
    % Copy edit fields
    style = 'edit';
    HmatchOld = findobj(imlook4d_current_handle,'Style',style);
    HmatchNew = findobj(newHandle,'Style',style);
    for i = 1: length(HmatchOld)
       set( HmatchNew(i), 'String',  get( HmatchOld(i), 'String') );
    end
    
    % Copy record-button status
    tag = 'record_toolbar_button';
    HmatchOld = findobj(imlook4d_current_handle,'Tag',tag);
    HmatchNew = findobj(newHandle,'Tag',tag);
    set( HmatchNew(1), 'State',  get( HmatchOld(1), 'State') );


 %   
 % FINALIZE
 %     
    %Save modified handles    
     guidata(newHandle, newHandles);
     
     imlook4d('updateImage',newHandle, {}, newHandles);
    
    clear tempHandle tempHandles HmatchOld HmatchNew i style tag
