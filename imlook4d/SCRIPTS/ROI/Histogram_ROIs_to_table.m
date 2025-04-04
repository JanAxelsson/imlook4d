StoreVariables
ExportROIs

numberOfRois = length( imlook4d_ROI_data.names );

TAB=sprintf('\t');


% Get user input

    prompt={'Number of bins', 'start (value, or "min" for lowest pixel)', 'end (value, or "max" for highest pixel)'};
    titleString='Number of bins';
    numlines=1;

    defaultanswer = RetriveEarlierValues('HistogramTableDialog', {'20', 'min', 'max' } ); % Read default if exists, or apply these as default
    answer=inputdlg(prompt,titleString,numlines,defaultanswer);

    StoreValues('HistogramTableDialog', answer ); % Store answer as new dialog default

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

    
% Calculate histogram for current frame

    header = [];  % For clipboard
    format = []; 
    
    headerForMatlabDisplayFormat = []; % For Matlab display
    headerForMatlabDisplay = []; 
    
    data = [];
    
    HIST_FORMAT_FIRST_COL = '% 15.5f';
    HIST_FORMAT = '% 15d';
    HEADER_FORMAT_FIRST_COL = '% 12s'; % Fill leading edge
    HEADER_FORMAT = '% 17s'; % Fill leading edge
    
    % For screen printout    
    lengthLongestRoiName = max( cellfun('length', imlook4d_ROI_data.names) );
    spaceAfterRoiName = sprintf( ['%' num2str(lengthLongestRoiName)  's'], '');
    
    for i = 1 : numberOfRois
        
        % Histogram data for current ROI and frame
        [N,edges] = histcounts(imlook4d_ROI_data.pixels{i}(:,imlook4d_frame), bins, 'BinLimits',[first ,last] );
        
        % First column inserted here
        if (i == 1)
            header = [ 'bin         ' ];
            headerForMatlabDisplay = [ "bin"];
            data = edges(1 : (end - 1) )'; % left side of bin (skip last value)
            format = HIST_FORMAT_FIRST_COL;
            headerForMatlabDisplayFormat = HEADER_FORMAT_FIRST_COL; % Start at left edge
        end
    
        data = [ data N'];
        
        % Format for Clipboard
        header = [ header TAB  imlook4d_ROI_data.names{i} ]; 
        format = [ format '\t' HIST_FORMAT]; 
        
        headerForMatlabDisplay = [ headerForMatlabDisplay imlook4d_ROI_data.names{i} ];
        headerForMatlabDisplayFormat = [ headerForMatlabDisplayFormat HEADER_FORMAT  ];
        
        if (lengthLongestRoiName < length('ROI-name') )
            lengthLongestRoiName = length('ROI-name');
        end
    end

    

% Print data

    
    total = header; % Build for Clipboard
    disp( [ '<strong>' sprintf( headerForMatlabDisplayFormat, headerForMatlabDisplay ) '</strong>']); % Display in Matlab
    
    for i = 1 : length(data)
        row = sprintf( [ format ], data(i,:) ); % Format for Matlab display
        disp(row); 
        
        total =[ total sprintf('\n') row ];   % Format for Clipboard
    end  


    disp(' ');
    
    clipboard ( 'copy', total );
    
    
    disp(' ');
    disp('(HISTOGRAM values in clipboard) ');
    disp(' ');


    
    
    
ClearVariables  