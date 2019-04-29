StoreVariables;
ReferenceModel; % Makes sure Reference Region is defined

% Inhibit model image (which is triggered by existence of functionHandle)
keepFunctionHandle = imlook4d_current_handles.model.functionHandle;
imlook4d_current_handles.model.functionHandle = [];
guidata( imlook4d_current_handle, imlook4d_current_handles);


Export;

model_name = 'Ratio';

%
% Dialog
%


%
% Model
%
disp('Calculating time-activity curves ...');
tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs

ref = generateReferenceTACT( imlook4d_current_handles);
tact = tacts;  % all ROIs


a = jjratio( tacts, imlook4d_time/60, imlook4d_duration/60, ref, imlook4d_frame);

% Remove model parameter "ratios" from output, since I am only interested
% in the ratios graph
a.names = {};
a.units = {};
a.pars = {};


%
% Display
%
modelWindow( ...
    a , ...
    imlook4d_ROINames(1:end-1), ...
    [model_name ] ...
    );

disp('Done!');

ClearVariables;
