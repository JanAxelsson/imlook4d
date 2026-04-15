function pix = pixels( mm, mm_per_voxel )
% Convert between pixels and mm
%
% Example:
%    pixels( [ 3.59, 3.40, 4.32], [ 1, 1, 3.27] )

pix = mm ./ mm_per_voxel;