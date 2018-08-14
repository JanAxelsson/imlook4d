function data =  jsrtm2( data, k2p)

    % SRTM2, more robust version of SRTM.  Intended for parametric images,
    % but this routine only works for ROI analysis.
    %
    % Inputs:
    %   data.midtime = time points
    %   data.reftact = reference activity curve in time points
    %   data.tact    = activity curve for ROI
    %   k2p = global k2p from srtm
    %
    % Outputs:
    %   data.srtm.par  = values for [ R1, k2, k2p, k2a, BP ]; 
    %   data.srtm.name = { 'R1', 'k2', 'k2p','k2a','BP'};
    %   data.srtm.fitted_curve = fitted time-activity curve
    %
    % Example:
    %   a = jsrtm( data) % a.srtm.k2p is calculated here
    %   a = jsrtm2( a, a.srtm.k2p ) 

    % time
    tmid = data.midtime;
    dt = [tmid(1); tmid(2:length(tmid))-tmid(1:length(tmid)-1)];
    
    % activity
    reftac = data.reftact;
    roitac = data.tact;

    % Derived variables
    t_points = length(tmid);
 
  
    % Integrate to mid times
    function value_vector = integrate( C, dt)
        value_vector = cumsum( C.*dt);% - 0.5 * C .* dt; % exclude activity from second half (after midtime)
    end            
    % --------
    %  SRTM2
    % --------
    
    % Set up the linear system of equations (SRTM2):
    % C(t0)=R1*[CR(t0)+k2p*int(CR(0:t0))]-k2a*int(C(0:t0))
    % C(t1)=R1*[CR(t1)+k2p*int(CR(0:t1))]-k2a*int(C(0:t1))
    % ...
    % C(tn)=R1*[CR(tn)+k2p*int(CR(0:tn))]-k2a*int(C(0:tn))
    % i.e. C=AX, where A(:,1)=[CR(t)+k2p*int(CR(0:tn))],  A(:,2)=int(C(t))

    ASRTM2 = zeros(t_points ,2);% Design matrix is [t_points x 2 parameters] matrix
       
    ASRTM2(:,1)  = reftac +  k2p * integrate( reftac, dt);  % CR(t0)
    ASRTM2(:,2) = -integrate( roitac, dt);  % int(CR(0:t))
    
    %LSQ-estimation using lscov
    [parest se mse]   = lscov(ASRTM2,roitac); % Yields also SEs
    modfit_srtm2=ASRTM2*parest;
    R1_ = parest(1); %K1/K1p
    k2_ = k2p*R1_; 
    k2a_= parest(2); % k2a=k2/(1+BP)
    BP_ = k2_/k2a_ - 1;  
    
    
          
    % --------
    %  Output
    % --------    
    
    data.srtm2.par = [ R1_, k2_, k2a_ ,BP_ ];
    data.srtm2.name = { 'R1_', 'k2_', 'k2a_','BP_'};
    data.srtm2.fitted_curve = modfit_srtm2;
    disp(data.srtm2.name );
    disp(data.srtm2.par );
    
end