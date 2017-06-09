function [TACT_out coefficients] = regionalModel( TACT, inputFunction, modelFunction, pguess, varargin)
% Fit a pharmaco-kinetic model to data in a TACT-struct, defined below.
% Fitted model coefficients ("coefficients") and modelled data ("TACT_out") at the sampling points are
% output.
%
% IN :
%   TACT            tact-struct of ROI time-activity values
%   inputFunction   input function also as tact-struct
%   modelFunction   handle to model function
%   pguess          start values for fitting coefficients 
%   varargin        additional constants defined in the modelFunction
%
% A tact-struct is defined as:
%   TACT.mean
%   TACT.midtime
%   TACT.duration
%   TACT.names
%   ....
%
% OUT:
%   TACT_out        tact-struct with data values in time points from TACT, using fitted model coefficients
%   coefficients    fitted model coefficients
%
% Jan Axelsson 2015-NOV-23

dt = TACT.duration;
t = TACT.midtime;
cols = size(TACT.mean,2);

% Make one time column per ROI
if size(t,2)==1
    t  = repmat( t,[1 cols]);
    dt = repmat(dt,[1 cols]);
end

% make f  function of only coefficients p, and time t
f=@(p,t)modelFunction(t,dt,inputFunction,p,varargin{:}); 

for i=1:cols
    disp(['Fitting ROI = ' num2str(i) ]);
    [coefficients(:,i),R,J,CovB,MSE,ErrorModelInfo] = nlinfit( t(:,i), TACT.mean(:,i), f, pguess); % fit
    TACT_out.mean(:,i) = f( coefficients(:,i), t(:,i) ); % calculate values, applying found coefficients
end

% Copy from input for these struct fields
TACT_out.names = TACT.names;
TACT_out.midtime = TACT.midtime;
TACT_out.duration = TACT.duration;
