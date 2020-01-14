    %
    % Dialog
    %
    StoreVariables
    ExportUntouched % I do not want recalculation of model for whole matrix, on Export.
    model_name = 'Water';

    prompt={'Input Function variable-name (time points should be same as frame times)' };
    [answer, imlook4d_current_handles] = ModelDialog( imlook4d_current_handles, ...
    model_name, ...
    prompt, ...
    {  'Cinp' } ...
    );

    Cinp_variableName = answer{1};

    Cinp_for_this_script = eval( Cinp_variableName );  
    Cinp_for_this_script = Cinp_for_this_script(:)'; % Allow both column and row vectors (make a row vector)


    % Set model parameters
    imlook4d_current_handles.model.functionHandle = @water;
    imlook4d_current_handles.model.Water.Cinp = Cinp_for_this_script;


    ImportUntouched
    ClearVariables
