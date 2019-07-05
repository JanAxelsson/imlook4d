
try
% SPM Fieldtrip causes error
    out = which('ft_annotate');
    %disp(['Removing FieldTrip old Matlab compatibilities  from path : ' parentDir(out) ]);
    warning('off', 'MATLAB:rmpath:DirNotFound');
    rmpath( genpath( [parentDir(out) filesep 'compat'] ) ); % Remove compat directory and downwards
    warning('on', 'MATLAB:rmpath:DirNotFound');
    
    savepath
catch
    
end
