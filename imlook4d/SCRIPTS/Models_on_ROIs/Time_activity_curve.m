
model_name = 'Time-activity curve';

t = imlook4d_time/60;
dt = imlook4d_duration/60;

tmid = t + 0.5 * dt;
dt = [tmid(1), tmid(2:length(tmid))-tmid(1:length(tmid)-1)];


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
a.xlabel = 'time';
a.ylabel = 'C_t';
a.names = {};
a.units = {};
a.pars = {};


modelWindow( ...
    a , ...
    imlook4d_ROINames(1:end-1), ...
    [model_name ] ...
    );