function [R1, k2, BP] = imlook4d_srtm(TACT, refColumn, model)
%
% srtm function for imlook4d
%
% Input:
%           TACT            struct containing:
%               .mean        2D matrix - ROI data in columns
%               .midtime     1D matrix - frame midtime in column
%               .duration    1D matrix - frame duration in column
%               .names       Cell - ROI names
%                  
%           refColumn       column number for reference region
%           model           'Turku', 'Lammertsma' or 'Zhou'
%
% Output:
%           [R1, k2, BP]    SRTM 
%
% Example:
%   From imlook4d menu: "SCRIPTS/ROI/ROI data to workspace"
%   imlook4d_srtm(imlook4d_ROI_data, 1, 'Turku');
%
%
% (from http://www.turkupetcentre.net/petanalysis/model_compartmental_ref.html):
% ------------------------------------------------------------------------------
% Assumptions
%   - Reference region has no specific binding (devoid of receptors)
%   - K1/k2 is same in the regions of interest and in the reference region
%   - Kinetics in all brain regions is fast and simple: 
%       if we had an arterial plasma input function, we could fit one-tissue compartmental model to tissue curves fairly well.
%
% Reference tissue model also provides an index for the perfusion and transport of tracer to the tissue (R1)
%
% Jan Axelsson

TAB = sprintf('\t')

% Resample
TACT = resample1D( TACT, 'evenly_distributed', 100)
TACT = resample1D( TACT, 's_to_min')

% Ref region
Cref = TACT.mean(:,refColumn);

% Remaining columns
cols = [ 1 : size(TACT.mean,2) ];
cols = cols( cols~= refColumn);
TACT.mean = TACT.mean(:,cols)
TACT.names = TACT.names(cols)

% SRTM
k2_start = 0.23;
BP_start = 2;
pguess = [0.8 , k2_start, k2_start/(1+BP_start) ];
pguess = [0.8 , k2_start, BP_start ];


[TACT_out p] = regionalModel( TACT , Cref, @srtm, pguess,model);

% Print parameters  
    R1 = p(1,:);
    k2 = p(2,:);
    BP = p(3,:);
     
    disp( [ TAB strjoin(TACT.names', TAB) ]);
    disp( [ 'R1' TAB sprintf( ['%d' TAB], R1) ] )
    disp( [ 'k2' TAB sprintf( ['%d' TAB], k2) ] )
    disp( [ 'BP' TAB sprintf( ['%d' TAB], BP) ] )

    
% Plot
% figure;
% plot( TACT.midtime, TACT.mean,'.' )
% 
% hold on
% plot( TACT_out.midtime, TACT_out.mean, '-b' )



