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

aaa.ylabel = 'C_t';

% Normal
try
    t = imlook4d_time/60;
    dt = imlook4d_duration/60;
    
    tmid = t + 0.5 * dt;
    %dt = [tmid(1), tmid(2:length(tmid))-tmid(1:length(tmid)-1)];
    
    
    aaa.xlabel = 'time';
catch
    tmid = 1 : size( imlook4d_Cdata,4);
    aaa.xlabel = 'frame';
end

% Special for PC image
if IsPCImage
    model_name = 'Principal component plot';
    try
        t = 1:numberOfFrames;
        dt = ones(size(dt));
        
        tmid = 1:numberOfFrames;        
        
        aaa.xlabel = 'frame';
        aaa.ylabel = 'Eigen values';
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
    aaa.names = {};
    aaa.units = {};
    aaa.pars = {};
    
    % Store for use in SaveTact, when called from modelWindow
    aaa.extras.N = NPixels;
    aaa.extras.stdev = stdev;
    try
        aaa.extras.unit = imlook4d_current_handles.image.unit;
    catch
        aaa.extras.unit = '';
    end
    try
        aaa.extras.frameStartTime = imlook4d_time / 60;
    catch
        aaa.extras.frameStartTime =  1 : size( imlook4d_Cdata,4);
    end
    try
        aaa.extras.frameDuration = imlook4d_duration / 60;
    catch
        aaa.extras.frameDuration = ones( size( aaa.extras.frameStartTime));
    end
      
    n = size(tact,1);
    for i = 1:n
        aaa.X{i} = tmid;
        aaa.Y{i} = tact(i,:);
        if IsPCImage
            aaa.Y{i} = abs(aaa.Y{i} ); % PCA arbitrary direction
        end
    end
    
    % Store same data points in model (will be drawn as a line)
    aaa.Xmodel = aaa.X;
    aaa.Ymodel = aaa.Y;
    
    
    % PVE-correction (if weights exist)
    
    if exist('pveFactors')
        numberOfFrames = size(tact,2);
        for i = 1:numberOfFrames
            pvc_tact(:,i) = (pveFactors' \ tact(:,i) );
        end
        
        for i = 1 : n % Number of ROIs
            aaa.Y{i} = pvc_tact(i,:);
        end
    end
    
    
    % Ref
    try
        REF_EXISTS = length(imlook4d_current_handles.model.common.ReferenceROINumbers) > 0;
        if REF_EXISTS
            ref = generateReferenceTACT( imlook4d_current_handles);
            aaa.Xref = aaa.X{1};
            aaa.Yref = ref;
        end
    catch
        REF_EXISTS = false;
    end
    
    % Plot
    imlook4d_curve_window = modelWindow( ...
        aaa , ...
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


% PVE-correction (is calculated in ExportROIs)
   
    model_name = 'ROI data';
    tactWindow( ...
        imlook4d_ROI_data , ...
        [model_name ] ...
        );
end

% Special for PC image
if IsPCImage
    for i = 1 : length(aaa.Y)
        aaa.Y{i} = abs(aaa.Y{i});
    end
end


ClearVariables;