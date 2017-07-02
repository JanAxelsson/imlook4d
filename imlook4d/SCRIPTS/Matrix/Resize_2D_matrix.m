% Resize_image_matrix.m
%
% SCRIPT to resize image matrix
%
%
% Jan Axelsson


% INITIALIZE
        
    % Define filter
        prompt={'New number of pixels in X ',...
                'New number of pixels in Y ',...
                'Interpolation type (bilinear, nearest, bicubic).  See Matlab interp2 function.'};
        title='Resize image matrix';
        numlines=1;
        defaultanswer={ '128', '128', 'bilinear'};
        answer=inputdlg(prompt,title,numlines,defaultanswer);
        Xpixels=(str2num(answer{1}));
        Ypixels=(str2num(answer{2}));
        interpolationType=answer{3};
        
    %
    % Display in new imlook4d window
    %
        imlook4dWindowTitle=get(imlook4d_current_handles.figure1,'Name');
        Duplicate;  % Call SCRIPTS/Duplicate  (new instance in newHandle) 

    % Export to workspace (from duplicated imlook4d)
        imlook4d('exportToWorkspace_Callback', newHandle,{},newHandles);  % Export to workspace
        

%
%  PROCESS
%
        % Old grid
            [x,y]   = meshgrid(1:1:size(imlook4d_Cdata,1),1:1:size(imlook4d_Cdata,2) );              
         
        % New grid, more steps but same x,y coordinate system
            xStep=size(imlook4d_Cdata,1)/Xpixels;
            yStep=size(imlook4d_Cdata,2)/Ypixels;
            [xi,yi]   = meshgrid(xStep:xStep:size(imlook4d_Cdata,1),yStep:yStep:size(imlook4d_Cdata,2) );
            %[xi,yi]   = meshgrid(1:xStep:Xpixels,1:yStep:Ypixels );

            
            
            

    % Loop frames and slices
        waitBarHandle = waitbar(0,'Resizing');	% Initiate waitbar with text
        last=size(imlook4d_Cdata,3)*size(imlook4d_Cdata,4);
        for i=1:size(imlook4d_Cdata,3)
            for j=1:size(imlook4d_Cdata,4)
                if (mod(i*j, 10)==0) waitbar(i*j/last); end  % Show image number in progress  bar
                tempData=imlook4d_Cdata(:,:,i,j);
                newImlook4d_Cdata(:,:,i,j)=interp2(x,y,tempData',xi,yi,interpolationType)';
                
            end
                %newImlook4d_ROI(:,:,i)=interp2(x,y,imlook4d_ROI(:,:,i)',xi,yi,'bilinear')';
        end
        
        close(waitBarHandle);
        
     % Calculate new values 
     try
        newHandles.image.pixelSizeX=imlook4d_current_handles.image.pixelSizeX * ( size(imlook4d_Cdata,1)/Xpixels);
        newHandles.image.pixelSizeY=imlook4d_current_handles.image.pixelSizeY * ( size(imlook4d_Cdata,2)/Ypixels);
     catch
     end

%
% FINALIZE
% 
         
        
    % Record history (what this image has been through)
        historyDescriptor=[num2str(Xpixels) 'x' num2str(Ypixels) ];
        newHandles.image.history=[historyDescriptor '-' newHandles.image.history  ];   

    % Import modified data (back to duplicated imlook4d)
        imlook4d_Cdata=newImlook4d_Cdata;
        
        imlook4d_ROI=zeros(Xpixels,Ypixels,size(newImlook4d_Cdata,3),'int8');
        %imlook4d_ROI=newImlook4d_ROI;
        
        MakeCurrent
     
        
        set(imlook4d_current_handles.axes1,'XLim',[1 Xpixels], 'YLim', [1 Ypixels]);  % Set viewport size to match matrix        
        imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Import from workspace to duplicated-imlook4d instance 

        disp('DONE importing results');
        
        %guidata(newHandle,newHandles);


    % Set title
        set(imlook4d_current_handles.figure1,'Name', [imlook4dWindowTitle '(' historyDescriptor ')']);
        
        Import
    
    % Clean up

        clear yi last newHandle newHandles newImlook4d_Cdata tempData title 
        clear waitBarHandle x xStep xi y yStep Xpixels Ypixels imlook4dWindowTitle
        clear answer defaultanswer i j numlines prompt
        clear historyDescriptor  imlook4d_Cdata  imlook4d_ROI  imlook4d_ROINames  imlook4d_current_handle  imlook4d_current_handles  imlook4d_duration  imlook4d_frame  imlook4d_slice  imlook4d_time  interpolationType