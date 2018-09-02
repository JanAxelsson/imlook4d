StoreVariables
ExportUntouched % I do not want recalculation of model for whole matrix, on Export.

model_name = 'SRTM';

%
% Dialog  ( Type of parametric image)
%
    try 
        initialValue = imlook4d_current_handles.model.SRTM.imagetype;
    catch
        initialValue = 1;
    end
    out = jjsrtm2();
    [selection ,ok] = listdlg('PromptString','Image type : ',...
                    'SelectionMode','single',...
                    'ListString', out.names, ...
                    'InitialValue', initialValue);
%
% Store parameters in current imlook4d
%

    % Set model parameters
    imlook4d_current_handles.model.functionHandle = @srtm;
    imlook4d_current_handles.model.SRTM.referenceData = generateReferenceTACT( imlook4d_current_handles);
    imlook4d_current_handles.model.SRTM2.imagetype = selection;


Import
ClearVariables