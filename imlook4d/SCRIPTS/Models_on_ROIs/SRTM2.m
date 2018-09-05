StoreVariables;

% Inhibit model image (which is triggered by existence of functionHandle)
keepFunctionHandle = imlook4d_current_handles.model.functionHandle;
imlook4d_current_handles.model.functionHandle = [];
guidata( imlook4d_current_handle, imlook4d_current_handles);


Export;

model_name = 'SRTM2';

%
% First run SRTM 
%
    disp('Calculating time-activity curves ...');
    tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs

    ref = generateReferenceTACT( imlook4d_current_handles);
    tact = tacts;  % all ROIs


    disp('Calculating SRTM ...');
    a = jjsrtm( tact, imlook4d_time/60, imlook4d_duration/60, ref);

    % store for use in SRTM2
    k2p_values = a.pars{3};
    BP_values = a.pars{1};

    % Version 1) Calculate k2p
    k2p_specific_bindings = k2p_values( BP_values > 0);

    RoiNumbers = (1:length(BP_values)); % All ROIs
    ReferenceROINumbers = imlook4d_current_handles.model.common.ReferenceROINumbers;
    roisToCalculate = setdiff( RoiNumbers(BP_values > 0 ), ReferenceROINumbers);

    k2p = median( k2p_values(roisToCalculate) );  
    disp(['Median of k2p values for specific binding (outside ref rois) = ' num2str(k2p) ]);

    % Version 2) Calculate k2p
    k2p = median( k2p_values(k2p_values>0) );  % Positive k2p 
    disp(['Use this: Median of positive k2p values = ' num2str(k2p) ]);

%
% Model
%
    disp('Calculating SRTM2 ...');

    b = jjsrtm2( tact, imlook4d_time/60, imlook4d_duration/60, ref,k2p);

%
% Display
%
    modelWindow( ...
        b , ...
        imlook4d_ROINames(1:end-1), ...
        [model_name ' (k2p = ' num2str(k2p) ')'] ...
        );

    disp('Done!');

    ClearVariables;