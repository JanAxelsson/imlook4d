StartScript

% Find most narrow x,y that fits ROI in all slices
[row,col] = find(sum( imlook4d_ROI, 3) );
x1 = min(row);
x2 = max(row);
y1 = min(col);
y2 = max(col);

% Find z positions of ROI
nonZeroSlices = find( sum( sum( imlook4d_ROI, 1), 2) );
z1 = min(nonZeroSlices);
z2 = max(nonZeroSlices);

% Truncate in x,y,z
imlook4d_Cdata = imlook4d_Cdata( x1:x2, y1:y2, z1:z2, :); 
imlook4d_ROI = imlook4d_ROI( x1:x2, y1:y2, z1:z2 ); 

% Set slice so that current slice is within new z-range
if imlook4d_slice > size(imlook4d_Cdata,3)
    set(imlook4d_current_handles.SliceNumEdit,'String', num2str( size(imlook4d_Cdata,3)));
    set(imlook4d_current_handles.SliceNumSlider,'Value', size(imlook4d_Cdata,3));
end


EndScript