function INPUTS = Parameters( args)
% Function to use in recorded scripts.
% Typical use:
%    INPUTS = Parameters( {'C:\Users\Jan\Desktop\ROIs.roi'} );
%    Menu('Save ROI');
%
% More advanced typical use:
%    INPUTS = Parameters( {'test^person ', '12345', ' WB 3D MAC ', '6 ', 'SERUME000000000'} );
%    INPUTS = Parameters( {'C:\Users\Jan\Desktop\test'} );
%    Menu('Save')
%
% The function puts args into workspace variable INPUTS 
% and also makes it available in local workspace within a function.
% 

% Add to stack
   try 
       INPUTS_STACK = evalin('base', 'INPUTS_STACK');  % Get stack
       INPUTS_STACK{end+1} =  args ; % Add to end of stack
   catch
       INPUTS_STACK = { args }; % Create stack
   end

% Pull from stack   
   INPUTS = INPUTS_STACK{1};
  % INPUTS_STACK = { INPUTS_STACK{2:end} };

% Assign new variables to workspace
   assignin('base', 'INPUTS', INPUTS);
   assignin('base', 'INPUTS_STACK', INPUTS_STACK);

