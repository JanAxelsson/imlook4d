function T =  loop( myFunction, xlsFileList, sheet, columns )
% A generic loop.  
% Iterates over variable-list specificed in Excel, and calls myFunction
%
% INPUTS:
%   myFunction  - handle to function, for instance @myFunction.  This
%                 function should return data in a one-row matlab table
%
%   xlsFileList - with variables and file-paths in rows of an Excel file. 
%                 Also an Excel sheet "static" can contain static variables
%                 that are passed to myFunction.
%                 Excel sheet "static" contains constants that can be used
%
%   sheet       - sheet name in Excel file ('' if only one sheet)
%
%   columns     - Cells with valid Excel column names, from which parameters should be taken.
%                 Data from selected columns are forwarded as arguments to myFunction. 
%                 Example: columns = {'A', 'B', 'D', 'E'};  
%                 Example: columns = {'AA', 'AB'};  
%                   
%                 The column names are translated to column numbers internally.
%                 The column numbers may be used directly as input arguments, instead of names
%                 Example: columns = [1 2 4 5];
%
%                 It is not permitted to mix column names and column
%                 numbers
%
% OUTPUTS:
%   T             Table with one row per looped file.  Each table row is
%                 returned from myFunction
%
%
% Example use:
%   T = loop(@loop_my_test_function,'loop_test.xlsx', 'Sheet1', {'A', 'B', 'D', 'E'})
%   writetable(T, 'Q:\COBRA\Jan_Axelsson\matlab\janlibs\loop\test.txt', 'Delimiter',TAB);  % Save to file
%
%   T = loop(@loop_my_test_function,'loop_test.xlsx', 'Sheet1', [1 2 4 5])
% 
%
% "loop_test_main_script.m" is a template for implementing the function
% "loop_test.xlsx" is a template for implementing the excel sheet
%
% REQUIRES: Matlab later than 2012 (for table)
%           Excel
%
% AUTHOR: Jan Axelsson
%         2015-APR-16


%
% Preprocess
% 
    displayColumns = cell(size(columns));  % Empty cells -- stores display of column names if in Excel 'A' format (otherwise emtpy)
    
    disp('=================================');
    disp(['DATA SOURCE (for loop)' ]);
    disp(['   Excel file  = ' xlsFileList ]);
    disp(['   Excel sheet = ' sheet ]);
    
    % Convert to column numbers from Excel names (if necessary)
    if iscell(columns)
        displayColumns = columns;  % Store 
        displayString = '';
        for i=1:length(columns)
            if ~isnumeric(columns(i))
                tempColumns(i) = convert2ColumnIndex(columns{i});
                displayString = [ displayString columns{i} '  '];
            end
        end
        columns = tempColumns;   
        disp(['   Columns     = ' displayString ]);
    end
    
    disp(['   Columns     = ' num2str(columns)]);

%
% Initialize
%     
    s = [];
    TAB=sprintf('\t');
    EOL=sprintf('\n');

    FIRSTCOLUMN = columns(1);  % Used to count number of rows in main sheet

    SKIPROWS=1;             % Skip first row (header)
    FIRSTROW=SKIPROWS+1;    % First row has number 2
    
    errCount=0; 
    successCount=0;
    
    T = table();  % Empty table

%
% Excel - Read column data from sheet
%    
    % Read Excel sheet 
    try
        [num, text, raw] = xlsread(xlsFileList,sheet);
        
        % Display columns to use
        for i=1:length(columns)
            disp(['   Col=' displayColumns{i} ' (' num2str(columns(i)) ') "' text{1,columns(i)} '"'])
        end
    catch
        dispRed(['?? Error reading Excel-file = ' xlsFileList  ]);
        dispRed(['??                    sheet = ' sheet ]);
    end
    disp('=================================');

    
%
% Excel - Parse static (global) variables
%
    disp('GLOBAL VARIABLES FROM EXCEL SHEET');
    try
        % Variables in sheet "static" first column
        [snum, stext, sraw] = xlsread(xlsFileList,'static');
        numberOfVariableRows=size(sraw,1);
        for i=FIRSTROW:numberOfVariableRows
           try
               disp( [ '   ' stext{i,1} ' = ' stext{i,2} TAB '%'  stext{i,3}]);
           catch
               disp( [ '   ' stext{i,1} ' = ' stext{i,2}  ]);
           end
           
           try
               s.(sraw{i,1}) = sraw{i,2};
           catch
               dispRed('?? Failed reading static variable from sheet = static');
           end
        end
        
    catch
        dispRed(['?? Error reading static variable' ]);
        dispRed(['?? Excel file = ' xlsFileList ]);
    end    
    
    disp('=================================');
       
  
%
% Main loop
%
    disp('MAIN LOOP');
    
    files = raw(FIRSTROW:end, FIRSTCOLUMN );   % First column should always be a complete file path.  Start at row 2, allowing for column titles
    numberOfRows = length(files);
    
    errCount = zeros(1,numberOfRows);      % Use matrix to allow parfor signalling
    successCount = zeros(1,numberOfRows);  % Use matrix to allow parfor signalling
    data = raw(FIRSTROW:end, columns );     % Data in columns
    
   for i=1:numberOfRows    
   %parfor i=1:numberOfRows
        try
            disp(' ');
            disp([ '   '  num2str(i) '(' num2str(numberOfRows) ') ===> ' files{i} ]);
            tic;
            T2 = myFunction( s, data(i, :));  % Send arguments from specified Excel-columns-numbers to my function
            toc
            T = [T;T2];
            successCount(i) =1;
        catch ME   
            msgText = getReport(ME);
            disp(msgText);
            
            errCount(i) =1;
            f = functions(myFunction); % Name
            dispRed( [ '?? ERROR in your function = ' f.function ] ); % RED
        end
    end    

%
% Finish
%
    
    % Summarize run
        disp('DONE!');

        if ( sum(errCount(:) ) > 0)
            disp('=================================');
            disp('Error in file names');
            indeces = find(errCount==1);
            disp(files(indeces));
        end

        disp('=================================');
        disp('SUMMARY');
        disp(['   Errors     = ' num2str( sum(errCount(:) ) ) ] );
        disp(['   Successes  = ' num2str( sum(successCount(:) ) ) ]);
        disp('=================================');

end


