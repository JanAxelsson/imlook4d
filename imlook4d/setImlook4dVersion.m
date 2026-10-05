% 
% This script forces imlook4d to use Legacy implementation (pre Matlab 2024)
% 
% Useage:
%
%   setImlook4dVersion 'legacy'  % Sets old version of imlook4d (which is NOT currently developed)
%   setImlook4dVersion 'new'     % Sets new version of imlook4d (which IS currently developed)
%
% The only use case for the " setImlook4dVersion 'new' " command is to
% reset if you have forced 'legacy'
%
% Typically if you just run imlook4d command it uses the correct version.
% This script is only to try old versions on a new system.

function setImlook4dVersion( newOrLegacy )




% Locate the installed imlook4d folder
[ d f e] = fileparts( which('imlook4d') ); 

% Build and prepend the legacy plugin path
legacyFolder = [ d filesep 'Legacy_Imlook4d'];
addpath( genpath( legacyFolder), '-begin'); 

% Mark legacy configuration in app data
setappdata(0, 'imlook4d_path_configured', false);

switch newOrLegacy
    case 'new'
        setappdata(0, 'imlook4d_selected_version', 'new');

    case 'legacy'
        setappdata(0, 'imlook4d_selected_version', 'legacy');

    otherwise
        dispRed("This function forces the version of imlook4d  (this is for development only)." )
        dispRed("You need to give argument 'new' or 'legacy' " )
end