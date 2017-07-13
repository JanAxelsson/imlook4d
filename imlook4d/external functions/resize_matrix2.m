function outImageStruct  = resize_matrix2( templateImageStruct, oldImageStruct )
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
% if size(oldImageStruct.Cdata,4)>1
%    warndlg('Dynamic images cannot be resliced - reslice the static image instead'); 
%    return
% end


% Copy header, and zero what should be changed
outImageStruct=oldImageStruct;
outImageStruct=oldImageStruct;
outImageStruct.dirtyDICOMHeader=oldImageStruct.dirtyDICOMHeader;
outImageStruct.dirtyDICOMFileNames=oldImageStruct.dirtyDICOMFileNames;

%outImageStruct.dirtyDICOMIndecesToScaleFactor={};
outImageStruct.Cdata=[];

% Read positions to match
oldPositions=oldImageStruct.sliceLocations;
newPositions=templateImageStruct.sliceLocations;

% Constants
numberOfFrames=( size(oldImageStruct.Cdata , 4) );  % Should remain also after resize


% Set up transformations in x-y plane

    % Cosines ( only handle orthogonal axes, that is pos and neg x,y directions)
    try
        xDirection1 = oldImageStruct.DicomImageOrientationVector(1);
        yDirection1 = oldImageStruct.DicomImageOrientationVector(5);
        xDirection2 = templateImageStruct.DicomImageOrientationVector(1);
        yDirection2 = templateImageStruct.DicomImageOrientationVector(5);
    catch
        xDirection1 = 1;
        yDirection1 = 1;
        xDirection2 = 1;
        yDirection2 = 1;
    end

    % Image to change
    dx1=xDirection1*oldImageStruct.pixelSizeX;  % Has a direction
    dy1=yDirection1*oldImageStruct.pixelSizeY;
    
    nx1=size(oldImageStruct.Cdata,1);
    ny1=size(oldImageStruct.Cdata,2);
    
    % First and last point
    x1pos=[ oldImageStruct.imagePosition{1}(1) ,  oldImageStruct.imagePosition{1}(1) + dx1*(nx1-1) ];
    %y1pos=[ oldImageStruct.imagePosition{1}(2) ,  oldImageStruct.imagePosition{1}(2) + dy1*(ny1-1) ];    
    y1pos=[  oldImageStruct.imagePosition{1}(2) + dy1*(ny1-1) , oldImageStruct.imagePosition{1}(2) ];  % Reverse Y direction

    
    x1=single(linspace(x1pos(1), x1pos(2), nx1));
    y1=single(linspace(y1pos(1), y1pos(2), ny1));
 
    % Template image
    dx2=xDirection2*templateImageStruct.pixelSizeX;
    dy2=yDirection2*templateImageStruct.pixelSizeY;
    
    nx2=size(templateImageStruct.Cdata,1);
    ny2=size(templateImageStruct.Cdata,2);
    
    % First and last point
    x2pos=[ templateImageStruct.imagePosition{1}(1) ,  templateImageStruct.imagePosition{1}(1) + dx2*(nx2-1) ];
    %y2pos=[ templateImageStruct.imagePosition{1}(2) ,  templateImageStruct.imagePosition{1}(2) + dy2*(ny2-1) ];
    y2pos=[ templateImageStruct.imagePosition{1}(2) + dy2*(ny2-1) , templateImageStruct.imagePosition{1}(2) ];  % Reverse Y direction
    
    x2=single(linspace(x2pos(1), x2pos(2), nx2));
    y2=single(linspace(y2pos(1), y2pos(2), ny2));
    
%[X, Y ] = meshgrid( x1pos: dx1: x1pos+x1size , y1pos: dy1: y1pos+y1size );  
%[Xq,Yq] = meshgrid( x2pos: dx2: x2pos+x2size , y2pos: dy2: y2pos+y2size );    

