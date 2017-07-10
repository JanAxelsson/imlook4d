% Threshold_within_ROI.m
%
% SCRIPT for imlook4d to obtain ROI from pixels above threshold, AND within existing ROI.
%
%
% Strategy:  Reuse Threshold_ROI script to find pixels, and pick out the
% pixels that are both in original ROI (oldROI) and in newly Thresholded ROI.
%
%
% Jan Axelsson

% INITIALIZE

StoreVariables
temp_variable_list=imlook4d_variables_before_script;

    Export

    myActiveROI=get(imlook4d_current_handles.ROINumberMenu,'Value');
    
    % Set max value (that will be used in Threshold_ROI
     ROI_data_to_workspace;
     maxLevel=imlook4d_ROI_data.max(imlook4d_frame, myActiveROI);
    
    % Special for Emily
    % numberOfHighestPixels=9;
    % sortedPixels=sort( imlook4d_ROI_data.pixels{myActiveROI}(:,imlook4d_frame) );
    % maxLevel=mean(sortedPixels((end-numberOfHighestPixels-1):end));
    
    % Store ROI
    oldROI=imlook4d_ROI;
    
    % clean ROI - get a fresh start
    imlook4d_ROI(imlook4d_ROI==myActiveROI)=0;
    %ImportUntouched
    Import
    
    % Threshold ROI on myActiveROI (myActiveROI=roi number)
    try
        Threshold_ROI
    catch
        % Canceled or crashed
        imlook4d_ROI=oldROI;
    end
    
    % Result so far:
    %   For the matrix elements with value=myActiveROI,
    %   imlook4d_ROI: thresholded ROI over whole volume
    %   oldROI:       original ROI (which should be the max extension of the new ROI)
    %
    % We now want to keep only pixels that are both in oldROI and imlook4d_ROI
    
    % Make ROI matrix with pixels for new ROI
    newROI=zeros(size(oldROI),'uint8');
    
    % Put pixels from myActiveROI
    newROI( find((imlook4d_ROI==myActiveROI)&(oldROI==myActiveROI)) )=myActiveROI;
    
    % Remove all but myActiveROI
    oldROI(oldROI==myActiveROI)=0;
    
    % Set new pixels
    imlook4d_ROI=oldROI+newROI;
 
   % ImportUntouched
    Import
    

    
    
imlook4d_variables_before_script=temp_variable_list;    
ClearVariables    

