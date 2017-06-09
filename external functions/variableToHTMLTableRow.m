 function outstring=variableToHTMLTableRow(message, variable, variableName)  
% USES:
%   parseHTMLTableRow
%       displayMatrix

 
            maxNumberOfElements=100;  % Number of lines to display   
            TAB=sprintf('\t');
            EOL=sprintf('\n');
 
           %disp([a(i).name '  ' a(i).class])

           % Get struct info
            if strcmp( class(variable) ,'struct') 
                str=['struct [' num2str( size(variable)) ']']; 
            end  
            if strcmp( class(variable) ,'struct') 
              str=['struct [' num2str(  size(variable)) ']']; 
            end 
            if strcmp( class(variable) ,'cell') 
              str=['struct [' num2str(  size(variable)) ']']; 
            end
           
            % Display variables with few bytes
            if  numel(variable) < maxNumberOfElements
                
                 if strcmp( class(variable) ,'double') str=num2str( variable); end
                 if strcmp( class(variable) ,'single') str=num2str( variable); end
                 if strcmp( class(variable) ,'logical') str=num2str(variable); end
                 if strcmp( class(variable) ,'char') str=variable; end
                    
            % Display variables with many bytes (make links)   
            else
                
                % Display matrix using imlook4d or imagesc
                if ( strcmp( class(variable) ,'double') || strcmp( class(variable) ,'single') || strcmp( class(variable) ,'int8') )
                    
                    str=num2str(  size(variable) );
                    str=[ 'matrix [' str ']'];
                    

                    
                    % 2D (use imagesc)
                    if (size(variable,3)==1)
                        str=['<a href="matlab:figure(''Name'',''' variableName ''' , ''NumberTitle'', ''off'');imagesc(' variableName  ');'...
                            'colorbar;xlabel(''column (second index)'');ylabel(''row (first index)'')">' ...
                            str '</a>']; 
                    else
                    % Many Dimensions (use imlook4d)
                        str=['<a href="matlab:imlook4d(' variableName ');'...
                            'set(gcf, ''Name'',''' variableName ''')' ...
                            '">' str '</a>']; 
                    end
                    
                    % 2D Few columns (make a table)
                    if (size(variable,2)<10)
                        str=num2str(  size(variable) );
                        str=[ 'matrix [' str ']'];
                        str=['<a href="matlab:displayMatrix(' variableName ...
                            ', ''' variableName ''' ) ">' ...
                            str '</a>']; 
                    end
                    
                    % 1D (make a graph)
                    if (size(variable,2)==1)
                        str=num2str(  size(variable) );
                        str=[ 'matrix [' str ']'];
                        str=['<a href="matlab:figure(''Name'',''' variableName ''' , ''NumberTitle'', ''off'');plot(' variableName ...
                            ');xlabel(''i'');ylabel(''' variableName '(i)' ''' , ''Interpreter'', ''none'' );">' ...
                            str '</a>'];                      
                    end

                end
            end
            
        message=[message parseHTMLTableRow( variableName, [ ' = ' str TAB], ['   (' class(variable)  ')' ] )];
        outstring=message;