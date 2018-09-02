% Get ROI data

%ROI_data_to_workspace
%Menu('Export (untouched)') 
load('/Users/jan/Documents/Projects/imlook4d/Test data/DAD/imlook4d_ROI_data.mat');

%  Cref
ref_roi = 97;
disp( [ 'Cr = ' imlook4d_ROINames( ref_roi) ]);
Cr = imlook4d_ROI_data.mean( :, ref_roi)';

 %  Caudate + Putamen both side
range = 75:78;
Ct = imlook4d_ROI_data.mean(:, range)';
%%
out = jjlogan( imlook4d_ROI_data.mean',imlook4d_time/60, imlook4d_duration/60, Cr, [12 18] );
disp( [ ' Logan : ' out.names]);
disp( [ out.pars{1}(range) out.pars{2}(range) out.pars{3}(range) ]);

out = jjzhou( imlook4d_ROI_data.mean',imlook4d_time/60, imlook4d_duration/60, Cr,  [12 18]  );
disp( [ ' Zhou : ' out.names]);
disp( [ out.pars{1}(range) out.pars{2}(range) out.pars{3}(range) ]);

out = jjsrtm( imlook4d_ROI_data.mean',imlook4d_time/60, imlook4d_duration/60, Cr  );
disp( [ ' SRTM : ' out.names]);
disp( [ out.pars{1}(range) out.pars{2}(range) out.pars{3}(range) out.pars{4}(range) out.pars{5}(range)]);

out = jjsrtm2( imlook4d_ROI_data.mean',imlook4d_time/60, imlook4d_duration/60, Cr, 0.20  );
disp( [ ' SRTM2 : ' out.names]);
disp( [ out.pars{1}(range) out.pars{2}(range) out.pars{3}(range) out.pars{4}(range) ]);