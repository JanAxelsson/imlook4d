% Same as Grow_ROI, except code-section at the bottom

ALGORITHM = 'FloodFill3D';
%ALGORITHM = 'regionGrowing';

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
        if isempty(answer) % cancelled inputdlg
            return
        end
        thresholdString = num2str(answer{1});
        
        BELOW_THRESHOLD = strcmp( '<', thresholdString(1) );
        if BELOW_THRESHOLD
           thresholdString = thresholdString(2:end); % Remove '<' 
           % Error message if bad inputs
           if strcmp( thresholdString(end), '%')
               dispRed('ERROR: < and % is an impossible combination');
               return
           end
        end
        
        if strcmp( '>', thresholdString(1) )
           thresholdString = thresholdString(2:end); % Remove '>' 
        end
    %
    % Use max value from input ROI (which will be within ROI)
    %        
        
        % Threshold value

        if strcmp( thresholdString(end), '%')
            thresVal=0.01 * maxVal * str2num(thresholdString(1:end-1)) ;
        else
            thresVal=  eval(thresholdString) ;  % If not percent, then whole string is a number
        end

        StoreValues('RegionGrowth', answer ); % Store answer as new dialog default
    


    % Find pos of max value in drawn ROI
        indecesToMaxVal = find( (cIM.*ROI == maxVal) );
        indexToMaxVal = indecesToMaxVal(1); % First index to maxVal, if many
        [x,y,z] = ind2sub(s,indexToMaxVal);
        
        if BELOW_THRESHOLD
            minVal = min( valuesInROI(:) );
            indecesToMinVal = find( (cIM.*ROI == minVal) );
            indecesToMinVal = indecesToMinVal(1); % First index to maxVal, if many
            [x,y,z] = ind2sub(s,indecesToMinVal);
        end
        
        
        initPos = [x,y,z] ;
        
    % Region growth
        if strcmp(ALGORITHM,'regionGrowing');
        	[P, J] = regionGrowing(cIM, initPos, thresVal);
        end
        if strcmp(ALGORITHM,'FloodFill3D');
            J = FloodFill3D(cIM, initPos, thresVal,BELOW_THRESHOLD, imlook4d_current_handles);
        end
        
 
    % Keep only voxels within original ROI
            imlook4d_ROI( ROI ) = 0;
            imlook4d_ROI( J & ROI) = imlook4d_ROI_number;



%
% FINALIZE
%

    % Import into imlook4d from Workspace
    ImportUntouched

%     % Store default until next tim
%     imlook4d_store.RegionGrowth.inputs =  answer;

    ClearVariables
    %disp('SCRIPTS/Threshold.m DONE');