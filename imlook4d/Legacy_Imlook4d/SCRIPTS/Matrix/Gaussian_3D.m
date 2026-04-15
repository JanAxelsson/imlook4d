% Image_Filter_3D.m
%
% SCRIPT for imlook4d to Gauss filter in 3 dimensions
%
%
% Jan Axelsson

%
% INITIALIZE
%

    % Export to workspace
    StartScript
        %imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace
        %activeROI=get(imlook4d_current_handles.ROINumberMenu,'Value');

    % Voxel size
    try
        dX=imlook4d_current_handles.image.pixelSizeX;
        dY=imlook4d_current_handles.image.pixelSizeY;
        dZ=imlook4d_current_handles.image.sliceSpacing;
    catch
        warning('Imlook4d: Pixel dimensions unknown -- Assuming 1x1x1 mm voxels');
        dX=1;
        dY=1;
        dZ=1;
    end

    
    % Define filter
        prompt={'x FWHM [mm]', 'y FWHM [mm]', 'z FWHM [mm]'};
        title='3D Gaussian filter';
        numlines=1;
        defaultanswer={ '5', '5', '5' };
        answer=inputdlg(prompt,title,numlines,defaultanswer);
        
        % Calculate width (in number of pixels)           
            widthInMmX = str2num(answer{1});
            widthInMmY = str2num(answer{2});
            widthInMmZ = str2num(answer{3});
            
            widthInPixelsX = widthInMmX/dX;
            widthInPixelsY = widthInMmY/dY;
            widthInPixelsZ = widthInMmZ/dZ;
 
            disp(['FWHM [mm] (x,y,z)=(' ...
                num2str(widthInMmX) ', ' ...
                num2str(widthInMmY) ', '...
                num2str(widthInMmZ) ...
                ') mm']);   
            
            disp(['FWHM [pixels] (x,y,z)=(' ...
                num2str(widthInPixelsX) ', ' ...
                num2str(widthInPixelsY) ', '...
                num2str(widthInPixelsZ) ...
                ') pixels']);
           
            
            % FWHM-in-pixels / 2.35   
            sigmaX=widthInPixelsX / 2.35;  
            sigmaY=widthInPixelsY / 2.35;  
            sigmaZ=widthInPixelsZ / 2.35;          
           
        % Calculate filter size (3 times FWHM in pixels)
            fsizeX=( round(3*widthInPixelsX) +1 )/2 ; 
            fsizeY=( round(3*widthInPixelsY) +1 )/2 ;
            fsizeZ=( round(3*widthInPixelsZ) +1 )/2 ;
            
            c = 5; % Number of sigmas to use in matrix (convolution speed depends on this)
            fsizeX=ceil(c*sigmaX);
            fsizeY=ceil(c*sigmaY);
            fsizeZ=ceil(c*sigmaZ);
            
            
                      
            disp(['Filtersize sigma  (x,y,z)=(' num2str(sigmaX) ', ' num2str(sigmaY) ', ' num2str(sigmaZ) ') pixels']);
            disp(['Filtersize pixels (x,y,z)=(' num2str(fsizeX) ', ' num2str(fsizeY) ', ' num2str(fsizeZ) ') pixels']);  
        
    
        %
        % Gaussian filter matrix
        %          
            for i = -(fsizeX-1):(fsizeX-1)  % Loop in steps of 1 pixel
                for j = -(fsizeY-1):(fsizeY-1)
                    for k= -(fsizeZ-1):(fsizeZ-1)
                        x = i*dX; % position in mm
                        y = j*dY; % position in mm
                        z = k*dZ; % position in mm
                        % Calculate formula using positions in mm, place in ix=1,2,.., iy=1,2,..., iz=1,2,...
                        %filterKernel(i+fsizeX, j+fsizeY, k+fsizeZ) = exp( -(x^2+y^2+z^2)/(2*sigmaX^2+2*sigmaY^2+2*sigmaZ^2)  );
                   
                        filterKernel(i+fsizeX, j+fsizeY, k+fsizeZ) = ...
                            exp( -(x^2)/(2*sigmaX^2) ) * ...
                            exp( -(y^2)/(2*sigmaY^2) ) * ...
                            exp( -(z^2)/(2*sigmaZ^2) );

                    end
                end
            end

            filterKernel = filterKernel / sum(filterKernel(:));  % Normalize to sum 1
            
            size(filterKernel)

%             % TODO: One dimensional (instead)
%                         
%             for i = -(fsizeX-1):(fsizeX-1)  % Loop in steps of 1 pixel
%                 x = i*dX; % position in mm
%                 filterKernelX = exp( -(x^2)/(2*sigmaX^2) );
%             end
%             filterKernelX = filterKernelX / sum(filterKernelX(:));  % Normalize to sum 1
%              
%             for i = -(fsizeY-1):(fsizeY-1)  % Loop in steps of 1 pixel
%                 y = i*dY; % position in mm
%                 filterKernelY = exp( -(y^2)/(2*sigmaY^2) );
%             end
%             filterKernelY = filterKernelY / sum(filterKernelY(:));  % Normalize to sum 1     
%             
%             for i = -(fsizeZ-1):(fsizeZ-1)  % Loop in steps of 1 pixel
%                 z = i*dZ; % position in mm
%                 filterKernelZ = exp( -(z^2)/(2*sigmaZ^2) );
%             end 
%             filterKernelZ = filterKernelZ / sum(filterKernelZ(:));  % Normalize to sum 1  
            
            
%
%  PROCESS
%

    % Loop frames
            
            waitBarHandle = waitbar(0,'Filtering frames');	% Initiate waitbar with text
            
            for j=1:size(imlook4d_Cdata,4)
                waitbar(j/size(imlook4d_Cdata,4));          % Update waitbar
                temp=convn(imlook4d_Cdata(:,:,:,j),filterKernel,'same');
                imlook4d_Cdata(:,:,:,j)=temp;
            end
             
            close(waitBarHandle);                           % Close waitbar

%
% FINALIZE
% 
    % Record history (what this image has been through)
    historyDescriptor=answer{1};
    imlook4d_current_handles.image.history=[historyDescriptor '-' imlook4d_current_handles.image.history  ];
    guidata(imlook4d_current_handle, imlook4d_current_handles);
    
    imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Import from workspace
%     
%     clear activeROI answer dX dY dZ defaultanswer fsizeX fsizeY fsizeZ historyDescriptor i 
%     clear imlook4d_Cdata imlook4d_ROI imlook4d_ROINames imlook4d_current_handle imlook4d_current_handles imlook4d_duration 
%     clear imlook4d_frame imlook4d_slice imlook4d_time j k numlines prompt sigma temp title widthInMm 
%     clear widthInPixelsX widthInPixelsY widthInPixelsZ x y z filterKernel waitBarHandle
%     
EndScript
