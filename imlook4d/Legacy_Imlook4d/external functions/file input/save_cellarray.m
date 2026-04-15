function save_cellarray(cellarr, filename, header, latex)
% function save_cellarray(cellarr, filename, header, latex)
%
% Save a cell array to an ASCII file, 
% cells separated by an arbitrary delimiter
% (default: tab). In Latex-Mode, the delimiter 
% is ' & ', and the newline is indicated by '\\ \n'.
%
% cellarr: 'm' times 'n' Cell Array
% filename: string, '.txt' is appended if no extension provided
%    'filename=[]' prints to stdout.
% header: arbitrary string that is written to 
%    the file in the first line, e.g. 'date';
%    can be ommitted or empty.
% latex: (boolean)

% Rev.1.0, 02.11.98 (Armin G�nter)
% Rev.1.1, 16.02.99 (A.G.: 'header' can be ommitted or empty)
% Rev.1.2, 11.11.99 (A.G.: '.txt' appended only if apparently no
%    other extension exists)
% Rev.1.3, 12.07.2000 (A.G.: '\r\n' as newline after the header line;
%    optional Latex-Mode)
% Rev.1.4, 26.08.2001 (A.G.: 'filename=[]' prints to stdout.)

if ~exist('latex','var'), latex = 0; end
if latex
   nl = '\\\\\r\n';
   del = ' & ';
else
   nl = '\r\n';
   del = '\t';
end

% create new file or write to stdout:
if ~isempty(filename)
   % check for file extension
   ipt = find(fliplr(filename) == '.');
   if isempty(ipt)
      filename = [filename '.txt'];
   end
   
   fid = fopen(filename, 'W');
   if fid == -1
      error(['Problem writing to the file ' filename])
   end
else
   fid = 1;
end

% write header if existent
if exist('header')
   if ~isempty(header)
      success = fprintf(fid, ['%s' nl], header);
      if ~success
         error(['Problem writing to the file ' filename])
      end
   end
end
[m, n] = size(cellarr);
for i = 1:m
   % create new line
   line = [];
   for j = 1:n-1
      line = [line sprintf(['%s' del], num2str(cellarr{i, j})) ];
   end
   line = [line sprintf('%s', num2str(cellarr{i, n}))];
   success = fprintf(fid, ['%s' nl], line);
   if ~success
      error(['Problem writing to the file ' filename]);
   end
end

%if fid ~= 1, fclose(fid); end
fclose(fid);
