StartScript

% Find most narrow x,y that fits ROI in all slices
[row,col] = find(sum( imlook4d_ROI, 3) );
x1 = min(row);
x2 = max(row);
y1 = min(col);
y2 = max(col);

% Truncate in x,y
imlook4d_Cdata = imlook4d_Cdata( x1:x2, y1:y2, :, :); 
imlook4d_ROI = imlook4d_ROI( x1:x2, y1:y2, : ); 

EndScript