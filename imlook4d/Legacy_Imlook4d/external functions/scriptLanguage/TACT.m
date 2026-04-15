
    % Calculate TACT curve
    % Command TACT(matrix, ROImatrix)
    %
    % Input
    %   matrix          3D or 4D image matrix
    %   ROImatrix       3D ROI matrix, with pixel values 1 for ROI1, 2 for  ROI2, ..
    %
    % Output, sets variables:
    %   tact.activity   time-activity curve in one column per ROI
    %   tact.n          Number of pixels per ROI
    %   tact.stdev      stdev curve in one column per ROI
    disp('TACT entered');
    
    [activity, NPixels, stdev]=generateTACT(imlook4d_current_handles, imlook4d_ROI);
    
    tact.activity=activity';
    tact.n=NPixels';
    tact.stdev=stdev';

     
     
    
    