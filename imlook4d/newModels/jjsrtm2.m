function out =  jjsrtm2( matrix, t, dt, Cr, k2p)

    % SRTM2 (Simplified Reference Tissue Model 2)
    %
    % Inputs:
    %   matrix = data with last dimension being frames (could be image matrix, or ROI values)
    %   t = frame start times in minutes
    %   dt = frame duration in minutes
    %   Cr = reference time-activity curve [ 1 N ] 
    %   k2p = from SRTM
    %
    % Outputs:
    %   out.pars  = cell array with matrices { R1, k2, k2a, BP }; 
    %   out.names = { 'R1', 'k2', 'k2a','BP'};
    %   out.units = { '1', 'min-1','min-1','1'};
    
    warning('off','MATLAB:lscov:RankDefDesignMat')
    warning('off','MATLAB:nearlySingularMatrix')

    % time
    tmid = t + 0.5 * dt;
    
    
    % activity
    s = size(matrix);
    switch length(s)
        case 2
            n = s(1);
            outsize = [ s(1) 1 ]; % reshape needs 2D input
        case 3
            n= s(1)*s(2);
            outsize = [ s(1) s(2)];
        case 4
            n = s(1)*s(2)*s(3);
            outsize = [ s(1) s(2) s(3)];
    end
        
    
    Ct = reshape( matrix, n, [] ) ;  % [  pixels frames ]
    
        
    Ct  = [Ct(:,1)/2, (Ct(:,2:end)+Ct(:,1:end-1))/2];
    Cr  = [Cr(:,1)/2, (Cr(:,2:end)+Cr(:,1:end-1))/2];

    % Derived variables
    t_points = length(tmid);

  
    % Integrate to mid times
    function value_vector = integrate( C, dt)
        value_vector = cumsum( C.*dt);% - 0.5 * C .* dt; % exclude activity from second half (after midtime)
    end        

    % ----------------
    %  SRTM model
    % ----------------   
    
    % Set up the linear system of equations (SRTM):
    % 
    %
    % C(t0)=R1*CR(t0)+k2*int(CR(0:t0))-k2a*int(C(0:t0))
    % C(t1)=R1*CR(t1)+k2*int(CR(0:t1))-k2a*int(C(0:t1))
    % ...
    % C(tn)=R1*CR(tn)+k2*int(CR(0:tn))-k2a*int(C(0:tn))
    % i.e. C = A * X, where A(:,1)=CR(t), A(:,2)=int(CR(t)), A(:,3)=int(C(t))
    %
    % C = roi curve ( one time-activity curve in each column)  
    % CR= ref curve
    %
    % A = [ CR(t) int(CR(t)) -int(C(t)) ]   (columns) called  ASRTM below
    %
    %     | R1  |
    % X = | k2  |
    %     | k2a |  
    
    
    % --------
    %  SRTM2
    % --------
    
    % Set up the linear system of equations (SRTM2):
    % C(t0) = R1*[CR(t0)+k2p*int(CR(0:t0))] - k2a*int(C(0:t0))
    % C(t1) = R1*[CR(t1)+k2p*int(CR(0:t1))] - k2a*int(C(0:t1))
    % ...
    % C(tn) = R1*[CR(tn)+k2p*int(CR(0:tn))] - k2a*int(C(0:tn))
    % i.e. C = A * X, where A(:,1)=[CR(t)+k2p*int(CR(0:tn))],  A(:,2)=int(C(t))
    %
    % C = roi curve ( one time-activity curve in each column)  
    % CR= ref curve
    %
    % A = [ {CR(t) + k2p*int(CR(t))}   -int(C(t)) ]   (columns) called  ASRTM below
    %
    %     | R1  |
    % X = |     |
    %     | k2a |  
    

    
    A = zeros(t_points ,2);% Design matrix is [t_points x 2 parameters] matrix
    A(:,1)  = Cr +  k2p * integrate( Cr, dt);  % CR(t) + k2p*int(CR(t))
    
    for i = 1:n
        A(:,2) = -integrate(  Ct(i,:), dt);  % -int(Ct(0:t))

        %LSQ-estimation using, solving for X = lscov(A,C)
        [X se mse]   = lscov(A,Ct(i,:)'); 
        %X = A\Ct(i,:)';  % Faster!

        % modfit_srtm = A * X;
        R1_(i)= X(1); %K1/K1p
        k2_(i) = k2p * R1_(i); 
        k2a_(i)= X(2); % k2a=k2/(1+BP)
        BP_(i) = k2_(i)/k2a_(i) - 1;  

    end
          
    % --------
    %  Output
     % --------  
    R1_ = reshape(R1_, outsize);
    k2_ = reshape(k2_, outsize);
    k2a_ = reshape(k2a_, outsize);
    BP_ = reshape(BP_, outsize);
    
    out.pars = {R1_, k2_,  k2a_, BP_};
    out.names = { 'R1_', 'k2_','k2a_','BP_'};
    out.units = { '1', 'min-1','min-1','1'};

    
    % --------
    % Clean up
    % --------
   
    warning('on','MATLAB:lscov:RankDefDesignMat')
    warning('on','MATLAB:nearlySingularMatrix')
    
end