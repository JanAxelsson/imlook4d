imlook4d_curve_window = [];
StoreVariables;

% Inhibit model image (which is triggered by existence of functionHandle)
keepFunctionHandle = imlook4d_current_handles.model.functionHandle;
imlook4d_current_handles.model.functionHandle = [];
guidata( imlook4d_current_handle, imlook4d_current_handles);


Export;

IS_DYNAMIC = size(imlook4d_Cdata,4) > 1 % One frame if more than one column


model_name = 'Time-activity curve';

try
    t = imlook4d_time/60;
    dt = imlook4d_duration/60;
    
    tmid = t + 0.5 * dt;
    dt = [tmid(1), tmid(2:length(tmid))-tmid(1:length(tmid)-1)];
    
    
    a.xlabel = 'time';
catch
    tmid = 1 : size( imlook4d_Cdata,4);
    a.xlabel = 'frame';
end

%
% Model
%
disp('Calculating time-activity curves ...');



a.ylabel = 'C_t';


%
% Alternative analysis DYNAMIC / STATIC
%

if IS_DYNAMIC
    [tact, NPixels, stdev, maxActivity, roisToCalculate ] = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs
    a.names = {};
    a.units = {};
    a.pars = {};
    
    % Store for use in SaveTact, when called from modelWindow
    a.extras.N = NPixels;
    a.extras.stdev = stdev;
    try
        a.extras.unit = imlook4d_current_handles.image.unit;
    catch
        a.extras.unit = '';
    end
    try
        a.extras.frameStartTime = imlook4d_time / 60;
    catch
        a.extras.frameStartTime =  1 : size( imlook4d_Cdata,4);
    end
    try
        a.extras.frameDuration = imlook4d_duration / 60;
    catch
        a.extras.frameDuration = ones( size( a.extras.frameStartTime));
    end
      
    n = size(tact,1);
    for i = 1:n
        a.X{i} = tmid;
        a.Y{i} = tact(i,:);
    end
    
    % Store same data points in model (will be drawn as a line)
    a.Xmodel = a.X;
    a.Ymodel = a.Y;
    
    % Ref
    try
        REF_EXISTS = length(imlook4d_current_handles.model.common.ReferenceROINumbers) > 0;
        if REF_EXISTS
            ref = generateReferenceTACT( imlook4d_current_handles);
            a.Xref = a.X{1};
            a.Yref = ref;
        end
    catch
        REF_EXISTS = false;
    end
    
    % Plot
    imlook4d_curve_window = modelWindow( ...
        a , ...
        imlook4d_ROINames(1:end-1), ...
        [model_name ] ...
        );
else
    ExportROIs
    a.names = {'mean', 'volume', 'pixels','max', 'min', 'std'};
    a.units = {'', '', '', '', '', ''};
    a.pars = { imlook4d_ROI_data.mean', ...
        imlook4d_ROI_data.volume', ...
        imlook4d_ROI_data.Npixels', ...
        imlook4d_ROI_data.max', ...
        imlook4d_ROI_data.min', ...
        imlook4d_ROI_data.stdev', ...
        };
    
    if (STAT_TOOLBOX)
        a.pars =  [ a.pars, imlook4d_ROI_data.skewness', imlook4d_ROI_data.kurtosis' ]; 
        a.names = [ a.names, 'skewness', 'kurtosis']
        a.units = [ a.units, ' ', ' ']
    end
   
    model_name = 'ROI data';
    tactWindow( ...
        imlook4d_ROI_data , ...
        [model_name ] ...
        );
end


Import; 
ClearVariables;