StoreVariables
ExportUntouched % I do not want recalculation of model for whole matrix, on Export.

model_name = 'SRTM';

%
% Store parameters in current imlook4d
%

% Set model parameters
imlook4d_current_handles.model.functionHandle = @srtm;
imlook4d_current_handles.model.SRTM.referenceData = generateReferenceTACT( imlook4d_current_handles)';

Import
ClearVariables