StoreVariables
Export

% Get handle to image to put in background
imlook4d_current_handles.image.backgroundImageHandle=SelectWindow({'Select image to use in background (from imlook4d/Windows menu)', ...
                '(image that we want in background', ...
                ' ', ...
                'Wait a second after pressing OK' } ...
            )
            
% Get sizes            
currentSize = size(imlook4d_current_handles.image.Cdata);
backgroundHandles = guidata(imlook4d_current_handles.image.backgroundImageHandle);
backgroundSize = size(backgroundHandles.image.Cdata);

% Link if same matrix sizes
if ( currentSize(1:3) == backgroundSize(1:3) )
    %imlook4d_current_handles.image.backgroundImageHandle = [];
    Import
else
        % Align movingImage to staticImage
        
        movingImage = imlook4d_current_handles; % Change this image
        staticImage = backgroundHandles; % Keep background image dimensions
    
        % Reslice
        [outImageStruct indeces] = reslice( staticImage.image , movingImage.image );  % outImageStruct is now updated.
        
        % Change matrix dimensions and FOV
        outImageStruct  = resize_matrix2( staticImage.image, outImageStruct );
        
        % Write back
        
        % Modify imlook4d variables that should be changed
        imlook4d_current_handles.image=outImageStruct;  % Use outImageStruct (DICOM headers, data matrix etc)
        
        imlook4d_Cdata=imlook4d_current_handles.image.Cdata;       
        imlook4d_ROI=imlook4d_current_handles.image.ROI;
        
        Import
    
    
%     warndlg({ 'Background image does not have same matrix size', ...
%         [ 'Current image size    = ' num2str(currentSize) ], ...
%         [ 'Background image size = ' num2str(backgroundSize) ], ...
%         '  ' , ...
%          'Solution : Resize matrices to same size', ...
%          ' ',....
%          'Use for instance "SCRIPTS/Matrix/Put in other matrix" on the smallest matrix prior to adding it as a background image' ...
%          });
end

ClearVariables
