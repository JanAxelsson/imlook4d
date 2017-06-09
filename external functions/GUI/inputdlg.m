function answer = inputdlg(varargin)
  % Shaddowing the default matlab function
  % Alt 1) Calls default matlab function
  % Alt 2) If Workspace has a cell array INPUTS, then the arguments of 
  %        workspace variable INPUTS are used instead.
  %
  % Inputs alt 1):
  %     Same inputs as uiputfile takes
  %
  % Inputs alt 2):
  %     INPUTS = { filepath }  % Workspace variable being read giving full file path
  %                            % for example:
  %                            % INPUTS = {'E:\Ume� work\D03\jan_test4.nii'};
  %
  % Output:
  %     file 
  %     path
  
  EOL = sprintf('\n');

  this = 'inputdlg'; % the name of function in MATLAB we are shadowing   
  disp([ 'imlook4d function overriding matlab''s default ' this ' function' ])
  
  % Try to get input from workspace INPUTS variable
      try
          % Try to get input from workspace INPUTS variable
          INPUTS=getINPUTS();
          
          % Here, select if using default inputs from varargin
          % or from workspace variable INPUTS
          %
          % An example is Save DICOM in imlook4d, which gives default
          % values from the current DICOM file
          for i = 1:length(INPUTS)
              if ( strcmp( INPUTS{i}, '-') )
                  INPUTS{i}=varargin{4}{i};
              end
          end
          
          answer=INPUTS;
          
          evalin('base','clear INPUTS'); % Clear INPUTS from workspace
      catch
          % Call default function instead
          shipped = getShaddowedFunction(this);
          answer = shipped(varargin{:})
         % answer=inputdlg(prompt,title,numlines,defaultanswer);
         
         recordComment('Set field to ''-'', if you wish to keep value supplied by imlook4d'); % Insert text at caret
         recordInputsText(answer);  % Insert text at caret

      end
  
  
  

