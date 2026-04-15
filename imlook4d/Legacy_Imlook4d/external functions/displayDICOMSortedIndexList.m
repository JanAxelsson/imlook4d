function displayMatrix(matrix)

% Called from links created in parseHTMLTableRow
% which is initially called by the script Display_Variables

cnames = {'frame t','image index','slice pos', 'acq t', 'date', 'series uid', 'trig t', 'image nr'};

f = figure('Position', [100 100 752 700]);
t = uitable('Parent', f, 'Position', [25 25 700 650],'ColumnName',cnames);
set(t, 'Data', matrix);