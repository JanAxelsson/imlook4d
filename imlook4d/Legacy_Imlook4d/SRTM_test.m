
%
% SRTM 
%
% http://www.walkingrandomly.com/?p=5196
% 
%
% Jan Axelsson

% Prerequisites:
%  imlook4d_ROI_data populated by "SCRIPTS/ROI Data to Workspace"
%
% 
% global Cref;
% global dt;
% global model;  % Type of model

% Columns
ref = 1;  % ROI number for Cref
t = imlook4d_time(1:end-1)' / 60;
dt = imlook4d_duration(1:end-1)' / 60;
Cref = imlook4d_ROI_data.mean(1:end-1,ref);
C = imlook4d_ROI_data.mean(1:end-1,:);


t = imlook4d_time' / 60;
dt = imlook4d_duration' / 60;
Cref = imlook4d_ROI_data.mean(:,ref);
C = imlook4d_ROI_data.mean;

t = t + 0.5*dt;  % Midtime

%C(:,ref) = []; % Remove reference ROI

% TODO: Resample to each second
% N = sum(imlook4d_duration)
% t= 0:N;
% dt = ones(size(t));
% C = 
% Cref =



% Fit
 xdata = t';
 ydata = C(:,3)';
 
%  N = 30; % Number of seconds per sample
% start =(60*t(1));
% stop = (60*t(end));
% xdata = (start:start+N:stop) / 60 ;
% ydata = interp1(t,ydata,xdata,'linear');
% Cref = interp1(t,Cref,xdata,'linear')';
% 
% dt = ones(size(xdata))';


%Function to calculate the sum of residuals for a given p1 and p2
% R1 = p(1)
% k2 = p(2)
% P0 = p(3)

%starting guess
pguess = [0.8 , 0.2, 0.2/(1+3) ];
pguess = [0.8 , 0.23, 0.23/(1+3.27) ];

% Statistical toolbox (object version)
%mdl = NonLinearModel.fit(xdata, ydata, @SRTM_function, pguess)
%p=double( mdl.Coefficients(:,1) )

     model = 'Zhou';
     model = 'Lammertsma';
     model = 'Turku';


% Statistical toolbox (lighter version)
%[p,R,J,CovB,MSE,ErrorModelInfo] = nlinfit(xdata', ydata', @SRTM_function, pguess)


% http://se.mathworks.com/help/optim/ug/passing-extra-parameters.html

f=@(p,t)SRTM_function(p,t,model,Cref,dt)
[p,R,J,CovB,MSE,ErrorModelInfo] = nlinfit(xdata', ydata', f, pguess)

%[TACT_out p] = regionalModel( ydata' ,@SRTM_function, pguess,t,model,Cref,dt)


[TACT_out p] = regionalModel( imlook4d_ROI_data , Cref, @srtm, pguess,model)
% y = srtm(refRegion,coefficients, model)

% Get parameters
     R1 = p(1)
     k2 = p(2)
     P0 = p(3)  % = k2/(1+BP)
      
     BP = (k2 / P0) - 1
      
% Plot
figure;
plot( t, f(p,t) )

hold on
plot( t, C, '.' )
hold on
plot( t, C(:,2) - f([R1 k2 P0 ] ,t), '-b' )


