% Dialog
%
StoreVariables
ReferenceModel
ExportUntouched % I do not want recalculation of model for whole matrix, on Export.
model_name = 'Ratio';



% Set model parameters
imlook4d_current_handles.model.functionHandle = @ratio;
imlook4d_current_handles.model.Ratio.referenceData = generateReferenceTACT( imlook4d_current_handles);
imlook4d_current_handles.model.Ratio.imagetype = 1; % Ratio

ImportUntouched
ClearVariables