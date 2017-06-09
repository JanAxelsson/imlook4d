function tf = areTheseToolboxesInstalled(requiredToolboxes)
%ARETHESETOOLBOXESINSTALLED takes a cell array of toolbox names and checks whether they are currently installed
% SYNOPSIS tf = areTheseToolboxesInstalled(requiredToolboxes)
%
% INPUT requiredToolboxes: cell array with toolbox names to test for. Eg. 
%        {'MATLAB','Image Processing Toolbox'}
%
% OUTPUT tf: true or false if the required toolboxes are installed or not
%%%%%%%%%%%%%%%%%%%%%%%%%%

% get all installed toolbox names
v = ver;
% toolbox names in a cell array
[installedToolboxes{1:length(v)}] = deal(v(:).Name);

% check 
tf = all(ismember(requiredToolboxes,installedToolboxes));