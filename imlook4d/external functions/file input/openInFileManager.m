function openInFileManager(myDir)

% Windows PC    
if ispc
    C = evalc(['!explorer ' '' myDir '']);

% Unix or derivative
elseif isunix

    % Mac
    if ismac
        C = evalc(['!open -n ' myDir]);

    % Linux
    else
        fMs = {...
            'xdg-open'   % most generic one
            'gvfs-open'  % successor of gnome-open
            'gnome-open' % older gnome-based systems               
            'kde-open'   % older KDE systems
           };
        C = '.';
        ii = 1;
        while ~isempty(C)                
            C = evalc(['!' fMs{ii} ' ' myDir]);
            ii = ii +1;
        end

    end
else
    error('Unrecognized operating system.');
end

if ~isempty(C)
    error(['Error while opening directory in default file manager.\n',...
        'The reported error was:\n%s'], C); 
end