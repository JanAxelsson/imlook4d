function out = imlook4d_fliplr( matrix)

try
    % Recommended to use by Matlab instead of flipdim
    out = fliplr(matrix);
catch
    % Matlab 2013a only allows 2D matrix for fliplr
    out = flipdim(matrix,2);
end