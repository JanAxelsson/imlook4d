function [outImageStruct indeces] = reslice( templateImageStruct, oldImageStruct )
% RESLICE Reslices a static image volume (oldImageStruct) so that slices are located at same
% positions as a template (templateImageStruct).
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
outImageStruct.dirtyDICOMHeader={};
outImageStruct.dirtyDICOMFileNames={};
outImageStruct.dirtyDICOMIndecesToScaleFactor={};
outImageStruct.Cdata=[];
outImageStruct.imagePosition={};
try
outImageStruct.dirtyDICOMMode = oldImageStruct.dirtyDICOMMode;
catch
    return
end

% Read positions to match
oldPositions=unique(oldImageStruct.sliceLocations); % unique, to allow dynamic scans to give one position (ignoring that position repeats for multiple frames)
newPositions=templateImageStruct.sliceLocations;


disp(['reslice - Coverting from ' num2str(size(oldImageStruct.Cdata,3)) ' to '  num2str(size(templateImageStruct.Cdata,3)) ' slices']);

% Loop positions in template z-axis
numberOfSlices=size(templateImageStruct.Cdata,3);  % We want these many slices in the new image set
oldNumberOfSlices=size(oldImageStruct.Cdata,3); 
numberOfFrames=size(oldImageStruct.Cdata,4);  
            
waitBarHandle = waitbar(0,'Reslicing frames (pass 1)');	% Initiate waitbar with text
     

outImageStruct.time2D = zeros(numberOfSlices,numberOfFrames);
outImageStruct.duration2D = zeros(numberOfSlices,numberOfFrames);

outImageStruct.Cdata = zeros( [ size(oldImageStruct.Cdata,1), ...
    size(oldImageStruct.Cdata,2), ...
    size(templateImageStruct.Cdata,3 ) ...
    size(oldImageStruct.Cdata,4), ...
    ]);

for i=1:numberOfSlices
        if mod(i,round(numberOfSlices/20) )
            waitbar(i/numberOfSlices);          % Update waitbar
        end
   

         % Determine index to image in oldImage
        [dummy,index]=min(abs(oldPositions-newPositions(i)) );
        indeces(i)=index;  % for a templateSlice i, indeces(i) is the nearest slice in oldImage
        
%         if index > numberOfSlices 
%            index = numberOfSlices 
%         end
%         if index < 1 
%            index = 1 
%         end        
        
%         
%         % Linear interpolation (distance-weighted average)
         [distances,ind]=sortrows((abs(oldPositions-newPositions(i)) )); % ind(1:2) show nearest two slices
         totDistance=distances(1)+distances(2);
         % Weights - biggest weight to nearest (therefore reversed indeces 1,2)
         if (totDistance==0)
             weight1=1;
             weight2=1;
         else
            weight2=distances(1)/totDistance;
            weight1=distances(2)/totDistance;
         end
         
         %outImageStruct.Cdata(:,:,i,:)=weight1*oldImageStruct.Cdata(:,:,ind(1),:)+weight2*oldImageStruct.Cdata(:,:,ind(2),:);
         
         if ( ind(1)>1 ) & ( ind(1)<oldNumberOfSlices )
            outImageStruct.Cdata(:,:,i,:)=weight1*oldImageStruct.Cdata(:,:,ind(1),:)+weight2*oldImageStruct.Cdata(:,:,ind(2),:);
         else
            outImageStruct.Cdata(:,:,i,:) = 0;
         end 

end

%
% Modify image meta-data
%

% Repeating values for each frame
outImageStruct.sliceLocations = repmat(templateImageStruct.sliceLocations, [numberOfFrames 1] );
%outImageStruct.imagePosition = repmat(oldImageStruct.imagePosition, [1 numberOfFrames] );
        
% Pick data from nearest slice
outImageStruct.ROI=oldImageStruct.ROI(:,:,indeces);


% Modify  Scalars
outImageStruct.dirtyDICOMSlicesString=numberOfSlices;
outImageStruct.dirtyDICOMPixelSizeString=size(outImageStruct.Cdata,1);
outImageStruct.sliceSpacing=templateImageStruct.sliceSpacing;
       
% Time and duration (when applicable)
try
    outImageStruct.time2D(i, :) = oldImageStruct.time2D(1:numberOfSlices,:);
    outImageStruct.duration2D(i, :) = oldImageStruct.duration2D(1:numberOfSlices,:);
catch
end

% Modify for each new slice and frame

outImageStruct.DICOMsortedIndexList = zeros( numberOfFrames, size(oldImageStruct.DICOMsortedIndexList,2) );
outImageStruct.dirtyDICOMIndecesToScaleFactor = cell( 1, numberOfFrames*numberOfSlices ); 

close(waitBarHandle); 
waitBarHandle = waitbar(0,'Reslicing frames (pass 2)');	% Initiate waitbar with text
for j=1:numberOfFrames
    waitbar( j /numberOfFrames);
    
    for i=1:numberOfSlices
        
        oldIndex = indeces(i) + (j - 1) * oldNumberOfSlices;
        newIndex = i + (j - 1) * numberOfSlices;

        % Modify outputImageStruct - Matlab Cells
        outImageStruct.dirtyDICOMHeader{newIndex} = oldImageStruct.dirtyDICOMHeader{oldIndex};
        outImageStruct.dirtyDICOMFileNames{newIndex}=oldImageStruct.dirtyDICOMFileNames{oldIndex};
        outImageStruct.dirtyDICOMIndecesToScaleFactor{newIndex}=oldImageStruct.dirtyDICOMIndecesToScaleFactor{oldIndex};  % This one is probably wrong - but scale factor is corrected when saving image.  Scale factor is not used anywhere because Cdata stores float data.
        
        % Modify outputImageStruct - Matlab matrices
        outImageStruct.DICOMsortedIndexList(newIndex,:) = oldImageStruct.DICOMsortedIndexList(oldIndex,8);
        
        
        % Change DICOM new headers - read positions from templateImage, copy to new headers
        
        % Position 1)  Image Position Patient
        try
            out1 = dirtyDICOMHeaderData(templateImageStruct.dirtyDICOMHeader, i, '0020', '0032',templateImageStruct.dirtyDICOMMode);  % This is only for test output
            outImageStruct.dirtyDICOMHeader{newIndex} = dirtyDICOMModifyHeaderString(outImageStruct.dirtyDICOMHeader{newIndex},'0020', '0032',outImageStruct.dirtyDICOMMode, out1.string);
        catch   
        end
        
        % Position 2)  Slice Location
        try
            out2 = dirtyDICOMHeaderData(templateImageStruct.dirtyDICOMHeader, i, '0020', '1041',templateImageStruct.dirtyDICOMMode);
            outImageStruct.dirtyDICOMHeader{newIndex} = dirtyDICOMModifyHeaderString(outImageStruct.dirtyDICOMHeader{newIndex},'0020', '1041',outImageStruct.dirtyDICOMMode, out2.string);
        catch
        end
        
        % Position 3) imlook4d store of imagePosition
        outImageStruct.imagePosition{newIndex} = oldImageStruct.imagePosition{ oldIndex};

        
        % Change DICOM header - instance number
        outImageStruct.dirtyDICOMHeader{newIndex} = dirtyDICOMModifyHeaderString(outImageStruct.dirtyDICOMHeader{newIndex},'0020','0013',outImageStruct.dirtyDICOMMode, num2str(newIndex));

    end
end


close(waitBarHandle);                           % Close waitbar
disp('Done!');


