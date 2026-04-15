% Image_Filter_2D.m
%
% SCRIPT for imlook4d to Gauss filter in plane
%
%
% Jan Axelsson


% INITIALIZE

    StartScript
    % Export to workspace
    %imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace
    activeROI=get(imlook4d_current_handles.ROINumberMenu,'Value');
    
    % Define filter
        prompt={'Filter type (gaussian, LoG, average). ',...
                'Width unit (1=FWHM,  2=sigma) (ignored for average filter)',...
                'Width in pixels ( FWHM / sigma / or width for average)'};
        title='2D Image filter';
        numlines=1;
        defaultanswer={ 'gaussian', '1', '2'};
        answer=inputdlg(prompt,title,numlines,defaultanswer);
        

        
        widthInPixels = str2num(answer{3}); % FWHM
        if strcmp(answer{2},'1')
            fwhm =  str2num(answer{3});
            sigma = fwhm/2.35;
        else
            sigma =  str2num(answer{3});
            fwhm = 2.35 * sigma;        
        end
        
        % Filter kernel (half) size
        fsize=( round(3*fwhm) +1 )/2 ; % This will be an integer or an integer+0.5

    
        %
        % Gaussian
        %
        
        if strcmp( answer{1},'gaussian')           
            
            for i = -(fsize-1):(fsize-1)
                for j = -(fsize-1):(fsize-1)
                    k = i+fsize;
                    l = j+fsize;
                    filterHandle(k,l) = exp(-(i^2+j^2)/(2*sigma^2));
                end
            end

            filterHandle=filterHandle/sum(filterHandle(:));  % Normalize to sum 1

        end
        
        %
        % Laplacian of Gaussian
        %
        
        if strcmp( answer{1},'LoG')
            
            for i = -(fsize-1):(fsize-1)
                for j = -(fsize-1):(fsize-1)
                    k = i+fsize;
                    l = j+fsize;
                    filterHandle(k,l) = - (1 / ( 3.14159 * sigma^4) ) * ...
                        ( 1 - (i^2+j^2) / (2*sigma^2) ) * exp(-(i^2+j^2)/(2*sigma^2));
                end
            end

            %filterHandle=filterHandle/sum(filterHandle(:));  % Normalize to sum 1

        end
        
        %
        % Average
        %
        if strcmp( answer{1},'average')
            fsize = (str2num(answer{3}));
            filterHandle=ones(fsize);
            filterHandle=filterHandle/sum(filterHandle(:));  % Normalize to sum 1
        end 


%
%  PROCESS
%

    % Loop frames and slices
        for i=1:size(imlook4d_Cdata,3)
            for j=1:size(imlook4d_Cdata,4)
                temp=conv2(imlook4d_Cdata(:,:,i,j),filterHandle,'same');
                imlook4d_Cdata(:,:,i,j)=temp;
            end
        end

%
% FINALIZE
% 
    % Record history (what this image has been through)
    historyDescriptor=answer{1};
    imlook4d_current_handles.image.history=[historyDescriptor '-' imlook4d_current_handles.image.history  ];
    guidata(imlook4d_current_handle, imlook4d_current_handles);
    
    imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Import from workspace
    
   % clear verify1 i j prompt numlines defaultanswer answer filterHandle
   EndScript
    
