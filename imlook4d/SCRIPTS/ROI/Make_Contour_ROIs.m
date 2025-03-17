StoreVariables
Export;
ROI_data_to_workspace;

orgROINumber = imlook4d_ROI_number;
orgRoi = imlook4d_ROI; % Spara alla roi-ar innan jag mixtrar

%
% INPUT
%

    % Get user input
    defaultanswer = RetriveEarlierValues('MakeContourRois', {'100%','0', '5'} ); 
    prompt={'Max value  (for instance "12345"  or "100%")',...
            'Min value  (for instance "12345"  or "40%")',...
            'Number of new Rois  '};
    title='Threshold levels';
    numlines=1;
    answer=inputdlg(prompt,title,numlines,defaultanswer);

    if isempty(answer)  % cancelled inputdlg and clean up
        ClearVariables
        return
    end
    StoreValues('MakeContourRois', answer ); % Store answer as new dialog default

    maxValueString = answer{1};
    minValueString = answer{2};
    Nlevels = str2num( answer{3});


    % maxValue
    maxLevel = imlook4d_ROI_data.max(orgROINumber);            
    if strcmp( maxValueString(end), '%')
        maxInputPercent = str2num(maxValueString(1:end-1)) ;
        maxValue = 0.01 * maxInputPercent *  maxLevel ;
    else
        maxValue=  eval(maxValueString) ;  % If not percent, then whole string is a number
    end


    % minValue
    minLevel = imlook4d_ROI_data.max(orgROINumber);            
    if strcmp( minValueString(end), '%')
        minInputPercent = str2num(minValueString(1:end-1)) ;
        minValue = 0.01 * minInputPercent *  minLevel ;
    else
        minValue=  eval(minValueString) ;  % If not percent, then whole string is a number
    end

%
% MAKE ROIs
%

    low = minValue;
    step = (maxValue - minValue) / Nlevels;
    high = minValue + step;
    disp( [ 'Low  value = ' num2str(low) ]);
    disp( [ 'High value = ' num2str(high) ]);
    
    for i = 1 : Nlevels
        
        % Gör en ny ROI
        INPUTS = Parameters( { [ num2str(i) ' - ' imlook4d_ROINames{ orgROINumber} ] } );
        MakeROI
        newROINumber = length( imlook4d_ROINames) - 1;
        
        % Calculate levels for this ROI

        % Set pixels inside original ROI in interval low - high
        imlook4d_ROI( ...
            (imlook4d_ROI == orgROINumber ) & ...
            (imlook4d_Cdata(:,:,:,imlook4d_frame) >= low) & ...
            (imlook4d_Cdata(:,:,:,imlook4d_frame)  <= high) ...
         ) = newROINumber;
        
        % Values for next iteration
        low = low + step;
        high = high + step;

    end

%
% FINISH
%

    Import
    %EndScript

