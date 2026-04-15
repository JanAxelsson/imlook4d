StoreVariables; 

% Inhibit model image (which is triggered by existence of functionHandle)
keepFunctionHandle = imlook4d_current_handles.model.functionHandle;
imlook4d_current_handles.model.functionHandle = [];
guidata( imlook4d_current_handle, imlook4d_current_handles);


Export;
ReferenceModel; % Makes sure Reference Region is defined

model_name = 'eSRTM';

%
% Dialog
%
prompt={'Task onset, start frame ='};
[answer, imlook4d_current_handles] = ModelDialog( imlook4d_current_handles, ...
    model_name, ...
    prompt, ...
    { num2str(imlook4d_frame), num2str( size(imlook4d_Cdata,4) ), '' } ...
    );

frame0 = str2num( answer{1});


%
% Model
%

    disp('Calculating time-activity curves ...');
    tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs

    ref = generateReferenceTACT( imlook4d_current_handles)
    tact = tacts;  % all ROIs


    disp('Calculating model ...');
    a = jjesrtm( tact, imlook4d_time/60, imlook4d_duration/60, ref, frame0);

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