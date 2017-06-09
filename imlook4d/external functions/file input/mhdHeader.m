function outputString=mhdHeader( filePath, parameterName)
% This function searches an mhdHeader for a parameter and returns the
% parameter value as a string
%
% The mhdHeader syntax
% A key-value pair definition is specified as in the example:
% DimSize = 256 256 47
%
% Jan Axelsson, 2011-JAN-18
            fid=fopen(filePath);
    
            while 1
                tline = fgetl(fid);
                if ~ischar(tline),   break,   end

                try
                    [token, remain] = strtok(tline,'='); % Tokenize
                    token = regexprep(token, '=', ' ');   % Replace "!" with " "
                    token=strtrim(token);                 % Trim spaces
                    
                    [remain, remain2] = strtok(remain,';'); % Remove trailing comments
                    
                    %if strcmp( token, parameterName)
                    if findstr(token, parameterName)  % Find part of string matching
                        outputString=strtrim( remain(3:end));
                    end
                catch 
                    disp(['interFileHeader error while finding parameter with name=' parameterName ]);
                end
            end            
            