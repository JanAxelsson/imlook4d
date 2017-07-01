% Fill_ROI_Slice_Gaps.m
%
% SCRIPT for imlook4d to extrapolate ROI slices to slices that are empty.
% The empty slices are filled only if there are ROIs at lower and higher
% slices.
%
% Pixels in the currently selected ROI are extrapolated.
%
% 
% Uses: interp_shape (see function for acknowledgement)
%
% Jan Axelsson

% Export to workspace
StoreVariables
Export
% TESTCODE (REMOVE LATER)
% 
% num = 6;
% 
% bottom = imlook4d_ROI(:,:,1)==1;
% top = imlook4d_ROI(:,:,num)==1;
% 
% out = interp_shape(top,bottom,num);
% imlook4d(out)

%
% Extrapolate between ROI slices
%

    % Initialize
    numberOfSlices = size(imlook4d_ROI,3);
    currentROI = imlook4d_ROI_number;
    newImlook4d_ROI = zeros( size(imlook4d_ROI));

    % Determine slices with ROI pixeös
    slicesWithROIs = sum( reshape(imlook4d_ROI==currentROI,[ ], numberOfSlices ),1 )>0 
    sliceNumbersWithROIs = find(slicesWithROIs==1); 
    numberOfSlicesWithROIs = length(sliceNumbersWithROIs);

    % Require at least two ROI slices
    if (numberOfSlicesWithROIs > 1)
        bottomSlices = sliceNumbersWithROIs(1 : (end-1))
        topSlices = sliceNumbersWithROIs(2:end)

        % loop pairs of bottom, top
        for i = 1:numberOfSlicesWithROIs-1
            bottom = imlook4d_ROI(:,:,bottomSlices(i)) == currentROI;
            top = imlook4d_ROI(:,:,topSlices(i)) == currentROI;
            numberOfSlicesToInterpolate = topSlices(i) - bottomSlices(i) + 1
            newImlook4d_ROI(:,:, bottomSlices(i) : topSlices(i) ) = ...
                interp_shape(top,bottom,numberOfSlicesToInterpolate);
        end
    end

    %imlook4d(newImlook4d_ROI);


%   
% FINALIZE
%
    imlook4d_ROI = newImlook4d_ROI;
    Import % Adds ROI to handles in import function
    
    % Store Undo for ROI
    imlook4d_current_handles = imlook4d('storeUndoROI', guidata(imlook4d_current_handle));
    guidata(gcf, imlook4d_current_handles)

    ClearVariables

