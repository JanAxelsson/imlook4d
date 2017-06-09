StartScript

ROI_data_to_workspace

imlook4d_ROI_data.centroid{imlook4d_ROI_number}
imlook4d_ROI_data.dimension{imlook4d_ROI_number}

x0 =  round( imlook4d_ROI_data.centroid{imlook4d_ROI_number}.x );
y0 =  round( imlook4d_ROI_data.centroid{imlook4d_ROI_number}.y );
z0 =  round( imlook4d_ROI_data.centroid{imlook4d_ROI_number}.z );

x1 =  x0 - round( 0.5 * imlook4d_ROI_data.dimension{imlook4d_ROI_number}.x );
y1 =  y0 - round( 0.5 * imlook4d_ROI_data.dimension{imlook4d_ROI_number}.y );
z1 =  z0 - round( 0.5 * imlook4d_ROI_data.dimension{imlook4d_ROI_number}.z );

x2 =  x0 + round( 0.5 * imlook4d_ROI_data.dimension{imlook4d_ROI_number}.x );
y2 =  y0 + round( 0.5 * imlook4d_ROI_data.dimension{imlook4d_ROI_number}.y );
z2 =  z0 + round( 0.5 * imlook4d_ROI_data.dimension{imlook4d_ROI_number}.z );

% Different from Trim_3D
imlook4d_Cdata = imlook4d_Cdata( x1:x2, y1:y2, :, :); 
imlook4d_ROI = imlook4d_ROI( x1:x2, y1:y2, :, :); 

EndScript