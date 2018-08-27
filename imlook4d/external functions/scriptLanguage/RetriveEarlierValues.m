function outCellArray = RetriveEarlierValues( name, defaultValues)

imlook4d_variables_before_script = evalin('base', 'imlook4d_variables_before_script');
assignin('base','imlook4d_variables_before_script', [imlook4d_variables_before_script 'imlook4d_store']); % So ClearVariables won't clear imlook4d_store

try 
    % exists, do nothing
    outCellArray = evalin('base', ['imlook4d_store.' name '.inputs']);
catch
    % does not exist -- make new
    
    % Make empty cell array
    evalin('base',['imlook4d_store.' name '.inputs = {};' ]);
    
    % Set cell values one by one to defaultValues
    for i=1:length(defaultValues)
        % Skapa: imlook4d_store.Logan.inputs{4}=defaultValues{i}
        evalin('base',['imlook4d_store.' name '.inputs{' num2str(i) '}=''' defaultValues{i} ''''] );
    end
    outCellArray = defaultValues;
end
