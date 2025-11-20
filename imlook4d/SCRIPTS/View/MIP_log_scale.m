% MIP_log_scale.m

% Start script
    StartScript;

% Modify
imlook4d_Cdata=log( max(imlook4d_Cdata,[],3) + 0.01 );


% Set positions to a single slice
singleSliceIndex = ceil( length( imlook4d_current_handles.image.sliceLocations) / 2) ;
imlook4d_current_handles.image.sliceLocations = imlook4d_current_handles.image.sliceLocations( singleSliceIndex);
imlook4d_current_handles.image.imagePosition = { imlook4d_current_handles.image.imagePosition{ singleSliceIndex}  };

WindowTitle('MIP','prepend')

% Finish script
EndScript
