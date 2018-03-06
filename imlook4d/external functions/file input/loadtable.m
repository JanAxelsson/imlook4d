function A = loadtable(filename, delimiter, hlines)

% function A = loadtable(filename, delimiter, hlines)
%
% Load an ASCII text file into a cell array.
% Default delimiter is ASCII-Code 9 (TAB); 
% leave delimiter empty to use this default.
% The delimiter can be provided as a string character.
% filename: (string)
% delimiter: (scalar) ASCII-Code
% hlines: 'hlines' header lines will be skipped prior of 
%   scanning.
%
% The number of columns is determined out of
% the first line. If the text file contains rows
% with a different number of elements, no useful
% results can be expected. The remaining elements
% that can't be filled into the rectangular matrix
% 'A' will simply be discarded!
%
% See also: 'save_cellarray', 'numintable'

% Rev.1.0, 16.02.99 (Armin G?nter)
% Rev.2.0, 14.05.99 (A.G.: possibility to skip header lines,
%    use 'fgetl' instead of parsing for lines with 'strtok')
% Rev.2.1, 18.04.2001 (A.G. 'delimiter' can be empty)
% Rev.2.2  06.03.2018 (Jan Axelsson, skip commnent rows starting with #)

if ~exist('delimiter'), delimiter = 9; end
if isempty('delimiter'), delimiter = 9; end
if ~exist('hlines'), hlines = 0; end

fid = fopen(filename);
% skip header
if floor(hlines) >= 1
   for i = 1:hlines
      line = fgets(fid); 
   end
end
    
line = fgetl(fid);
if isequal(line, -1)
   error('No lines in file!')
end


% determine number of columns
i = 1;
while ~isempty(line)
   [A{i}, line] = strtok(line, delimiter);
   i = i + 1;
end
columns = i -1;

while ~isequal(line,-1) 
    
   isComment = startsWith(  strtrim(line),'#' );
   while ~isempty(line) && ~isComment
      [A{i}, line] = strtok(line, delimiter);
      i = i + 1;
   end
   line = fgetl(fid);
end

fclose(fid);

% reshape to matrix
% (no error treatment)
rows = floor((i-1)/columns);
rem = mod(i-1, columns);
A = reshape(A(1:rows*columns), columns, rows)';



function out = startsWith(s1,s2) % Emulate Matlab 2017 function
    try
        out = strcmp( s1(1), s2); 
    catch
       out = 0; % false if fails
    end
    