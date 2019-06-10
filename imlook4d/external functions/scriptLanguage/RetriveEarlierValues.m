function outCellArray = RetriveEarlierValues( name, defaultValues)
% Retrieve a CellArray of String values, stored with function StoreValues
%
% inputs:
%   name - the name to identify these settings
%   defaultValues - values that will be returned in case no values exist. These values are also stored for later retrieval

imlook4d_variables_before_script = evalin('base', 'imlook4d_variables_before_script');
assignin('base','imlook4d_variables_before_script', [imlook4d_variables_before_script 'imlook4d_store']); % So ClearVariables won't clear imlook4d_store

try 
    % exists, do nothing
    outCellArray = evalin('base', ['imlook4d_store.' name '.inputs']);
    
    % If empty 
    % (which may happen if somebody uses StoreValues after cancel in inputdlg)
    if isempty( outCellArray)
        StoreValues( name, defaultValues);
        outCellArray = defaultValues;
    end
catch
    % does not exist -- make new
    StoreValues( name, defaultValues);
    outCellArray = defaultValues;
end
