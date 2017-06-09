function handle=SelectWindow(message)
% SelectWindow is used to click and select another window.
% In:  message - a string or cell of strings
% Out: handle to selected window
%
% Returns handle to selected window
title='Select Window';
parentWindowHandle=gcf;

  EOL = sprintf('\n');

  % Try to get input from workspace INPUTS variable
      try
          % Gets input variables from the stack.  
            try
                % Get stack
                INPUTS_STACK=evalin('base', 'INPUTS_STACK');
                % Pull from stack
                INPUTS = INPUTS_STACK{1};
                INPUTS_STACK = { INPUTS_STACK{2:end} }; 
                assignin('base', 'INPUTS_STACK', INPUTS_STACK);
            catch
                INPUTS=evalin('base', 'INPUTS');
            end
          
          % Here, select if using default inputs from varargin
          % or from workspace variable INPUTS
          %
          % An example is Save DICOM in imlook4d, which gives default
          % values from the current DICOM file

          
          answer=INPUTS{1};
          
          figure(answer);  % Put figure handle=answer on top
          
          evalin('base','clear INPUTS'); % Clear INPUTS from workspace
          
          handle = answer;
      catch
         % Get handle from
            h = msgbox(message,title)
            while ishandle(h)
                pause(3)
                if gcf~=parentWindowHandle
                    try set(h, 'Visible', 'on');  % Move window to top
                    catch end
                end
            end
            
            handle=gca;
      end
    
         
         recordText('INPUTS = Parameters( { YOUR_HANDLE } )'); % Put a handle to an imlook4d window in YOUR_HANDLE'); % Insert text at caret
         %recordInputsText(answer);  % Insert text at caret

      end
  