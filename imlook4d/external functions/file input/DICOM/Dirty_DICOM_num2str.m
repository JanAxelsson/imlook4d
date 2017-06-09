function valueString=Dirty_DICOM_num2str(value, length)
%
% Formats a value to an exponential format with fixed witdth= length
%
% input:
%   value  - a matlab number
%   length - allowed number of characters
%
% output:
%   valueString - a string representation of the number
%
% Jan Axelsson, 080926
%


                    
%
% A string of characters representing either a fixed point number or a floating point number. A fixed
% point number shall contain only the characters0-9 with an optional leading "+" or "-" and an
% optional "." to mark the decimal point. A
% floating point number shall be conveyed asdefined in ANSI X3.9, with an "E" or "e" to
% indicate the start of the exponent. Decimal Strings may be padded with leading or trailing
% spaces. Embedded spaces are not allowed.
%length=indecesToScaleFactor{i}.high - indecesToScaleFactor{i}.low;
%valueString=num2str(scale_factor, '%12.12f');
%valueString=char(uint8(valueString(1:length+1))'  );
                        
                        
        precision=length-5;      %remove 'X.' '-eY' where X and Y are single numbers
        formatString=['%' num2str(length) '.' num2str(precision) 'g'];
        a=num2str(value, formatString);
        
         % Remove zeros in exponential if exist
        a = strrep(a, 'e-0', 'e-');a = strrep(a, 'e-0', 'e-');a = strrep(a, 'e+0', 'e+');  a = strrep(a, 'e+0', 'e+');
        
        % If valueString is too long, try again
        if (size(a,2)>length)
            % If length too long, it is most likely due to that the number
            % of digits in the exponential is too high.
            precision=precision-1;
            
            %
            % Repeat above procedure again;
            %
            formatString=['%' num2str(length) '.' num2str(precision) 'e'];
            a=num2str(value, formatString);

             % Remove zeros in exponential if exist
            a = strrep(a, 'e-0', 'e-');a = strrep(a, 'e-0', 'e-');a = strrep(a, 'e+0', 'e+');  a = strrep(a, 'e+0', 'e+');
        end
        
        % Padd with trailing spaces 
        a=[a '   '];
        
        valueString=char(uint8(a(1:length))'  );
        
        

