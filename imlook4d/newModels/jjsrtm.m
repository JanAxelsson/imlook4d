function out =  jjsrtm( matrix, t, dt, Cr)

    % SRTM (Simplified Reference Tissue Model)
    %
    % Inputs:
    %   matrix = data with last dimension being frames (could be image matrix, or ROI values)
    %   t = frame start times in minutes
    %   dt = frame duration in minutes
    %   Cr = reference time-activity curve [ 1 N ] 
    %
    % Outputs:
    %   out.pars  = cell array with matrices { R1, k2, k2p, k2a, BP }; 
    %   out.names = { 'R1', 'k2', 'k2p','k2a','BP'};
    %   out.units = { '1', 'min-1', 'min-1','min-1','1'};
    
    warning('off','MATLAB:lscov:RankDefDesignMat')
    warning('off','MATLAB:nearlySingularMatrix')

    % time
    tmid = t + 0.5 * dt;
    dt      = [tmid(1), tmid(2:length(tmid))-tmid(1:length(tmid)-1)];
    
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
    
    % TODO: Is this closer to Jarkkos ?
    Ct  = [Ct(:,1)/2, (Ct(:,2:end)+Ct(:,1:end-1))/2];
    Cr  = [Cr(:,1)/2, (Cr(:,2:end)+Cr(:,1:end-1))/2];
    

    % Derived variables
    t_points = length(tmid);

  
    % Integrate to mid times
    function value_vector = integrate( C, dt)
        value_vector = cumsum( C.*dt);% -0.5 * C .* dt; % exclude activity from second half (after midtime)
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
    
    A = zeros(t_points ,3); % Design matrix is [t_points x 3 parameters] matrix
   
    A(:,1) = Cr;  % CR(t0)
    A(:,2) = integrate( Cr, dt);  % int(CR(0:t))
    
    for i = 1:n

        A(:,3) = -integrate( Ct(i,:), dt); % -int(C(t))

        %LSQ-estimation using, solving for X = lscov(A,C)
        [X se mse]   = lscov(A,Ct(i,:)'); 
        %X = A\Ct(i,:)';  % Faster!

        % modfit_srtm = A * X;
        R1(i)  = X(1); %K1/K1p
        k2(i)  = X(2); % k2 of target region
        k2p(i) = k2(i)/R1(i); % k2 of ref region (used in SRTM2 as a fixed parameter; should be determined for ONE high binding region)
        k2a(i) = X(3); % k2a=k2/(1+BP)
        BP(i)  = k2(i)/k2a(i) - 1;

    end
          
    % --------
    %  Output
     % --------  
    R1 = reshape(R1, outsize);
    k2 = reshape(k2, outsize);
    k2p = reshape(k2p, outsize);
    k2a = reshape(k2a, outsize);
    BP = reshape(BP, outsize);
    
    out.pars = {R1, k2, k2p, k2a, BP};
    out.names = { 'R1', 'k2', 'k2p','k2a','BP'};
    out.units = { '1', 'min-1', 'min-1','min-1','1'};

    
    % --------
    % Clean up
    % --------
   
    warning('on','MATLAB:lscov:RankDefDesignMat')
    warning('on','MATLAB:nearlySingularMatrix')
    
end