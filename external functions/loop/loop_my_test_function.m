function T = loop_my_test_function( static, args )
% This function is called from loop.  
% For convenience the call to loop is stored in a top level script,
% see: loop_test_main_script.m
%
% Input variables:
%   static  not used in this function 
%		(variables defined in Excel-workbook sheet="static")
%          
%   args    cell with arguments.  It is up to this function to use
%           these input variables.
%
% 1) Use standalone:
%   
%   args = {1,2,3,'Anna' }; %cell array of one or more arguments
%   T = loop_my_test_function( {}, args )
%
% 2) Use with loop (illustrating definition that columns 1,2,4,5 
% are input arguments)
%
%   loop_test.xlsx, Sheet 1:
%   length  height  sex weight  description_text
%     1     2       f       3   Anna
%     2     4               6   Pelle
%
%   T = loop(@loop_my_test_function,'loop_test.xlsx', 'Sheet1', [1 2 4 5])
%
 
    % Assign variables ( you may call them whatever you like ) 
    % 1) from static variables (struct static)
       reportFile = static.REPORTFILE;
 
    % 2) from input arguments (cell array args)
        a = args{1};      
        b  =args{2};    
        c  =args{3};    
        subjects = {args{4}};  % Note: Text should be within cell brackets {}
    
    % Do calculations
    abc=a*b*c;
 
    % Report results
    % (Use simple variables when creating table (gives nice table headers)  )
    % (Using arrays etc, gives less informative table headers).
    T = table( subjects, a, b, c, abc );
    
    % Alternatively, do not report results.  In that case, use the following: 
    %T = table();


