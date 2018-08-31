StoreVariables
ExportUntouched % I do not want recalculation of model for whole matrix, on Export.

model_name = 'SRTM2';
%
% Dialog
%
prompt={'k2p'};
[answer, imlook4d_current_handles]  = ModelDialog( imlook4d_current_handles, model_name, prompt, {'0.2'} );
k2p = str2num( answer{1});

%
% Store parameters in current imlook4d
%

% Set model parameters
imlook4d_current_handles.model.functionHandle = @srtm2;
imlook4d_current_handles.model.SRTM2.referenceData = generateReferenceTACT( imlook4d_current_handles);
imlook4d_current_handles.model.SRTM2.k2p = k2p;

Import
ClearVariables