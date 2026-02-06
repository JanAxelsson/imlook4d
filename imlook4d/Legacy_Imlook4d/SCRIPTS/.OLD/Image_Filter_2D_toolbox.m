% Image_Filter_2D.m
%
% SCRIPT for imlook4d to Gauss filter in plane
%
% REQUIRES: Imaging Toolbox
%
%
% Jan Axelsson

% VERIFY TOOLBOXES
disp('Image_Filter_2D_toolbox entered');


    verify1=which('fspecial');
    if not(size(verify1)) % verify1=[0 0]  i.e. did not find any path matching
        warndlg('Matlab Image Processing toolbox required!');
        
        clear verify1
        return
    end;  

             


% INITIALIZE

    % Export to workspace
    imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace
    activeROI=get(imlook4d_current_handles.ROINumberMenu,'Value');
    
    % Define filter
        prompt={'Filter type (gaussian, average, etc).  See fspecial in Matlab Imaging toolbox ',...
                'Filter size (in pixels)',...
                'Width (in standard deviation.  Used for gaussian filter only)'};
        title='Image toolbox: fspecial filter';
        numlines=1;
        defaultanswer={ 'gaussian', '5', '1'};
        answer=inputdlg(prompt,title,numlines,defaultanswer);
    
        if strcmp( answer{1},'gaussian')
            filterHandle = fspecial(answer{1},str2num(answer{2}),str2num(answer{3}))
        end
            
        if strcmp( answer{1},'average')
            filterHandle = fspecial(answer{1},str2num(answer{2}))
        end
    
    
         
    
    

    
%
%  PROCESS
%

    % Loop frames
    for i=1:size(imlook4d_Cdata,3)
        for j=1:size(imlook4d_Cdata,4)
            imlook4d_Cdata(:,:,i,j)=imfilter(imlook4d_Cdata(:,:,i,j),filterHandle,'replicate','conv');
        end
    end

%
% FINALIZE
% 
    
    imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Import from workspace
    
    clear verify1 i j prompt numlines defaultanswer answer filterHandle
    
