% Align_image_sets.m
%
% Jan Axelsson
%
% The theory of this script is to replace the exported image with a
% processed image.  This is done by 
% 1) changing the imlook4d_current_handles and the imlook4d-variable that
%    were exported by StartScript command
% 2) importing them back by EndScript command
%
% In this script, a second image is selected from the open imlook4d images,
% by the call to ontopMsgbox.
%StartScript
StoreVariables;
tic
%
% INITIALIZE
%
        % Prefix which is added to window title
            historyDescriptor='Aligned';

        % Verify that not a dynamic image 
        % (not supported in reslice or  resize_matrix)
            if size(imlook4d_current_handles.image.Cdata,4)>1
               warndlg('Dynamic images cannot be resliced - reslice the static image instead'); 
               return
            end
        
        % Get image 1 (to imlook4d_current_handle)
            temp = imlook4d_variables_before_script;  
            StartScript 
            
            imlook4d_variables_before_script = temp; % ignore new variable created in StartScript
  
        % Get image 2  (which is the template image, called staticImage) 
         
%             staticImage.handle=ontopMsgbox(imlook4d_current_handle,...
%                 {'Select template image (from imlook4d/Windows menu)', ...
%                 '(image that we want slices to match'}, ...
%                 'Select template image');
%             disp('EXIT MSG BOX');
staticImage.handle=SelectWindow({'Select template image (from imlook4d/Windows menu)', ...
                '(image that we want slices to match'});

            % Image2 is stored in staticImage.handle
            staticImage.handles=guidata(staticImage.handle);
%
% PROCESS
%

    % Align movingImage to staticImage
    
        % Reslice
        [outImageStruct indeces] = reslice( staticImage.handles.image ,imlook4d_current_handles.image );  % outImageStruct is now updated.
        
        % Change matrix dimensions and FOV
        outImageStruct  = resize_matrix2( staticImage.handles.image, outImageStruct );

%
% WRITE BACK
%       

        % NOTE: EndScript imports the following variables into imlook4d_current_handle:
        %   imlook4d_current_handles,
        % where the following variables override data in the struct imlook4d_current_handles
        %   imlook4d_Cdata, 
        %   imlook4d_ROI, 
        %   imlook4d_ROINames, 
        %   imlook4d_time, 
        %   imlook4d_duration 
        %
        % At this point, above variables are all the same as image1 (imlook4d_current_handle)!

        % Modify imlook4d variables that should be changed
        imlook4d_current_handles.image=outImageStruct;  % Use outImageStruct (DICOM headers, data matrix etc)
        
        imlook4d_Cdata=imlook4d_current_handles.image.Cdata;       
        imlook4d_ROI=imlook4d_current_handles.image.ROI;
        
        % Import imlook4d_current_handles and variables, and cleans up
        EndScript  

toc
    
