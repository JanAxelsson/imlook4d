% Dialog
%
StoreVariables
ReferenceModel

ExportUntouched % I do not want recalculation of model for whole matrix, on Export.
model_name = 'Logan';

prompt={'Start Frame ',...
    'Last Frame ',...
    'k2'};
title=[ model_name ' inputs'];
numlines=1;

defaultanswer = RetriveEarlierValues('Logan', { num2str(imlook4d_frame), num2str( size(imlook4d_Cdata,4) ), ''}  );  % Read default if exists, or apply these as default
answer=inputdlg(prompt,title,numlines,defaultanswer);
if isempty(answer) % cancelled inputdlg
    return
end

startFrame = str2num( answer{1});
endFrame = str2num( answer{2});
[k2ref, k2ref_existing] = str2num(answer{3} );

StoreValues(model_name, answer); % Store answer as new dialog default

% Set model parameters
imlook4d_current_handles.model.functionHandle = @logan;
imlook4d_current_handles.model.Logan.startFrame = startFrame;
imlook4d_current_handles.model.Logan.endFrame = endFrame;
imlook4d_current_handles.model.Logan.referenceData = generateReferenceTACT( imlook4d_current_handles);
imlook4d_current_handles.model.Logan.k2 = k2ref;
imlook4d_current_handles.model.Logan.imagetype = 1; % BP

Import
ClearVariables