StoreVariables;
ReferenceModel; % Makes sure Reference Region is defined

% Inhibit model image (which is triggered by existence of functionHandle)
keepFunctionHandle = imlook4d_current_handles.model.functionHandle;
imlook4d_current_handles.model.functionHandle = [];
guidata( imlook4d_current_handle, imlook4d_current_handles);


Export;

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
% Model
%
disp('Calculating time-activity curves ...');
tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs

ref = generateReferenceTACT( imlook4d_current_handles);
tact = tacts;  % all ROIs


disp('Calculating model ...');
a = jjzhou( tact, imlook4d_time/60, imlook4d_duration/60, ref, [ startFrame endFrame]); % Fit to end frame

% Get Zhou Logan-like axes for reference tissue
r = jjzhou( ref, imlook4d_time/60, imlook4d_duration/60, ref, [ startFrame endFrame]);
a.Yref = r.Y{1};
a.Xref = r.X{1};


%
% Display
%
modelWindow( ...
    a , ...
    imlook4d_ROINames(1:end-1), ...
    [model_name ' (First frame = '  num2str(startFrame) ')'] ...
    );

disp('Done!');

ClearVariables;
