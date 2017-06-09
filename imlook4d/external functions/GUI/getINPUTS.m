function INPUTS = getINPUTS()

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
    
    % Create a string representation of INPUTS command in Workspace
    str = 'INPUTS = { ';
    for i=1:length(INPUTS)-1
        str = [ str '''' INPUTS{i} ''', ' ];
    end
    
    str = [ str '''' INPUTS{end} '''' ];
    
    str = [ str ' };' ];
    
    % Display INPUTS
    disp(str)