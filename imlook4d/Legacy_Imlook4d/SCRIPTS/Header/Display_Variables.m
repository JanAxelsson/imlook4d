% Display_Variables
%
% This script displays the workspace variables, and the
% imlook4d_current_handles.image internal variables
%
% USES:
% variableTOHTMLTableRow
%   parseHTMLTableRow
%       displayMatrix

StoreVariables
temp=whos;

Export

% Read workspace variables


webpageTitle='Workspace and internal variables list';
mainHeader=webpageTitle;
subHeader=' Workspace variables  ';





TAB=sprintf('\t');
EOL=sprintf('\n');

%--------------------------------------------------------------------
%
% Loop Workspace variables - make HTML table 
%

    
    message='<TABLE>';
   message=[message '<TR><TH COLSPAN="2"><h3> ' subHeader ': </h3></TH></TR>'];

    for i=1:length(temp)
        try
            %message=variableToHTMLTableRow(message, eval(a(i).name), ['<B>' a(i).name '</B>']);
            message=variableToHTMLTableRow(message, eval(temp(i).name), [ temp(i).name ]);
        catch
            disp([ temp(i).name ' error evalutating.   Class=' char( temp(i).class ) ])
            %disp(str)
        end  
    end
    message=[message '</TABLE>'];

%%--------------------------------------------------------------------
%
% Make HTML table for imlook4d_current_handles.image
%
    subHeader2='Internal variables:  imlook4d_current_handles.image ';
    message=[message '<TABLE>' ];
    message=[message '<TR><TH COLSPAN="2"><h3> ' subHeader2 '</h3></TH></TR>'];

    %temp=fieldnames( eval( a(i).name) );fieldnames(eval('imlook4d_current_handles.image'));
    temp2=getfield(eval( 'imlook4d_current_handles'),'image');
    fields=fieldnames(imlook4d_current_handles.image);
    for i=1:length(fields)
            try    
                tempVariable=getfield(imlook4d_current_handles.image,fields{i});
                message=variableToHTMLTableRow(message, tempVariable, ['imlook4d_current_handles.image.'  fields{i} ]);
            catch
                disp([ fields{i} ' error evalutating.   Class=' class(tempVariable)  ])
                %disp(str)
            end  

    end

    message=[message '</TABLE>'];

    
%%--------------------------------------------------------------------
%       
% Display HTML
%
        web(['text:// '  '<html><title>'  webpageTitle ' </title>'...
            '<h1>' mainHeader '</h1>' ...
            '<h3>' '' '</h3>'...
            message ... 
            '</html>'] );
        
%
% Finish
%
ClearVariables
        
