% Start script
    StartScript;
    historyDescriptor='slice_choice'; % Make a descriptor to prefix new window title with

    % Get user input
    prompt={'Start slize:',...
                'End slize'};
        title_name='S';
        numlines=1;
    	defaultanswer={'1' '10'};

    answer=inputdlg(prompt,title_name,numlines,defaultanswer);
    
    slice_start=str2num(answer{1});
    slice_end=str2num(answer{2});
    
    imlook4d_Cdata=imlook4d_Cdata(:, :, slice_start:slice_end);
    imlook4d_current_handles.image.sliceLocations=imlook4d_current_handles.image.sliceLocations(slice_start:slice_end);
  
        % Finish script
        EndScript
