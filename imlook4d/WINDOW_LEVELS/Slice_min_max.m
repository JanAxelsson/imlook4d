function Slice_min_max(hObject, eventdata, handles)

    %window=[-1500 500];

    % Display HELP and get out of callback
     if imlook4d('DisplayHelp', hObject, eventdata, handles) 
         return 
     end
     

    % Determine min-max in frame
    imlook4d_handles=guidata(gcf);
    slice=round(get(imlook4d_handles.SliceNumSlider,'Value'));
    frame=round(get(imlook4d_handles.FrameNumSlider,'Value'));
    
    minValue=min(min(min( imlook4d_handles.image.Cdata(:,:,slice,frame)) ))
    maxValue=max(max(max( imlook4d_handles.image.Cdata(:,:,slice,frame)) ))
    window=[minValue maxValue];
    
     
    % Set window level
    imlook4d('setColorBar',guidata(gcf),window )