%% Jarkkos format from simulation data
load('NtSimul_RACBI_May2018.mat');
%%
midtime = mean( NtSimul.ROITime,2);
tact =  NtSimul.ROIdata_Baseline.Tissue';
reftact =  NtSimul.REFdata_simul';

% Jans way to get start time and dT from midtime
T(1) = 0;
dT(1) = 2 * midtime(1);
for i = 2:length(midtime)
    dT(i) = 2 * ( midtime(i) - T(i-1) - dT(i-1) );
    T(i) = T(i-1) + dT(i-1);
end

% SRTM
a = jjsrtm( tact, T, dT, reftact);
R1 = a.pars{1}
BP = a.pars{5}
k2p = a.pars{3};

% SRTM2
b = jjsrtm2( tact, T, dT, reftact,k2p);
R1_ = b.pars{1}
BP_ = b.pars{4}

%a = jsrtm( data1)
%a = jsrtm2( a, a.srtm.k2p )



%%

% ROI-data to workspace, first ROI being ref roi
% Other ROIs being roi 2,3, ...
tic

ref = imlook4d_ROI_data.mean(:,imlook4d_ROI_number)'; 
tact = imlook4d_ROI_data.mean()';

a = jjsrtm( tact, imlook4d_time/60, imlook4d_duration/60, ref);
R1 = a.pars{1}


% SRTM2
k2p = median(a.pars{3});
b = jjsrtm2( tact, imlook4d_time/60, imlook4d_duration/60, ref,k2p);
R1_ = b.pars{1}
BP_ = b.pars{4}

toc
%%

S = roi_table_gui( ...
    [imlook4d_ROINames(1:end-1) num2cell( cell2mat(b.pars) ) ], ...
    'test window', ...
    b.names ...
    )


%%  

% ROI-data to workspace, first ROI being ref roi
tic
ref = imlook4d_ROI_data.mean(:,imlook4d_ROI_number)';  % ROI-data to workspace, first ROI being ref roi

% One pixel
a = jjsrtm( imlook4d_Cdata(1,1,20,:), imlook4d_time, imlook4d_duration, ref);
size(a.pars{1})
toc;tic;

% One row
a = jjsrtm( imlook4d_Cdata(1,:,20,:), imlook4d_time, imlook4d_duration, ref);
size(a.pars{1})
toc;tic;

% One slice
a = jjsrtm( imlook4d_Cdat a(:,:,20,:), imlook4d_time, imlook4d_duration, ref);
size(a.pars{1})
toc;tic;

% Whole volume
a = jjsrtm( imlook4d_Cdata(:,:,:,:), imlook4d_time, imlook4d_duration, ref);
size(a.pars{1})
toc

R1 = a.pars{1};
toc
imlook4d(R1);
%a = jsrtm2( a, a.srtm.k2p );
