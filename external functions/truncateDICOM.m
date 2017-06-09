function imageHandles=truncateDICOM(imageHandles, sliceRange,frameRange);
%
% This function truncates all variables stored in imlook4d handles, when a DICOM series is truncates
%

numberOfSlices=size( imageHandles.Cdata,3);
numberOfFrames=size( imageHandles.Cdata,4);

newSliceIndeces=1:length(sliceRange);

%
% Modify imageHandles
%

for i=1:length(frameRange)  % Loop number of frames in frameRange (=i)
    frameNumber=frameRange(i);  % The frame number taken from frameRange
    linearIndeces( newSliceIndeces+(i-1)*newSliceIndeces )=sliceRange+(frameNumber-1)*sliceRange;
end


try imageHandles.duration2D=imageHandles.duration2D(sliceRange,frameRange); catch end

try imageHandles.time2D=imageHandles.time2D(sliceRange,frameRange);catch end

imageHandles.DICOMsortedIndexList=imageHandles.DICOMsortedIndexList(linearIndeces);
imageHandles.sliceLocations=imageHandles.sliceLocations(linearIndeces);
imageHandles.imagePosition=imageHandles.imagePosition(1,linearIndeces);
imageHandles.dirtyDICOMFileNames=imageHandles.dirtyDICOMFileNames(linearIndeces);
imageHandles.dirtyDICOMHeader=imageHandles.dirtyDICOMHeader(1,linearIndeces);

imageHandles.dirtyDICOMFileNames=imageHandles.dirtyDICOMFileNames(1,linearIndeces);

imageHandles.dirtyDICOMIndecesToScaleFactor=imageHandles.dirtyDICOMIndecesToScaleFactor(1,linearIndeces);

return