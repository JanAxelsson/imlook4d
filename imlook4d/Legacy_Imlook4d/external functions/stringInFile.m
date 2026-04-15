function out=stringInFile( fileName, searchString)
% Verify if searchString exists in file.
% Returns 1 if the searchString exists in the file (fileName), where file
% is in MATLAB search path.
    a=fileread(fileName);
    positions=strfind(lower(a),lower(searchString));
    
    out=~isempty(positions);