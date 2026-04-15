StoreVariables
Export



timeScale = imlook4d_time';
duration = imlook4d_duration';
activity = zeros( size(imlook4d_time))';


[file,path] = uiputfile( {...
    '*.sif', 'Turku (blood/weight)  (*.sif)' ...
    }, ...
    'Export times to sif file', 'TACT.sif');

[pathstr,name,ext] = fileparts(file);  % To get extension
fullPath=[path file];

%
% Copied from SaveTact.m
%

    % Simplified sif file, from one ROI
   

    % Header info
    scan_start_time = 'xx/xx/xxxx xx:xx:xx'
    number_of_frames = length(imlook4d_time);
    number_of_columns = 2 + size(activity,2) ;
    SIF_version = '1';
    study_ID = 'xxxx';
    isotope = 'X-XX';

    if (  size(activity,2) == 1 )
        activity = [ activity activity ];  % Sif seems to require 4 columns (minimum)
        number_of_columns = 2 + size(activity,2) ;
    end

    tactHeader=[sprintf(['%s' '\t'], scan_start_time, num2str(number_of_frames), num2str(number_of_columns), SIF_version, study_ID, isotope) ];
    tactHeader=tactHeader(1:end-1); % Remove last TAB

    unitFactor = 1; % Do nothing
    try

        save_cellarray( num2cell([ timeScale (timeScale+duration) unitFactor*double(activity) ]), fullPath, tactHeader );
    catch
        %disp('You selected not to save TACT curve');
    end

Import
%ClearVariables
