
% INITIALIZE

    % Export to workspace
    StoreVariables
    Export
    % Setup
    cIM = imlook4d_Cdata(:,:,:,imlook4d_frame);
    s = size(imlook4d_Cdata);
    ROI = ( imlook4d_ROI == imlook4d_ROI_number );

    % Determine max value
    valuesInROI = ( cIM( ROI));
    maxVal = max( valuesInROI(:) );

    %
    % Get user input
    %
        prompt={'Threshold level (for instance 12345  or 40%)'};
        title='Threshold level';
        numlines=1;

        defaultanswer = RetriveEarlierValues('RegionGrowth', {'40%'} ); % Read default if exists, or apply these as default
        answer=inputdlg(prompt,title,numlines,defaultanswer);
        if isempty(answer) % cancelled inputdlg
            return
        end

    %
    % First iteration, use max value from input ROI
    %        
        
        % Threshold value
        thresholdString = num2str(answer{1});

        if strcmp( thresholdString(end), '%')
            thresVal=0.01 * maxVal * str2num(thresholdString(1:end-1)) ;
        else
            thresVal=  eval(thresholdString) ;  % If not percent, then whole string is a number
        end

        StoreValues('RegionGrowth', answer ); % Store answer as new dialog default
    


    % 1) Find pos of max value in drawn ROI
        indecesToMaxVal = find( (cIM.*ROI == maxVal) );
        indexToMaxVal = indecesToMaxVal(1); % First index to maxVal, if many
        [x,y,z] = ind2sub(s,indexToMaxVal);
        initPos = [x,y,z] ;
        
    % Region growth
        [P, J] = regionGrowing(cIM, initPos, thresVal);
        
        
    %
    % Second iteration, need new max value
    %

        % Determine new max value (from found binary matrix)
        valuesInROI = ( cIM( J));
        maxVal = max( valuesInROI(:) );

        if strcmp( thresholdString(end), '%')
            thresVal=0.01 * maxVal * str2num(thresholdString(1:end-1)) ;
        else
            thresVal=  eval(thresholdString) ;  % If not percent, then whole string is a number
        end
        
        % Find pos of max value in found ROI
        indecesToMaxVal = find( (cIM.*J == maxVal) );
        indexToMaxVal = indecesToMaxVal(1); % First index to maxVal, if many
        [x,y,z] = ind2sub(s,indexToMaxVal);
        initPos = [x,y,z] ;

    % Region growth
        [P, newROIMatrix] = regionGrowing(cIM, initPos, thresVal); % using default values for maxDist, tfMean, tfFillHoles, tfSimplify


    %
    % Write to all except locked ROI pixels
    %

        % Make matrix of locked pixels
        lockedMatrix = zeros( size(imlook4d_ROI) ,'logical'); % Assume all unlocked
        numberOfROIs = length( imlook4d_current_handles.image.LockedROIs );
        for i=1:numberOfROIs
            lockedMatrix(imlook4d_ROI == i ) = imlook4d_current_handles.image.LockedROIs(i); % Pixels = 0 if locked, 1 if not locked
        end

        newROIMatrix( lockedMatrix) = false; % Remove pixels that are locked from newROI
        
        % Set ROI
         imlook4d_ROI( ROI ) = 0;
         imlook4d_ROI(newROIMatrix) = imlook4d_ROI_number;
        
        

%
% FINALIZE
%

    % Import into imlook4d from Workspace
    ImportUntouched

    ClearVariables
    %disp('SCRIPTS/Threshold.m DONE');