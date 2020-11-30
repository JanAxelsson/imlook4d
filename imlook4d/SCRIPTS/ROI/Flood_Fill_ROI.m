ALGORITHM = 'FloodFill3D';   % Stops at locked ROI
%ALGORITHM = 'regionGrowing';% Does not stop at locked ROI -- (but, does not over write locked ROI)

% INITIALIZE

    % Export to workspace
    StoreVariables
    Export
    % Setup
    cIM = imlook4d_Cdata(:,:,:,imlook4d_frame);
    s = size(cIM);
    ROI = ( imlook4d_ROI == imlook4d_ROI_number );

    % Determine max value
    valuesInROI = ( cIM( ROI));
    maxVal = max( valuesInROI(:) );

    %
    % Get user input
    %
        prompt={'Threshold level (for instance 12345, <20, or 40%)'};
        title='Threshold level';
        numlines=1;

        defaultanswer = RetriveEarlierValues('RegionGrowth', {'40%'} ); % Read default if exists, or apply these as default
        answer=inputdlg(prompt,title,numlines,defaultanswer);
        if isempty(answer) % cancelled inputdlg and clean up
            ClearVariables
            clear ALGORITHM
            return
        end
        clear title; % This variable creates problem for many scripts, if remaining after a crash
        
        thresholdString = num2str(answer{1});
        
        BELOW_THRESHOLD = strcmp( '<', thresholdString(1) );
        if BELOW_THRESHOLD
           thresholdString = thresholdString(2:end); % Remove '<' 
           % Error message if bad inputs
           if strcmp( thresholdString(end), '%')
               dispRed('ERROR: < and % is an impossible combination');
               ClearVariables
               return
           end
        end
        
        if strcmp( '>', thresholdString(1) )
           thresholdString = thresholdString(2:end); % Remove '>' 
        end

    %
    % First iteration, use max value from input ROI
    %        
        
        % Threshold value

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
        if strcmp(ALGORITHM,'regionGrowing');
        	[P, J] = regionGrowing(cIM, initPos, thresVal);
        end
        if strcmp(ALGORITHM,'FloodFill3D');
            J = FloodFill3D(cIM, initPos, thresVal,BELOW_THRESHOLD, imlook4d_current_handles);
        end
        
        
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

        if strcmp(ALGORITHM,'regionGrowing');
        	[ P, newROIMatrix] = regionGrowing(cIM, initPos, thresVal); 
        end
        if strcmp(ALGORITHM,'FloodFill3D');
            newROIMatrix = FloodFill3D(cIM, initPos, thresVal,BELOW_THRESHOLD, imlook4d_current_handles);
        end

    %
    % Write to all except locked ROI pixels (NOTE : only needed for algorithm=regionGrowing)
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