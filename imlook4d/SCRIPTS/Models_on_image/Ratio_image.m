% Dialog
%
StoreVariables
ExportUntouched % I do not want recalculation of model for whole matrix, on Export.
model_name = 'Ratio';

% prompt={'Start Frame ',...
%     'Last Frame ',...
%     'k2'};
% title=[ model_name ' inputs'];
% numlines=1;
% 
% defaultanswer = RetriveEarlierValues(model_name, { num2str(imlook4d_frame), num2str( size(imlook4d_Cdata,4) ), ''}  );  % Read default if exists, or apply these as default
% answer=inputdlg(prompt,title,numlines,defaultanswer);
% 
% startFrame = str2num( answer{1});
% endFrame = str2num( answer{2});
% 
% StoreValues(model_name, answer); % Store answer as new dialog default

% Set model parameters
imlook4d_current_handles.model.functionHandle = @ratio;
imlook4d_current_handles.model.Ratio.referenceData = generateReferenceTACT( imlook4d_current_handles);
imlook4d_current_handles.model.Ratio.imagetype = 1; % Ratio

Import
ClearVariables