            function htmlTableRow=parseHTMLTableRow( varargin )
            % This functions creates a HTML table-row
            % Inputs:  - a1, a2  elements in the table row
            
            EOL=sprintf('\r\n');  % Windows end-of-line (used for nicer formatting of page source for generated HTML file)
            
            htmlTableRow= '<tr>';
            for k= 1 : size(varargin,2) 
                 htmlTableRow= [htmlTableRow '<td>' varargin{k} '</td>']; 
            end
           
            htmlTableRow= [htmlTableRow '</tr>' EOL];  