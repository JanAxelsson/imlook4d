function data =  jsrtm( data)

    % time
    tmid = data.midtime;
    dt = [tmid(1); tmid(2:length(tmid))-tmid(1:length(tmid)-1)];
    
    % activity
    reftac = data.reftact;
    roitac = data.tact;

    % Derived variables
    t_points = length(tmid);

  
    % Integrate to mid times
    function value_vector = integral( C, dt)
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
    ASRTM(:,2) = integral( reftac, dt);  % int(CR(0:t))
    ASRTM(:,3) = -integral( roitac, dt); % CR(t0)

    %LSQ-estimation using, solving for X = lscov(A,C)
    [parest se mse]   = lscov(ASRTM,roitac); 
    modfit_srtm = ASRTM * parest;
    R1  = parest(1); %K1/K1p
    k2  = parest(2); % k2 of target region
    k2p = k2/R1; % k2 of ref region (used in SRTM2 as a fixed parameter; should be determined for ONE high binding region)
    k2a = parest(3); % k2a=k2/(1+BP)
    BP  = k2/k2a - 1;
   

          
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
       
    ASRTM2(:,1)  = reftac +  k2p * integral( reftac, dt);  % CR(t0)
    ASRTM2(:,2) = -integral( roitac, dt);  % int(CR(0:t))
    
    %LSQ-estimation using lscov
    [parest se mse]   = lscov(ASRTM2,roitac); % Yields also SEs
    modfit_srtm2=ASRTM2*parest;
    R1_ = parest(1); %K1/K1p
    k2_ = k2p*R1; 
    k2a_= parest(2); % k2a=k2/(1+BP)
    BP_ = k2_/k2a_ - 1;  
    
    
          
    % --------
    %  Output
    % --------    
    data.srtm.par = [ R1, k2, k2p, k2a, BP ]; 
    data.srtm.name = { 'R1', 'k2', 'k2p','k2a','BP'};
    data.srtm.fitted_curve = modfit_srtm;
    disp(data.srtm.name );
    disp(data.srtm.par );
    
    data.srtm2.par = [ R1_, k2_, k2a_ ,BP_ ];
    data.srtm2.name = { 'R1_', 'k2_', 'k2a_','BP_'};
    data.srtm2.fitted_curve = modfit_srtm2;
    disp(data.srtm2.name );
    disp(data.srtm2.par );
    
end