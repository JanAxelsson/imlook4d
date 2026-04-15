function outImageStruct  = resize_matrix( templateImageStruct, oldImageStruct )
% RESLICE Resizes the matrix of an image volume (oldImageStruct) so that number of pixels and field-of-view are the same
% as a template (templateImageStruct).
%
% The original header is kept for each image, but necessary tags are
% modified.
%   
% Input:
%   templateImageStruct     handles.image for the image we use as a  template for positions
%   oldImageStruct          handles.image for the image we want to position as template positions
%
% Output:
%   outImageStruct          image struct with images at positions
%   indeces                 indeces to slices in oldImage, that were used outIMage


% Verify that static image
if size(oldImageStruct.Cdata,4)>1
   warndlg('Dynamic images cannot be resliced - reslice the static image instead'); 
   return
end


% Copy header, and zero what should be changed
outImageStruct=oldImageStruct;
outImageStruct.dirtyDICOMHeader={};
outImageStruct.dirtyDICOMFileNames={};
outImageStruct.dirtyDICOMIndecesToScaleFactor={};
outImageStruct.Cdata=[];

% Read positions to match
oldPositions=oldImageStruct.sliceLocations;
newPositions=templateImageStruct.sliceLocations;


% Set up transformations in x-y plane


    % Image to change
    nx1=size(oldImageStruct.Cdata,1);
    ny1=size(oldImageStruct.Cdata,2);
    x1size=oldImageStruct.pixelSizeX*nx1;
    y1size=oldImageStruct.pixelSizeY*ny1;
    
    x1=single(linspace(-x1size/2, x1size/2, nx1));
    y1=single(linspace(-y1size/2, y1size/2, ny1));
 
    % Template image
    nx2=size(templateImageStruct.Cdata,1);
    ny2=size(templateImageStruct.Cdata,2);
    x2size=templateImageStruct.pixelSizeX*nx2;
    y2size=templateImageStruct.pixelSizeY*ny2;
    
    x2=single(linspace(-x2size/2,x2size/2, nx2));
    y2=single(linspace(-y2size/2,y2size/2, ny2));

    disp(['resize matrix - Converting from ' num2str(nx1) 'x' num2str(ny1) ' to ' num2str(nx2) 'x' num2str(ny2) ' matrix']);



% Loop positions in template z-axis
    numberOfSlices=size(templateImageStruct.Cdata,3);  % We want these many slices in the new image set
    outImageStruct.Cdata=zeros(nx2,ny2,numberOfSlices);
    outImageStruct.ROI=zeros(nx2,ny2,numberOfSlices,'int8');  % ROI's can't be interpolated, since they are integers
    
    
waitBarHandle = waitbar(0,'Resizing images');	% Initiate waitbar with text
        
    for i=1:numberOfSlices
        %disp(i)
        waitbar(i/numberOfSlices);          % Update waitbar
        
            %outImageStruct.Cdata(:,:,i)=interp2(x1, y1', oldImageStruct.Cdata(:,:,i), x2, y2','*linear');  % Equally spaced, use '*' in front of method to increase speed
            outImageStruct.Cdata(:,:,i)=interp2(y1, x1', oldImageStruct.Cdata(:,:,i), y2, x2','linear');

            % Modify outputImageStruct - Cells
            outImageStruct.dirtyDICOMHeader{i}=oldImageStruct.dirtyDICOMHeader{i};
            outImageStruct.dirtyDICOMFileNames{i}=oldImageStruct.dirtyDICOMFileNames{i};
            outImageStruct.dirtyDICOMIndecesToScaleFactor{i}=oldImageStruct.dirtyDICOMIndecesToScaleFactor{i};

            % Change DICOM header - FOV

            % Change DICOM header - coordinate


    end

% Set outside FOV pixels (NaN) to zero
   outImageStruct.Cdata(isnan(outImageStruct.Cdata)) = 0 ;
    

% Modify  Scalars
    outImageStruct.dirtyDICOMSlicesString=numberOfSlices;
    outImageStruct.dirtyDICOMPixelSizeString=size(outImageStruct.Cdata,1);
    outImageStruct.pixelSizeX=templateImageStruct.pixelSizeX;
    outImageStruct.pixelSizeY=templateImageStruct.pixelSizeY;
    outImageStruct.sliceSpacing=templateImageStruct.sliceSpacing;


    close(waitBarHandle);                           % Close waitbar
    disp('Done!');