%
% Display outputs
%
    t = dirtyDICOMHeaderData(oldImageStruct.dirtyDICOMHeader, 1,'0008','0060',2);modality=t.string;
    disp( [ 'moving image  (' modality ')' ] );
    disp(   '===================' )
    disp([ 'Corner:  [ ' num2str(x1pos(1)) ' x ' num2str(y1pos(1)) ' ]  matrix = [ ' num2str(nx1) ' x ' num2str(ny1) ' ]  Center:  x = '  num2str( ( x1pos(2) + x1pos(1) )/2 ) '   y =' num2str( ( y1pos(2) + y1pos(1) )/2 ) '   Width:  Dx =' num2str( x1pos(2) - x1pos(1) ) '   Dy =' num2str( y1pos(2) - y1pos(1) ) ]);
    disp([ 'Corner:  [ ' num2str(x1pos(2)) ' x ' num2str(y1pos(2)) ' ]' ]);
    disp([ 'PixelSize:  [ ' num2str(dx1) ' x ' num2str(dy1) ' ]' ]);
    disp(' ')
    
    t = dirtyDICOMHeaderData(templateImageStruct.dirtyDICOMHeader, 1,'0008','0060',3);modality=t.string;
    disp( [ 'static / template image  (' modality ')' ] );
    disp(   '==============================' )
    disp([ 'Corner:  [ ' num2str(x2pos(1)) ' x ' num2str(y2pos(1)) ' ]  matrix = [ ' num2str(nx2) ' x ' num2str(ny2) ' ]   Center:  x = '  num2str( ( x2pos(2) + x2pos(1) )/2 ) '   y =' num2str( ( y2pos(2) + y2pos(1) )/2 ) '   Width:  Dx =' num2str( x2pos(2) - x2pos(1) ) '   Dy =' num2str( y2pos(2) - y2pos(1) ) ]);
    disp([ 'Corner:  [ ' num2str(x2pos(2)) ' x ' num2str(y2pos(2)) ' ]' ]);
    disp([ 'PixelSize:  [ ' num2str(dx2) ' x ' num2str(dy2) ' ]' ]);
    disp(' ')


% 
%     %----------------------------------    
%     
%     % USE OTHER METHOD (WORK IN PROGRESS) 
%     X=linspace(-x1size/2, x1size/2, nx1);
%     Y=linspace(-y1size/2, y1size/2, ny1);
%     Z=oldPositions;
%     Xq=linspace(-x2size/2,x2size/2, nx2);
%     Yq=linspace(-y2size/2,y2size/2, ny2);
%     Zq=newPositions;
% 
%     %meshgrid(1:2,-0.2:0.2,1:2)
%     
%     Vq = interp3( X,Y,Z,oldImageStruct.Cdata,Xq,Yq,Zq', 'linear', 0);
%     
%     V=oldImageStruct.Cdata;
%     Vq = interp2( Y,X,V,Xq,Yq, 'linear', 0)
% 
%     %----------------------------------
    
% Loop positions in template z-axis
    numberOfSlices=size(templateImageStruct.Cdata,3);  % We want these many slices in the new image set
    numberOfFrames=size(oldImageStruct.Cdata,4);  % We want these many slices in the new image set
    outImageStruct.Cdata=zeros(nx2,ny2,numberOfSlices);
    outImageStruct.ROI=zeros(nx2,ny2,numberOfSlices,'uint8');  % ROI's can't be interpolated, since they are integers
    
    
waitBarHandle = waitbar(0,'Resizing matrices');	% Initiate waitbar with text
for j=1:numberOfFrames        
    for i=1:numberOfSlices

        %disp(i)
        waitbar( j / numberOfFrames);          % Update waitbar
        
            outImageStruct.Cdata(:,:,i,j)=interp2(y1, x1', oldImageStruct.Cdata(:,:,i,j), y2, x2','linear',0); 

            % update image variables    
               % outImageStruct=truncateDICOM(oldImageStruct, 1:numberOfSlices, 1:numberOfFrames); % Use return range for slices and frames (=1)
        

            % Change DICOM header - FOV

            % Change DICOM header - coordinate


    end
end
close(waitBarHandle);


% Set outside FOV pixels (NaN) to zero
   outImageStruct.Cdata(isnan(outImageStruct.Cdata)) = 0 ;
    

% Modify  Scalars
    outImageStruct.dirtyDICOMSlicesString=numberOfSlices;
    outImageStruct.dirtyDICOMPixelSizeString=size(outImageStruct.Cdata,1);
    outImageStruct.pixelSizeX=templateImageStruct.pixelSizeX;
    outImageStruct.pixelSizeY=templateImageStruct.pixelSizeY;
    outImageStruct.sliceSpacing=templateImageStruct.sliceSpacing;

% Modify position cell array
    waitBarHandle = waitbar(0,'Resizing images (pass 2)');	% Initiate waitbar with text
    for j=1:numberOfFrames
        waitbar( j /numberOfFrames);

        for i=1:numberOfSlices 
            newIndex = i + (j - 1) * numberOfSlices;
            outImageStruct.imagePosition{newIndex}=templateImageStruct.imagePosition{i}; % Multiple slices, should always have same position as template slices

        end
    end   



    close(waitBarHandle);                           % Close waitbar
    disp('Done!');


