function displayMatrix(matrix, matrixName)

% Called from links created in parseHTMLTableRow
% which is initially called by the script Display_Variables


f = figure('Position', [100 100 752 700], 'Name', matrixName, 'NumberTitle', 'off');
t = uitable('Parent', f, 'Position', [25 25 700 650]);
set(t, 'Data', matrix);

% Define matrix headers here
if strcmp( matrixName, 'imlook4d_current_handles.image.DICOMsortedIndexList')
    cnames = {'frame t','image index','slice pos', 'acq t', 'date', 'series uid', 'trig t', 'image nr'};
    set(t,'ColumnName',cnames );
end