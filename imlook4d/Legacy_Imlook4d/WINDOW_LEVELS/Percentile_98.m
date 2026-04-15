function Percentile_98(hObject, eventdata, handles)

    %window=[-1500 500];

    % Display HELP and get out of callback
     if imlook4d('DisplayHelp', hObject, eventdata, handles) 
         return 
     end
     

    % Determine min in frame
    imlook4d_handles=guidata(gcf);
    slice=round(get(imlook4d_handles.SliceNumSlider,'Value'));
    frame=round(get(imlook4d_handles.FrameNumSlider,'Value'));
    sliceImage = imlook4d_handles.image.Cdata(:,:,slice,frame);
    
    minValue=min(min(min( sliceImage) ))
    
    % Percentile in frame
    sorted = sort( sliceImage(:), 'ascend');
    percentile = 0.98;
    maxValue = sorted( round( percentile * length(sorted) ));

    % Set window level    
    window=[minValue maxValue];
    imlook4d('setColorBar',guidata(gcf),window )