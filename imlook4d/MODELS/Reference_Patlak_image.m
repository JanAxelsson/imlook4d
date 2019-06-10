%
% Dialog
%
StoreVariables
ReferenceModel; % Makes sure Reference Region is defined
ExportUntouched % I do not want recalculation of model for whole matrix, on Export.
model_name = 'Patlak_ref';

prompt={'Start Frame ', 'Last Frame ' };
[answer, imlook4d_current_handles] = ModelDialog( imlook4d_current_handles, ...
    model_name, ...
    prompt, ...
    { num2str(imlook4d_frame), num2str( size(imlook4d_Cdata,4) )} ...
    );

startFrame = str2num( answer{1});
endFrame = str2num( answer{2});
%Cinp_variableName = answer{3};

range = [startFrame endFrame];
% Cinp_for_this_script = eval( Cinp_variableName );  
% Cinp_for_this_script = Cinp_for_this_script(:)'; % Allow both column and row vectors (make a row vector)
Cinp_for_this_script = generateReferenceTACT( imlook4d_current_handles);


% Set model parameters
imlook4d_current_handles.model.functionHandle = @patlak;
imlook4d_current_handles.model.Patlak.startFrame = startFrame;
imlook4d_current_handles.model.Patlak.endFrame = endFrame;
imlook4d_current_handles.model.Patlak.Cinp = Cinp_for_this_script;


ImportUntouched
ClearVariables