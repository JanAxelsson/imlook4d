imlook4d_curve_window = [];
StoreVariables;

% Inhibit model image (which is triggered by existence of functionHandle)
keepFunctionHandle = imlook4d_current_handles.model.functionHandle;
imlook4d_current_handles.model.functionHandle = [];
guidata( imlook4d_current_handle, imlook4d_current_handles);


Export;

numberOfFrames=size(imlook4d_current_handles.image.Cdata,4);

% Determine mode of operation
IsNormalImage = get(imlook4d_current_handles.ImageRadioButton,'Value');
IsPCAFilter = not( (get(imlook4d_current_handles.PC_low_slider, 'Value')==1) &&  (get(imlook4d_current_handles.PC_high_slider, 'Value')==numberOfFrames) ); % PCA-filter selected with sliders
IsPCImage = get(imlook4d_current_handles.PCImageRadioButton,'Value');      % PC images radio button selected

IsModel =  isa(imlook4d_current_handles.model.functionHandle, 'function_handle');

IsDynamic = (numberOfFrames>1);


model_name = 'Time-activity curve';

a.ylabel = 'C_t';

% Normal
try
    t = imlook4d_time/60;
    dt = imlook4d_duration/60;
    
    tmid = t + 0.5 * dt;
    %dt = [tmid(1), tmid(2:length(tmid))-tmid(1:length(tmid)-1)];
    
    
    a.xlabel = 'time';
catch
    tmid = 1 : size( imlook4d_Cdata,4);
    a.xlabel = 'frame';
end

% Special for PC image
if IsPCImage
    model_name = 'Principal component plot';
    try
        t = 1:numberOfFrames;
        dt = ones(size(dt));
        
        tmid = 1:numberOfFrames;        
        
        a.xlabel = 'frame';
        a.ylabel = 'Eigen values';
    catch
    end
    
end

%
% Model
%
disp('Calculating time-activity curves ...');




%
% Alternative analysis DYNAMIC / STATIC
%

if IsDynamic
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
        if IsPCImage
            a.Y{i} = abs(a.Y{i} ); % PCA arbitrary direction
        end
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
        model_name ...
        );
    
else  % STATIC
    ExportROIs
%     a.names = {'mean', 'volume', 'pixels','max', 'min', 'std'};
%     a.units = {'', '', '', '', '', ''};
%     a.pars = { imlook4d_ROI_data.mean', ...
%         imlook4d_ROI_data.volume', ...
%         imlook4d_ROI_data.Npixels', ...
%         imlook4d_ROI_data.max', ...
%         imlook4d_ROI_data.min', ...
%         imlook4d_ROI_data.stdev', ...
%         };
    
%     %if (STAT_TOOLBOX)
%         a.pars =  [ a.pars, imlook4d_ROI_data.skewness', imlook4d_ROI_data.kurtosis' ]; 
%         a.names = [ a.names, 'skewness', 'kurtosis']
%         a.units = [ a.units, ' ', ' ']
%     %end
   
    model_name = 'ROI data';
    tactWindow( ...
        imlook4d_ROI_data , ...
        [model_name ] ...
        );
end

% Special for PC image
if IsPCImage
    for i = 1 : length(a.Y)
        a.Y{i} = abs(a.Y{i});
    end
end


ClearVariables;