StoreVariables;
Export;

model_name = 'SRTM2';
ref_name = imlook4d_ROINames{imlook4d_ROI_number};

% First run SRTM (same code as SRTM script copied here)

disp('Calculating time-activity curves ...');
tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs

ref = tacts(imlook4d_ROI_number,:); % Current ROI
tact = tacts;  % all ROIs


disp('Calculating SRTM ...');
a = jjsrtm( tact, imlook4d_time/60, imlook4d_duration/60, ref);

% store for SRTM2
k2p = median(a.pars{3});
disp(['Median k2p = ' num2str(k2p) ]);


% % Display
% S = roi_table_gui( ...
%     [imlook4d_ROINames(1:end-1) num2cell( cell2mat(a.pars) ) ], ...
%     model_name, ...
%     a.names ...
%     );


disp('Calculating SRTM2 ...');

b = jjsrtm2( tact, imlook4d_time/60, imlook4d_duration/60, ref,k2p);

% Display
S = roi_table_gui( ...
    [imlook4d_ROINames(1:end-1) num2cell( cell2mat(b.pars) ) ], ...
    [model_name ' (Ref=' ref_name ')'], ...
    b.names ...
    );

disp('Done!');

ClearVariables;