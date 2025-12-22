function recordInputsText(varargin)
% Translate the cell array  { '1', '2'}
% to text in imlook4d recording window:
% INPUTS = Parameters({ '1', '2'});
%
% 
% Inputs:
%    (Optional) handle to imlook4d handles (assume gcf if not specified)
%    cell array of string comments  
%

firstArgument = varargin{1};
if isstruct(firstArgument)
    answer = varargin{2};
    imlook4d_current_handles = firstArgument;
else
    imlook4d_current_handles = guidata( gcf);
    answer = varargin{1};
end
    
 
    
   % Bail out if not record mode
   try
%         if (imlook4d_current_handles.record.enabled == 1)
%         end
        
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

        recordInsertBeforeLastNonEmptyLine(imlook4d_current_handles.record.editor, outText)


    catch
        disp('ERROR - recordInputsText (your Matlab is probably too old for this)');
    end


end