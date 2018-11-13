%
% Dialog
%

prompt={'Start Frame ', 'Last Frame ', 'Input Function variable-name (times as for dynamic image)' };
[answer, imlook4d_current_handles] = ModelDialog( imlook4d_current_handles, ...
    model_name, ...
    prompt, ...
    { num2str(imlook4d_frame), num2str( size(imlook4d_Cdata,4) ), '' } ...
    );

startFrame = str2num( answer{1});
endFrame = str2num( answer{2});
Cinp_variableName = answer{3};

range = [startFrame endFrame];
Cinp_for_this_script = eval( Cinp_variableName );  
Cinp_for_this_script = Cinp_for_this_script(:)'; % Allow both column and row vectors (make a row vector)


% Set model parameters
imlook4d_current_handles.model.functionHandle = @patlak;
imlook4d_current_handles.model.Patlak.startFrame = startFrame;
imlook4d_current_handles.model.Patlak.endFrame = endFrame;
imlook4d_current_handles.model.Patlak.Cinp = Cinp_for_this_script;


Import