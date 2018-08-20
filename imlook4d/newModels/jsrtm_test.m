%% Jarkkos format from simulation data
load('NtSimul_RACBI_May2018.mat');
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
a = jjsrtm2( tact, T, dT, reftact,k2p);
R1_ = a.pars{1}
BP_ = a.pars{4}

%a = jsrtm( data1)
%a = jsrtm2( a, a.srtm.k2p )


%%
tic
R1=zeros(1,256*256);
for i = 1:256*256
data.midtime = imlook4d_ROI_data.midtime;
data.tact = imlook4d_ROI_data.mean(:,2);

data.reftact = imlook4d_ROI_data.mean(:,1);

a = jsrtm( data);
R1(i) = a.par(1);
%a = jsrtm2( a, a.srtm.k2p );

%disp(a.srtm)
%disp(a.srtm2)
end
toc

%%

% ROI-data to workspace, first ROI being ref roi
% Other ROIs being roi 2,3, ...
tic

ref = imlook4d_ROI_data.mean(:,1)'; 
matrix = imlook4d_ROI_data.mean(:,2:end)';

a = jjsrtm( matrix, imlook4d_time, imlook4d_duration, ref);
R1 = a.pars{1}

%%  

% ROI-data to workspace, first ROI being ref roi
tic
ref = imlook4d_ROI_data.mean(:,1)';  % ROI-data to workspace, first ROI being ref roi

% One pixel
a = jjsrtm( imlook4d_Cdata(1,1,20,:), imlook4d_time, imlook4d_duration, ref);
size(a.pars{1})
toc;tic;

% One row
a = jjsrtm( imlook4d_Cdata(1,:,20,:), imlook4d_time, imlook4d_duration, ref);
size(a.pars{1})
toc;tic;

% One slice
a = jjsrtm( imlook4d_Cdata(:,:,20,:), imlook4d_time, imlook4d_duration, ref);
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
