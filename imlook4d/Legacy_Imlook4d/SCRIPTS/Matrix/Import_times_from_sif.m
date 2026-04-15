StoreVariables
Export

% Get times from sif file - if exists (Turku data has that)
    try 
         [file,path] = uigetfile( ...
                            {
                           '*.sif',  'Turku frame times file (*.sif)';...
                           '*',  'All Files'} ...
                           ,'Select one file to open');
                           
                        fullPath=[path file];
                        cd(path);
        
        
        
        fullPath=[path filesep file];  % hdr file (img file was opened) 
        fid=fopen(fullPath);

        C = textscan(fid, '%f %f %f %f %f', 'headerLines', 1)
        imlook4d_time=C{1}';
        imlook4d_duration= (C{2}-C{1})';                           
        [ 'time' 'duration'];
        [imlook4d_time imlook4d_duration];

        fclose(fid);
    catch
        % Sif file does not exist
    end

Import
%ClearVariables
