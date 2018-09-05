%
% Dialog
%
StoreVariables
ExportUntouched % I do not want recalculation of model for whole matrix, on Export.

model_name = 'Water_DoubleIntegral';

%
% Store parameters in current imlook4d
%

% Set model parameters
imlook4d_current_handles.model.functionHandle = @water_doubleintegral;
imlook4d_current_handles.model.Water_DoubleIntegral.referenceData = generateReferenceTACT( imlook4d_current_handles);
imlook4d_current_handles.model.SRTM2.imagetype = 1; % Flow

Import
ClearVariables