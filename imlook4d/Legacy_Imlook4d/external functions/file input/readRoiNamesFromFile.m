function imlook4d_ROINames = readRoiNamesFromFile( filePath, imlook4d_ROINames) 

    % imlook4d_ROINames is populated with the numbers 

    [pathstr,name,ext] = fileparts(filePath);
    file = [name ext];  

    try
        newNames = loadtable( filePath );
    catch
        newNames = loadtable( which(file) );
    end
    OLDCOLUMN = 1;
    NEWCOLUMN = 2;


    stop = length(imlook4d_ROINames);  % All 
    % Exclude 'Add ROI' if exists (makes this function more generally applicable)
    if strcmp(imlook4d_ROINames{stop},'Add ROI')
       stop = stop -1; 
    end
    
    
    for i=1:stop
        currentName = imlook4d_ROINames{i};
        start = [];
        
        % Ref ROI
        if startsWith(currentName, '*')
            currentName = currentName(3:end);
            start = '* ';
        end
        
        % Hidden
        if contains(currentName, '(hidden) ')
            currentName = currentName(10:end);
            start = [start '(hidden) '];
        end 
        
        % Set name
        row = find(strcmp(newNames(:,OLDCOLUMN),currentName ));  
        if ~isempty(row) 
            imlook4d_ROINames{i} = [ start newNames{ row, NEWCOLUMN} ];
        end
    end