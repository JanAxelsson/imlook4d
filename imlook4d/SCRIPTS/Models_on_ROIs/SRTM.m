StoreVariables; 
ReferenceModel; % Makes sure Reference Region is defined

% Inhibit model image (which is triggered by existence of functionHandle)
keepFunctionHandle = imlook4d_current_handles.model.functionHandle;
imlook4d_current_handles.model.functionHandle = [];
guidata( imlook4d_current_handle, imlook4d_current_handles);


Export;

model_name = 'SRTM';

%
% Model
%

    disp('Calculating time-activity curves ...');
    tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs

    ref = generateReferenceTACT( imlook4d_current_handles)
    tact = tacts;  % all ROIs


    disp('Calculating model ...');
    a = jjsrtm( tact, imlook4d_time/60, imlook4d_duration/60, ref);

    % store for SRTM2
    k2p = median(a.pars{3});
    disp(['Median k2p = ' num2str(k2p) ]);

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