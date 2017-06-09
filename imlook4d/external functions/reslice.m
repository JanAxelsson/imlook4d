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
if size(oldImageStruct.Cdata,4)>1
   warndlg('Dynamic images cannot be resliced - reslice the static image instead'); 
   return
end


% Copy header, and zero what should be changed
outImageStruct=oldImageStruct;
outImageStruct.dirtyDICOMHeader={};
%outImageStruct.dirtyDICOMFileNames=templateImageStruct.dirtyDICOMFileNames;
outImageStruct.dirtyDICOMIndecesToScaleFactor={};
outImageStruct.Cdata=[];

%outImageStruct.imagePosition = templateImageStruct.imagePosition;
outImageStruct.imagePosition = oldImageStruct.imagePosition;

% Read positions to match
oldPositions=oldImageStruct.sliceLocations;
newPositions=templateImageStruct.sliceLocations;

disp(['reslice - Coverting from ' num2str(size(oldImageStruct.Cdata,3)) ' to '  num2str(size(templateImageStruct.Cdata,3)) ' slices']);

% Loop positions in template z-axis
numberOfSlices=size(templateImageStruct.Cdata,3);  % We want these many slices in the new image set
            
waitBarHandle = waitbar(0,'Reslicing frames');	% Initiate waitbar with text
     
%numberOfSlices = min( [ size(templateImageStruct.Cdata,3) size(oldImageStruct.Cdata,3)] );             

for i=1:numberOfSlices
        if mod(i,round(numberOfSlices/20) )
            waitbar(i/numberOfSlices);          % Update waitbar
        end
   

         % Determine index to image in oldImage
        [dummy,index]=min(abs(oldPositions-newPositions(i)) );
        indeces(i)=index;  % for a templateSlice i, indeces(i) is the nearest slice in oldImage
        
        if index > numberOfSlices 
           index = numberOfSlices 
        end
        if index < 1 
           index = 1 
        end        
        
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
         outImageStruct.Cdata(:,:,i,:)=weight1*oldImageStruct.Cdata(:,:,ind(1),:)+weight2*oldImageStruct.Cdata(:,:,ind(2),:);
%        outImageStruct.Cdata(:,:,i,:)=(distances(1)*oldImageStruct.Cdata(:,:,ind(1),:)+distances(2)*oldImageStruct.Cdata(:,:,ind(2),:) )...
%            /(distances(1)+distances(2));
       
        % Set new slice position
        outImageStruct.imagePosition{1}(3) = templateImageStruct.imagePosition{1}(3);

        % Modify outputImageStruct - Matlab Cells
        outImageStruct.dirtyDICOMHeader{i}=oldImageStruct.dirtyDICOMHeader{index};
        outImageStruct.dirtyDICOMFileNames{i}=oldImageStruct.dirtyDICOMFileNames{index};
        %outImageStruct.dirtyDICOMFileNames{i}=templateImageStruct.dirtyDICOMFileNames{index};  
        outImageStruct.dirtyDICOMIndecesToScaleFactor{i}=oldImageStruct.dirtyDICOMIndecesToScaleFactor{index};  % This one is probably wrong - but scale factor is corrected when saving image.  Scale factor is not used anywhere because Cdata stores float data.

        try
            outImageStruct.time2D(i, :) = oldImageStruct.time2D(index,:);
            outImageStruct.duration2D(i, :) = oldImageStruct.duration2D(index,:);
        catch
        end
        
        % Change DICOM header - copy positions from templateImage to outImage        
        out1=dirtyDICOMHeaderData(oldImageStruct.dirtyDICOMHeader, ind(1), '0020', '0032',oldImageStruct.dirtyDICOMMode);  % This is only for test output
%         
%         % Position 1)
%         try
%             out2=dirtyDICOMHeaderData(templateImageStruct.dirtyDICOMHeader, i, '0020', '1041',templateImageStruct.dirtyDICOMMode);
%             outImageStruct.dirtyDICOMHeader{i}=dirtyDICOMModifyHeaderString(outImageStruct.dirtyDICOMHeader{i},'0020', '1041',outImageStruct.dirtyDICOMMode, out2.string);
%         catch
%             % missing tag
%         end
         % Position 2)
        
        
        out3=dirtyDICOMHeaderData(templateImageStruct.dirtyDICOMHeader, i, '0020', '0032',templateImageStruct.dirtyDICOMMode);
        outImageStruct.dirtyDICOMHeader{i}=dirtyDICOMModifyHeaderString(outImageStruct.dirtyDICOMHeader{i},'0020', '0032',outImageStruct.dirtyDICOMMode, out3.string);

      %  disp(['WAS=' num2str(oldPositions(ind(1))) ' and ' num2str(oldPositions(ind(2))) ' ---  WAS=('  out1.string ') --- weights=(' num2str(weight1) ',' num2str(weight2) ')   IS=(' out3.string ')']);


        
        % Change DICOM header - instance number
        
        outImageStruct.dirtyDICOMHeader{i}=dirtyDICOMModifyHeaderString(outImageStruct.dirtyDICOMHeader{i},'0020','0013',outImageStruct.dirtyDICOMMode, num2str(i));

        

end


% Modify  Matrix
outImageStruct.sliceLocations=templateImageStruct.sliceLocations;
%outImageStruct.Cdata=oldImageStruct.Cdata(:,:,indeces,:);
outImageStruct.ROI=oldImageStruct.ROI(:,:,indeces);


% Modify  Scalars
outImageStruct.dirtyDICOMSlicesString=numberOfSlices;
outImageStruct.dirtyDICOMPixelSizeString=size(outImageStruct.Cdata,1);
outImageStruct.sliceSpacing=templateImageStruct.sliceSpacing;



close(waitBarHandle);                           % Close waitbar
disp('Done!');


