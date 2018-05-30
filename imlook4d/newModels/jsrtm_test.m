%% Jarkkos format from simulation data
data1.midtime = mean( NtSimul.ROITime,2);
data1.tact =  NtSimul.ROIdata_Baseline.Tissue;
data1.reftact =  NtSimul.REFdata_simul;

a = jsrtm( data1)

disp(a.srtm)
disp(a.srtm2)

%%
data.midtime = imlook4d_ROI_data.midtime;
data.tact = imlook4d_ROI_data.mean(:,2);
data.reftact = imlook4d_ROI_data.mean(:,1);

a = jsrtm( data)

disp(a.srtm)
disp(a.srtm2)