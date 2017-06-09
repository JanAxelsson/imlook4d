% Start script
clear xls_matrix xls_matrix_txt xls_matrix_raw
    StartScript;
    
    
    old_image_size=size(imlook4d_current_handles.image.Cdata);
    
    [xls_matrix, xls_matrix_txt, xls_matrix_raw]=xlsread('D:\My Box Files\Matlab\xls for imlook\Bok2', -1);
   %[FileName,PathName] = uiputfile;
   %[xls_matrix, xls_matrix_txt, xls_matrix_raw]=xlsread(');
   
    matrix_size=size(xls_matrix);
    
    nr_new_frames=max(xls_matrix(:, 1));
  
        
    
    % Ask for input
%     prompt={'Enter the number of frames to be summed in each new time frame:',...
%         'Enter new window title:'};
%     name='Input for new image';
%     numlines=1;
%     defaultanswer={'2','Summed frames x slices'};
%     answer=inputdlg(prompt,name,numlines,defaultanswer);
%     
%     historyDescriptor=str2mat(answer(2)); % Make a descriptor to prefix new window title with
    historyDescriptor=xls_matrix_raw(3, 3);
    historyDescriptor=str2mat(historyDescriptor);
    % Collect answer about how many frames that should be summed to each
    % new frame. Calculate number of new frames.
    %nr_frames_sum=str2num(cell2mat(answer(1)));
    %nr_new_frames=ceil(old_image_size(4)/nr_frames_sum);
    
    
    % Set empty variabels for the new image matrix and new time and duration
    % vectors.
    new_image=zeros(old_image_size(1), old_image_size(2), old_image_size(3), nr_new_frames);
    new_imlook4d_duration=zeros(1, nr_new_frames);
    new_imlook4d_time=zeros(1, nr_new_frames);
    
    % Calculate new image matrix and new duration vector
       
    for i=1:nr_new_frames
        for j=1:xls_matrix(i, 2)
            a=sum(xls_matrix(1:i, 2))-xls_matrix(i, 2);
            new_image(:, :, :, i)=new_image(:, :, :, i)+imlook4d_Cdata(:, :, :, a+j)/xls_matrix(i, 2);
            new_imlook4d_duration(i)=new_imlook4d_duration(i)+imlook4d_duration(a+j);
        end
    end
    
    
    % Normalise new image matrix
    %new_image=new_image/nr_frames_sum;
    
%     % Set last time frame and last number in duration vector
%     last_frame_sum=old_image_size(4)-nr_frames_sum*(nr_new_frames-1);
%     for i=1:last_frame_sum
%        new_image(:, :, :, nr_new_frames)= new_image(:, :, :, nr_new_frames)+imlook4d_Cdata(:, :, :, old_image_size(4)-last_frame_sum+i);
%        new_imlook4d_duration(nr_new_frames)=new_imlook4d_duration(nr_new_frames)+imlook4d_duration(old_image_size(4)-last_frame_sum+i);
%     end
%     new_image(:, :, :, nr_new_frames)=new_image(:, :, :, nr_new_frames)/last_frame_sum;
    
    
    % Set first time value separately, than calculate the other values.
    new_imlook4d_time(1)=0;
    for i=1:nr_new_frames-1
        new_imlook4d_time(i+1)=new_imlook4d_time(i)+new_imlook4d_duration(i);
    end
    
    % Replace the old variabels with the newly calculated ones. 
    imlook4d_Cdata=new_image;
    imlook4d_duration=new_imlook4d_duration;
    imlook4d_time=new_imlook4d_time;

    % Finish script
    EndScript
