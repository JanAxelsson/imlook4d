function recordComment(varargin)
    % Call to record a comment
    % Inputs:
    %    (Optional) handle to imlook4d handles (assume gcf if not specified)
    %    string  
    %


    if nargin == 2
        comment = varargin{2};
        imlook4d_current_handles = varargin{1};
    else
        imlook4d_current_handles = guidata(gcf);
        comment = varargin{1};
    end

    EOL = sprintf('\n');
    
    % I don't know which is best here:
    %imlook4d_current_handles = evalin('base','imlook4d_current_handles');
    %imlook4d_current_handles = guidata(gcf);
    
   % Bail out if not record mode
   try
    if (imlook4d_current_handles.record.enabled == 0)
        return
    end
   catch
       return
   end
   
   
    % Record the comment to editor window
    try          

        recordInsertBeforeLastNonEmptyLine(imlook4d_current_handles.record.editor, [ ' % ' comment EOL])

    catch
        disp('ERROR - recordInputsText (your Matlab is probably too old for this)');
    end