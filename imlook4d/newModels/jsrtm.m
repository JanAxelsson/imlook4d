function data =  jsrtm( data)

    % SRTM (Simplified Reference Tissue Model)
    %
    % Inputs:
    %   data.midtime = time points
    %   data.reftact = reference activity curve in time points
    %   data.tact    = activity curve for ROI
    %
    % Outputs:
    %   data.srtm.par  = values for [ R1, k2, k2p, k2a, BP ]; 
    %   data.srtm.name = { 'R1', 'k2', 'k2p','k2a','BP'};
    %   data.srtm.fitted_curve = fitted time-activity curve
    %   data.srtm.k2p  = value of k2p (which can be used in SRTM2); 
    %
    % Example:
    %   a = jsrtm( data) 
    
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
    %  SRTM
    % --------   
    
    % Set up the linear system of equations (SRTM):
    % 
    %
    % C(t0)=R1*CR(t0)+k2*int(CR(0:t0))-k2a*int(C(0:t0))
    % C(t1)=R1*CR(t1)+k2*int(CR(0:t1))-k2a*int(C(0:t1))
    % ...
    % C(tn)=R1*CR(tn)+k2*int(CR(0:tn))-k2a*int(C(0:tn))
    % i.e. C=AX, where A(:,1)=CR(t), A(:,2)=int(CR(t)), A(:,3)=int(C(t))
    %
    % C = roi curve ( in column)   called roitac below
    % CR= ref curve
    %
    % A = [ CR(t) int(CR(t)) -int(C(t)) ]   (columns) called  ASRTM below
    %
    %     | R1  |
    % X = | k2  |
    %     | k2a |  
    
    ASRTM = zeros(t_points ,3); % Design matrix is [t_points x 3 parameters] matrix
   
    ASRTM(:,1) = reftac;  % CR(t0)
    ASRTM(:,2) = integrate( reftac, dt);  % int(CR(0:t))
    ASRTM(:,3) = -integrate( roitac, dt); % -int(C(t))

    %LSQ-estimation using, solving for X = lscov(A,C)
    [parest se mse]   = lscov(ASRTM,roitac); 
    modfit_srtm = ASRTM * parest;
    R1  = parest(1); %K1/K1p
    k2  = parest(2); % k2 of target region
    k2p = k2/R1; % k2 of ref region (used in SRTM2 as a fixed parameter; should be determined for ONE high binding region)
    k2a = parest(3); % k2a=k2/(1+BP)
    BP  = k2/k2a - 1;
 
          
    % --------
    %  Output
    % --------    
    data.srtm.par = [ R1, k2, k2p, k2a, BP ]; 
    data.srtm.name = { 'R1', 'k2', 'k2p','k2a','BP'};
    data.srtm.fitted_curve = modfit_srtm;
    data.srtm.k2p = k2p;
    
    disp(data.srtm.name );
    disp(data.srtm.par );

    
end