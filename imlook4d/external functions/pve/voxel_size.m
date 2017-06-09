function voxel_size = voxel_size( imlook4d_handles)
    
voxel_size = [ ...
    imlook4d_handles.image.pixelSizeX, ...
    imlook4d_handles.image.pixelSizeX, ...
    imlook4d_handles.image.sliceSpacing ...
    ]