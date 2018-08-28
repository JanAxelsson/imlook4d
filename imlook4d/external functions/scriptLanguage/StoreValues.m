function StoreValues( name, valuesToStore)
% Store a CellArray of String values, which can be retrieved by functionRetrieveEarlierValues
%
% inputs:
%   name - the name to identify these settings
%   valuesToStore - values that will be stored for later retrieval

    % Make empty cell array
    evalin('base',['imlook4d_store.' name '.inputs = {};' ]);
    
    % Set cell values one by one
    for i=1:length(valuesToStore)
        % Skapa: imlook4d_store.Logan.inputs{4}=defaultValues{i}
        evalin('base',['imlook4d_store.' name '.inputs{' num2str(i) '}=''' valuesToStore{i} ''''] );
    end
