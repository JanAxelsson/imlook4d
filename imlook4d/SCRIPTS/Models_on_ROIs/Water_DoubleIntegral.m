StoreVariables;

% Inhibit model image (which is triggered by existence of functionHandle)
keepFunctionHandle = imlook4d_current_handles.model.functionHandle;
imlook4d_current_handles.model.functionHandle = [];
guidata( imlook4d_current_handle, imlook4d_current_handles);

Export;


model_name = 'Water Double Integral Method';

%
% Model
%
    disp('Calculating time-activity curves ...');
    tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs
    ref = generateReferenceTACT( imlook4d_current_handles)

    % Reference Region, mean of all ROIs
    indecesToROI=find(imlook4d_ROI>0);  
    for i=1:size(imlook4d_Cdata,4)
        tempData = imlook4d_Cdata(:,:,:,i);
        ref(i) = mean( tempData(indecesToROI) );
    end

    tact = tacts;  % all ROIs

    disp('Calculating model ...');
    a = jjwater_doubleintegralmethod( tact, imlook4d_time/60, imlook4d_duration/60, ref);

%
% Display
%
    modelWindow( ...
        a , ...
        imlook4d_ROINames(1:end-1), ...
        [model_name ] ...
        );
    
    % Restore functionHandle
    imlook4d_current_handles.model.functionHandle = keepFunctionHandle;

    disp('Done!');
    Import;
    ClearVariables;