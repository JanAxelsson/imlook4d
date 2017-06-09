
%
% model_test 
%
% http://www.walkingrandomly.com/?p=5196
% 
%
% Jan Axelsson

% Prerequisites:
% imlook4d_ROI_data populated by "SCRIPTS/ROI Data to Workspace"
%
format compact
ref = 1;

% Resample
TACT = imlook4d_ROI_data
%TACT = resample1D( TACT, 'evenly_distributed', 10)
TACT = resample1D( TACT, 's_to_min')

% Ref region
Cref = TACT.mean(:,ref);

% SRTM
k2_start = 0.23;
BP_start = 2;
pguess = [0.8 , k2_start, k2_start/(1+BP_start) ];
pguess = [0.8 , k2_start, BP_start ];

model = 'Zhou';
%model = 'Lammertsma';
model = 'Turku';


[TACT_out p] = regionalModel( TACT , Cref, @srtm, pguess,model);

% Get parameters    
     R1 = p(1,:)
     k2 = p(2,:)
     BP = p(3,:)
    
% Plot
figure;
plot( TACT.midtime, TACT.mean,'.' )

hold on
plot( TACT_out.midtime, TACT_out.mean, '-b' )

%% Logan 
%
% Schematic analysis:
% TACT -> minutes -> get Cref -> logan -> subrange -> fit

% TACT to minutes
TACT = imlook4d_ROI_data;
TACT = resample1D( TACT, 's_to_min');

% Ref region to vector
ref=1;
Cref = TACT.mean(:,ref);

% Logan coordinate system
TACT_logan = resample1D( TACT, 'logan', Cref, 0.216);  


% Extract data to fit
TACT_subrange = resample1D( TACT_logan, 'sub_range',32,'end'); 
size(TACT_subrange)

% Perform fit
pguess = [ 0 3  ]
[TACT_fit p] = regionalModel( TACT_subrange , Cref, @Logan, pguess);

% Plot
figure;
plot( TACT_logan.midtime, TACT_logan.mean,'.' )
hold on
plot( TACT_fit.midtime, TACT_fit.mean, '-b' );

p
