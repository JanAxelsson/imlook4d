% SumSlices
%
% This script adds N slices together by making an average.
% ROIs are updated by keeping the highest ROI number in each pixel
% DICOM variables are rewritten

StartScript

numberOfSlices=size(imlook4d_Cdata,3);

% Get user input
prompt={'Number of slices used for each new slice'};
    title='Sum slices';
    numlines=1;
    defaultanswer={'2'};
answer=inputdlg(prompt,title,numlines,defaultanswer);
step = str2num( answer{1});

% Create empty variables
matrixSize = size( imlook4d_Cdata);
matrixSize(3) = floor(matrixSize(3)/step);
a = zeros( matrixSize );      % New image matrix
b = zeros( matrixSize(1:3) ,'uint8'); % New ROI matrix.  ROI only has 3 dimensions

% Merge slices in image and ROIs
i=0;
while i< matrixSize(3)   
    % Update for processed range
    i = i+1;
    range = 1 + step * (i-1)  : step * i ;
    a(:,:, i ,:) = mean( imlook4d_Cdata( :,:,range,:), 3);   % Average pixel value used
    b(:,:, i) = max( imlook4d_ROI( :,:,range), [], 3);       % Assign to highest ROI number
    
    % Set to ONE of the values in range
    mid = floor( mean(range) );  % Use this value in range. Ex: range=[1 2 3] => mid=2
    try % DICOM variables
        dirtyDICOMHeader{i} = imlook4d_current_handles.image.dirtyDICOMHeader{ mid };
        dirtyDICOMFileNames{i} = imlook4d_current_handles.image.dirtyDICOMFileNames{ mid };
        imagePosition{i} = imlook4d_current_handles.image.imagePosition{ mid };
        dirtyDICOMIndecesToScaleFactor = imlook4d_current_handles.image.dirtyDICOMIndecesToScaleFactor{ mid };
        %sliceLocations(i) = imlook4d_current_handles.image.sliceLocations(mid);
        sliceLocations(i) = mean(imlook4d_current_handles.image.sliceLocations(range));
        DICOMsortedIndexList(i,:) = imlook4d_current_handles.image.DICOMsortedIndexList(mid,:);
        
    catch
    end
end


% Store new variables
imlook4d_Cdata = a;  % Image matrix
imlook4d_ROI = b;    % ROI matrix

% Store new variables
try imlook4d_current_handles.image.dirtyDICOMHeader = dirtyDICOMHeader; catch end
try imlook4d_current_handles.image.dirtyDICOMFileNames = dirtyDICOMFileNames;catch end
try imlook4d_current_handles.image.imagePosition = imagePosition; catch end

try imlook4d_current_handles.image.dirtyDICOMIndecesToScaleFactor = dirtyDICOMIndecesToScaleFactor;catch end
try imlook4d_current_handles.image.sliceLocations = sliceLocations;catch end
try imlook4d_current_handles.image.DICOMsortedIndexList = DICOMsortedIndexList;catch end

try imlook4d_current_handles.image.sliceSpacing = step * imlook4d_current_handles.image.sliceSpacing;catch end


EndScript
