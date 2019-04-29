StoreVariables
ExportUntouched % I do not want recalculation of model for whole matrix, on Export.
ReferenceModel

model_name = 'SRTM2';
%
% Dialog 1
%
prompt={'k2p'};
[answer, imlook4d_current_handles]  = ModelDialog( imlook4d_current_handles, model_name, prompt, {'0.2'} );
k2p = str2num( answer{1});

%
% Dialog 2 ( Type of parametric image)
%
try 
    initialValue = imlook4d_current_handles.model.SRTM2.imagetype;
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
imlook4d_current_handles.model.functionHandle = @srtm2;
imlook4d_current_handles.model.SRTM2.referenceData = generateReferenceTACT( imlook4d_current_handles);
imlook4d_current_handles.model.SRTM2.k2p = k2p;
imlook4d_current_handles.model.SRTM2.imagetype = selection;

ImportUntouched
ClearVariables