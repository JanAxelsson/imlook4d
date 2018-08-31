%
% Dialog
%
StoreVariables
ExportUntouched % I do not want recalculation of model for whole matrix, on Export.

model_name = 'Zhou';

%
% Dialog
%
prompt={'Start Frame ', 'Last Frame '};
[answer, imlook4d_current_handles] = ModelDialog( imlook4d_current_handles, ...
    model_name, ...
    prompt, ...
    { num2str(imlook4d_frame), num2str( size(imlook4d_Cdata,4) ) } ...
    );

startFrame = str2num( answer{1});
endFrame = str2num( answer{2});

%
% Store parameters in current imlook4d
%

% Set model parameters
imlook4d_current_handles.model.functionHandle = @zhou;
imlook4d_current_handles.model.Zhou.startFrame = startFrame;
imlook4d_current_handles.model.Zhou.endFrame = endFrame;
imlook4d_current_handles.model.Zhou.type = 'BP';
imlook4d_current_handles.model.Zhou.referenceData = generateReferenceTACT( imlook4d_current_handles);

Import
ClearVariables