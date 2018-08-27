function StoreValues( name, defaultValues)

    % Make empty cell array
    evalin('base',['imlook4d_store.' name '.inputs = {};' ]);
    
    % Set cell values one by one
    for i=1:length(defaultValues)
        % Skapa: imlook4d_store.Logan.inputs{4}=defaultValues{i}
        evalin('base',['imlook4d_store.' name '.inputs{' num2str(i) '}=''' defaultValues{i} ''''] );
    end
