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
backgroundHandles = guidata(imlook4d_current_handles.image.backgroundImageHandle);  % Handles from imlook4d instance of static background image
backgroundSize = size(backgroundHandles.image.Cdata);

% Link if same matrix sizes
if ( currentSize(1:3) == backgroundSize(1:3) )
    %imlook4d_current_handles.image.backgroundImageHandle = [];
    Import
else
        % Align movingImage to staticImage
        % Example PT on MR from PET/MR-exam.  Started this script from PT-imlook4d instane
        
        % imlook4d_current_handles is the image we started from. Change this image (PT)
        staticImage = backgroundHandles; % Keep background image (MR)
        
        %
        % Change matrix of current image to align to background image
        %
    
        % Reslice
        try
        [outImageStruct indeces] = reslice( staticImage.image , imlook4d_current_handles.image );  % outImageStruct is now updated.
        
        % Change matrix dimensions and FOV
        outImageStruct  = resize_matrix2( staticImage.image, outImageStruct );  % Aligned to space of staticImage (PT aligned to MR)
        
        %
        % Write back
        %
        
        % Modify imlook4d variables that should be changed
        % START
        imlook4d_current_handles.image=outImageStruct;  % Use outImageStruct in new space (DICOM headers, data matrix etc) (MR)
        
        % Set display window to match what we started from
        imlook4d_current_handles.axes1.XLim = staticImage.axes1.XLim;
        imlook4d_current_handles.axes1.YLim = staticImage.axes1.YLim;
        
        % Set display interpolation to match what we started from
        imlook4d_current_handles.interpolate2 = staticImage.interpolate2;
        imlook4d_current_handles.interpolate4 = staticImage.interpolate4;
        
        imlook4d_Cdata=outImageStruct.Cdata;  % Set up Import with variables from new space (matrix from aligned-PT)     
        imlook4d_ROI=outImageStruct.ROI;      % 
        
        Import
    
    
%     warndlg({ 'Background image does not have same matrix size', ...
%         [ 'Current image size    = ' num2str(currentSize) ], ...
%         [ 'Background image size = ' num2str(backgroundSize) ], ...
%         '  ' , ...
%          'Solution : Resize matrices to same size', ...
%          ' ',....
%          'Use for instance "SCRIPTS/Matrix/Put in other matrix" on the smallest matrix prior to adding it as a background image' ...
%          });
        catch
        end
end

ClearVariables
