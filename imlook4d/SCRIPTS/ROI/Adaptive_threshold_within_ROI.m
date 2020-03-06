StoreVariables;
Export;

%
% Get user input
%
    prompt={'Sensitivity (between 0 and 1)', ...
        'Background level'};
    title='Adaptive threshold sensitivity';
    numlines=1;

    defaultanswer = RetriveEarlierValues('AdaptiveThreshold', {'0.1', '0'} ); % Read default if exists, or apply these as default
    answer=inputdlg(prompt,title,numlines,defaultanswer);
    if isempty(answer) % cancelled inputdlg
        return
    end
    StoreValues('AdaptiveThreshold', answer ); % Store answer as new dialog default

    sensitivity = str2num(answer{1});
    background = str2num(answer{2});

%
% Make adaptive threshold using whole 3D image (current frame)
%
    % Background--subracted 3D volume
    I = imlook4d_Cdata(:,:,:,imlook4d_frame) - background; 

    % Normalize to max in ROI
    searchArea = (imlook4d_ROI == imlook4d_ROI_number); 
    valuesInSearchArea = I(searchArea);
    I = I / max( valuesInSearchArea(:));

    % Adaptive thresholding
    T = adaptthresh(I, sensitivity); 
    adaptiveWholeImage = imbinarize(I,T); % adaptive threshold whole 3D volume

    % Draw new ROI
    imlook4d_ROI(searchArea) = 0; % Clean original ROI
    adaptiveCurrentROI = (searchArea & adaptiveWholeImage); % Keep only that within searchArea
    imlook4d_ROI(adaptiveCurrentROI) = imlook4d_ROI_number; 

Import
ClearVariables



