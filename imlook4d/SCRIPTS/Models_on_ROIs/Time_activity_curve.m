StoreVariables;

% Inhibit model image (which is triggered by existence of functionHandle)
keepFunctionHandle = imlook4d_current_handles.model.functionHandle;
imlook4d_current_handles.model.functionHandle = [];
guidata( imlook4d_current_handle, imlook4d_current_handles);


Export;

ExportROIs

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
tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs

ref = generateReferenceTACT( imlook4d_current_handles);
tact = tacts;  % all ROIs

n = size(tacts,1);
for i = 1:n
    a.X{i} = tmid;
    a.Y{i} = tact(i,:);
end

a.Xref = a.X{1};
a.Yref = ref;
a.ylabel = 'C_t';


IS_DYNAMIC = size(a.X{1},2) > 1 % One frame if more than one column
if IS_DYNAMIC
    a.names = {'Click in cell'};
    a.units = {''};
    a.pars = {''};
    modelWindow( ...
        a , ...
        imlook4d_ROINames(1:end-1), ...
        [model_name ] ...
        );
else
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
    
    modelWindow( ...
        a , ...
        imlook4d_ROINames(1:end-1), ...
        [model_name ] ...
        );
end


Import; 
ClearVariables;