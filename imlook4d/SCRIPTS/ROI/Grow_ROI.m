
% INITIALIZE

    % Export to workspace
    StoreVariables
    Export

    % Setup
    cIM = imlook4d_Cdata;
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

    % Threshold value
        thresholdString = num2str(answer{1});

        if strcmp( thresholdString(end), '%')
            thresVal=0.01 * maxVal * str2num(thresholdString(1:end-1)) ;
        else
            thresVal=  eval(thresholdString) ;  % If not percent, then whole string is a number
        end

    StoreValues('RegionGrowth', answer ); % Store answer as new dialog default
    


    % Find pos of max value
        indecesToMaxVal = find( (imlook4d_Cdata.*ROI == maxVal) );
        indexToMaxVal = indecesToMaxVal(1); % First index to maxVal, if many
        [x,y,z] = ind2sub(s,indexToMaxVal);
        initPos = [x,y,z] ;

    % Region growth
        [P, J] = regionGrowing(cIM, initPos, thresVal); % using default values for maxDist, tfMean, tfFillHoles, tfSimplify
        %[P, J] = regionGrowing(cIM, initPos, thresVal, maxDist, tfMean, tfFillHoles, tfSimplify)

    % Set ROI
        imlook4d_ROI(J) = imlook4d_ROI_number;


%
% FINALIZE
%

    % Import into imlook4d from Workspace
    ImportUntouched

    % Store default until next tim
    imlook4d_store.RegionGrowth.inputs =  answer;

    ClearVariables
    %disp('SCRIPTS/Threshold.m DONE');