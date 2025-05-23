% Histogram_ROI.m
%
%
% Jan Axelsson


% Initialize
StoreVariables
Export
ROI_data_to_workspace


% Get user input
prompt={'Number of bins'};
titleString='Number of bins';
numlines=1;


prompt={'Number of bins', 'start (value, or "min" for lowest pixel)', 'end (value, or "max" for highest pixel)'};
titleString='Number of bins';
numlines=1;

defaultanswer = RetriveEarlierValues('HistogramROI', {'20', 'min', 'max' } ); % Read default if exists, or apply these as default
answer=inputdlg(prompt,titleString,numlines,defaultanswer);
StoreValues('HistogramROI', answer ); % Store answer as new dialog default

if isempty(answer)  % cancelled inputdlg and clean up
    ClearVariables
    return
end
bins = str2num(answer{1});% Number of histogram bins


if strcmp( answer{2}, 'min')
    first = min( imlook4d_ROI_data.min(:) );
else
    first = str2num(answer{2});% Number of histogram bins
end

if strcmp( answer{3}, 'max')
    last = max( imlook4d_ROI_data.max(:) );
else
    last = str2num(answer{3});% Number of histogram bins
end




if isempty(answer)  % cancelled inputdlg and clean up
    ClearVariables
    return
end
bins = str2num(answer{1});% Number of histogram bins

% Set up histogramming
low = first
high = last
step = ceil( (high - low) / bins );
step =  (high - low) / bins ;


oneFrame=imlook4d_Cdata(:,:,:,imlook4d_frame);
data =oneFrame(imlook4d_ROI==imlook4d_ROI_number);

% Draw histogram
    figure;
    histogram( data, [ low  : step : high] );

% Set labels and title
    xlabel( 'Pixel values' );
    ylabel( 'Number' );

    titleText = [ 'Histogram of pixels in ROI = ' imlook4d_ROINames{imlook4d_ROI_number} ];
    if ( size(imlook4d_Cdata,4) > 1 )
        titleText = [ titleText '  (frame ' num2str(imlook4d_frame) ')'];
    end
    title( titleText,'Interpreter','none');

% Set x-axis limits
    g = gcf;
    a = g.Children;
    a.XLim = [ low  high];

% Make space for information box
    textHeight = 0.15;
    pos = a.Position;
    pos(2) = pos(2) + textHeight;
    pos(4) = pos(4) - textHeight;
    a.Position = pos;

% Print information    

    % Simple statistics
    meanValue = mean(data(:));
    medianValue = median(data(:));
    stdevValue = std(data(:));
    
    
    maxValue = max(data(:));
    minValue = min(data(:));
    numberOfPixels = length(data(:));
    
    % Volume
    try
        dX=imlook4d_current_handles.image.pixelSizeX;  % mm
        dY=imlook4d_current_handles.image.pixelSizeY;  % mm
        dZ=imlook4d_current_handles.image.sliceSpacing;% mm
        dV=abs( dX*dY*dZ/1000 );  % cm3
    catch
        dX=0;
        dY=0;
        dZ=0;
        dV=0;
    end
    
    volValue = numberOfPixels * dV;
    
    % Statistical toolbox
    try
        STAT_TOOLBOX = 1;
        skewnessValue = imlook4d_skewness(data(:));
        kurtosisValue=imlook4d_kurtosis(data(:));
    catch
        % Missing Statistical toolbox
        STAT_TOOLBOX = 0;
    end
    
    s_left = { ['average = ' num2str(meanValue) ] ...
        ['median = ' num2str(medianValue) ] ...
        ['pixels  = ' num2str(numberOfPixels) ] ...
       };
   
       s_mid= {  ...
        ['max = ' num2str(maxValue) ] ...
        ['min = ' num2str(minValue) ] ...
        ['volume = ' num2str(volValue) 'cm^3'] ...
       };
   
   
    
    if STAT_TOOLBOX  
       s_right = { ['stdev = ' num2str(stdevValue) ]...
           ['skewness = ' num2str(skewnessValue) ] ...
        ['kurtosis = ' num2str(kurtosisValue) ] ...
       };
    else
        % Missing Statistical toolbox
        s_right = { ''  };
    end
    
    
    a1 = annotation ('textbox',[pos(1) 0.0 pos(3) textHeight], 'FitBoxToText', 'on', 'EdgeColor', g.Color,'string',s_left );
    a2 = annotation ('textbox',[0.45 0.0 pos(3) textHeight], 'FitBoxToText', 'on', 'EdgeColor', g.Color,'string',s_mid );
    a3 = annotation ('textbox',[0.7 0.0 pos(3) textHeight], 'FitBoxToText', 'on', 'EdgeColor', g.Color,'string',s_right );
        


% Finish    
    set(gcf,'NumberTitle','off') %don't show the figure number
    windowTitle = [ 'Histogram : ' imlook4d_current_handles.figure1.Name ];
    set(gcf,'Name', windowTitle) % set window title


    ClearVariables    

