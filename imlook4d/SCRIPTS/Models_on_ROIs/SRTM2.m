StoreVariables;
Export;

model_name = 'SRTM2';
ref_name = imlook4d_ROINames{imlook4d_ROI_number};

% First run SRTM (same code as SRTM script copied here)

disp('Calculating time-activity curves ...');
tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs

ref = generateReferenceTACT( imlook4d_current_handles)
tact = tacts;  % all ROIs


disp('Calculating SRTM ...');
a = jjsrtm( tact, imlook4d_time/60, imlook4d_duration/60, ref);

% store for SRTM2
k2p_values = a.pars{3};
k2p = median( k2p_values(k2p_values>0) );  % Positive k2p 
disp(['Median positive k2p = ' num2str(k2p) ]);


% % Display
% S = roi_table_gui( ...
%     [imlook4d_ROINames(1:end-1) num2cell( cell2mat(a.pars) ) ], ...
%     model_name, ...
%     a.names ...
%     );


disp('Calculating SRTM2 ...');

b = jjsrtm2( tact, imlook4d_time/60, imlook4d_duration/60, ref,k2p);

% Display
modelWindow( ...
    b , ...
    imlook4d_ROINames(1:end-1), ...
    [model_name ' (k2p = ' num2str(k2p) ')'] ...
    );

disp('Done!');

ClearVariables;