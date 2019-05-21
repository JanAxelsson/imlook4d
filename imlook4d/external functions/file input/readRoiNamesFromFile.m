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


    stop = length(imlook4d_ROINames)-1; % Exclude 'Add ROI'
    for i=1:stop
        currentName = imlook4d_ROINames{i};
        row = find(strcmp(newNames(:,OLDCOLUMN),currentName ));
        if ~isempty(row) 
            imlook4d_ROINames{i} = newNames{ row, NEWCOLUMN};
        end
    end