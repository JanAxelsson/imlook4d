% Start script
    StartScript;
    historyDescriptor='time frame'; % Make a descriptor to prefix new window title with

    % Get user input
    prompt={'Start frame:',...
                'End frame'};
        title_name='S';
        numlines=1;
    	defaultanswer={'1' '10'};

    answer=inputdlg(prompt,title_name,numlines,defaultanswer);
    
    frame_start=str2num(answer{1});
    frame_end=str2num(answer{2});
    
    imlook4d_Cdata=imlook4d_Cdata(:, :, : , frame_start:frame_end);
    imlook4d_current_handles.image.sliceLocations=imlook4d_current_handles.image.sliceLocations(frame_start:frame_end);
    
    new_imlook4d_duration=imlook4d_duration(frame_start:frame_end);
    new_imlook4d_time=imlook4d_time(frame_start:frame_end)-sum(imlook4d_duration(1:frame_start-1));
    
    imlook4d_duration=new_imlook4d_duration;
    imlook4d_time=new_imlook4d_time;
  
        % Finish script
        EndScript
