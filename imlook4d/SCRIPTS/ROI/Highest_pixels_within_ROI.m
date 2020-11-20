% Highest_pixels_within_ROI.m
%
% SCRIPT for imlook4d to obtain ROI from pixels 
%
%
% Strategy:  Reuse Threshold_ROI script to find pixels, and pick out the
% pixels that are both in original ROI (oldROI) and in newly Thresholded ROI.
%
%
% Jan Axelsson

% INITIALIZE

StoreVariables

EOL = sprintf('\n');

    Export
    ROI_data_to_workspace
    myActiveROI=get(imlook4d_current_handles.ROINumberMenu,'Value');
    N0 = imlook4d_ROI_data.Npixels(myActiveROI);  % Number of pixels in ROI at start

    
    % Get number of highest pixels to use
    answer = inputdlg( ...
        [ 'The N highest pixels will be kept within the current ROI.', EOL, ... 
          'N cannot be higher than the number of pixels in the ROI', EOL, ...
          '(displayed as default value in dialog)', EOL, ...
          'Input N:' ...
        ] , ...
        'Highest pixels within ROI', ...
        1, ...
        {num2str( N0 )} );
    
    if isempty(answer)  % cancelled inputdlg and clean up
        ClearVariables
        return
    end
    
    N=str2num( answer{1} );
    
    % Get threshold level for the lowest of the N pixels
    sortedPixels=sort( imlook4d_ROI_data.pixels{myActiveROI}(:,imlook4d_frame) , 'descend');
    maxLevel=sortedPixels(N);
    
    % Threshold at 
    INPUTS = Parameters( {'100%', num2str(maxLevel), '1', 'end'} );
    Threshold_within_ROI
    
 
   ImportUntouched
   % Import
        

    
ClearVariables    

