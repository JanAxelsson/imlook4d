%% Jarkkos format from simulation data
data1.midtime = mean( NtSimul.ROITime,2);
data1.tact =  NtSimul.ROIdata_Baseline.Tissue;
data1.reftact =  NtSimul.REFdata_simul;

a = jsrtm( data1)
%a = jsrtm2( a, a.srtm.k2p )

disp(a.srtm)
disp(a.srtm2)

%%
tic
R1=zeros(1,256*256);
for i = 1:256*256
data.midtime = imlook4d_ROI_data.midtime;
data.tact = imlook4d_ROI_data.mean(:,2);

data.reftact = imlook4d_ROI_data.mean(:,1);

a = jsrtm( data);
R1(i) = a.srtm.par(1);
%a = jsrtm2( a, a.srtm.k2p );

%disp(a.srtm)
%disp(a.srtm2)
end
toc