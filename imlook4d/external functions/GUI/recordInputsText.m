function recordInputsText(answer)
% Translate the cell array answer = { '1', '2'}
% to text
% INPUTS = Parameters({ '1', '2'});

    % I don't know which is best here:
    %imlook4d_current_handles = evalin('base','imlook4d_current_handles');
    imlook4d_current_handles = guidata(gcf);
    
   % Bail out if not record mode
   try
    if (imlook4d_current_handles.record.enabled == 0)
        return
    end
   catch
       return
   end

    

%     EOL = sprintf('\n');
%     outText = 'INPUTS = {';
%     for i=1:(length(answer)-1)
%         outText = [outText '''' answer{i} ''', '];
%     end
% 
%     outText = [outText '''' answer{end} ''''];
%     outText = [outText '};' EOL];
    
     EOL = sprintf('\n');
    outText = 'INPUTS = Parameters( {';
    for i=1:(length(answer)-1)
        outText = [outText '''' answer{i} ''', '];
    end

    outText = [outText '''' answer{end} ''''];
    outText = [outText '} );' EOL];   
    
    
    
    % Record the inputs to editor window
    try 
        lineNumber = imlook4d_current_handles.record.editor.getLineNumber();  % Line number
  
        imlook4d_current_handles.record.editor.goToLine( lineNumber-1 ,1);      % Set caret one line up (NOTE that getLineNumber and goToLine uses numbering that differ by one)
        imlook4d_current_handles.record.editor.insertTextAtCaret( outText );  % Insert text at caret
         
        imlook4d_current_handles.record.editor.goToLine( lineNumber ,1);      % Set caret one line up (NOTE that getLineNumber and goToLine uses numbering that differ by one)
       
        lineNumber = imlook4d_current_handles.record.editor.getLineNumber();  % Line number
        imlook4d_current_handles.record.editor.goToLine( lineNumber+3 ,1);  % Set caret one line down again
    catch
        disp('ERROR - recordInputsText (your Matlab is probably too old for this)');
    end