function out =  jjwater( matrix, t, dt_in, Cinp)

    % PET Water - perfusion
    %
    % Reference:
    % 
    %
    % Inputs:
    %   matrix = data with last dimension being frames (could be image matrix, or ROI values)
    %   t = frame start times in minutes
    %   dt = frame duration in minutes
    %   Cinp = input function [ 1 N ] 
    %
    %   If zero inputs arguments, then out.names and out.units are
    %   returned.  This may be used for dialog boxes previous to running
    %   this function
    %
    % Outputs:
    %   out.pars  = cell array with matrices { BPND, DVR, intercept}; 
    %   out.names = { 'BPND', 'DVR', 'intercept'};
    %   out.units = { '1','1','min'};
    %  
    %   Cell array with cells for each ROI:
    %     out.X = X-axis 
    %     out.Y = Y-axis 
    %     out.Xref = Ct1 x-axis (same times, most often)
    %     out.Yref = Cinp
    %

    
    warning('off','MATLAB:lscov:RankDefDesignMat')
    warning('off','MATLAB:nearlySingularMatrix')
        
    out.names = { 'F(K1)','k2'};
    out.units = { 'mL/cm3/min','min-1'};
    
    % Keep frame start time and duration (in seconds)
    out.extras.frameStartTime = t;
    out.extras.frameDuration = dt_in;
        
    if nargin == 0    
        return
    end
    
    % time
    tmid = t + 0.5 * dt_in;
    dt = [tmid(1), tmid(2:length(tmid))-tmid(1:length(tmid)-1)];

    
    % activity
    s = size(matrix);
    switch length(s)
        case 2
            IS_ROI = true; 
            n = s(1);
            outsize = [ s(1) 1 ]; % reshape needs 2D input
        case 3
            IS_ROI = false;  
            n= s(1)*s(2);
            outsize = [ s(1) s(2)];
        case 4
            IS_ROI = false; 
            n = s(1)*s(2)*s(3);
            outsize = [ s(1) s(2) s(3)];
    end
        
    
    Ct = reshape( matrix, n, [] ) ;  % [  pixels frames ]
  
  
    % Integrate to mid times
    function value_vector = integrate( C, dt)
        value_vector = cumsum( C.*dt);
    end        

    % Derived variables
    t_points = length(tmid);
    
    % ----------------
    %  Linearized perfusion
    % ----------------
    
    % Set up the linear system of equations :
    % 
    %
    % C(t0)=K1*Ca(t0)-k2*C(t0)
    % C(t1)=K1*int(Ca(0:t1))-k2*int(C(0:t1))
    % ...
    % C(tn)=K1*int(Ca(0:tn))-k2*int(C(0:tn))
    % i.e. C = A * X, where A(:,1)=int(Ca(t)), A(:,2)=int(C(t))
    %
    % C = roi curve ( one time-activity curve in each column)  
    % CR= ref curve
    %
    % A = [ CR(t) int(CR(t)) -int(C(t)) ]   (columns) called  ASRTM below
    %
    %     | K1  |
    % X = |     |
    %     | k2  |  
    %
    % Do two steps, one for finding whole brain delay
    % (will work on the sum of all tissue-curves)
    
    %
    % Step 1) Find delay and shift
    %
    Cb = zeros(size(Cinp));
    A = zeros(t_points ,2);
    for i = 1:30
        delay = i;
        Cb(delay+1:end) = Cinp(1:end-delay);
        averageCt = mean( Ct,1); 
        A(:,1) = cumsum( Cb .* dt);  % int(Cinp(0:t))
        A(:,2) = -cumsum( averageCt .* dt); % -int(C(t))
        [X se mse(i)]   = lscov(A,averageCt');
    end
    
    [M,index] = min(mse); % index with lowest mean square error
    Cb(index+1:end) = Cinp(1:end-index);
    Cinp = Cb;
    
    %
    % Step 2) work on each tissue curve 
    %
    
    A = zeros(t_points ,2); % Design matrix is [t_points x 2 parameters] matrix
    A(:,1) = cumsum( Cinp .* dt);  % int(Cinp(0:t))

    for i = 1:n

        A(:,2) = -cumsum( Ct(i,:) .* dt); % -int(C(t))

        %LSQ-estimation using, solving for X = lscov(A,C)
            %[X se mse]   = lscov(A,Ct(i,:)'); 
            %X = A\Ct(i,:)';  % Faster!
        
        % Faster!
        try
            if ( rank(A) == 2)
                X = A\Ct(i,:)';
            else
                X = [0; 0];
            end
        catch
            X = [0; 0];
        end

        % modfit_srtm = A * X;
        K1(i)  = X(1); 
        k2(i)  = X(2); 

        
        % For modelWindow compatibility: 
        if IS_ROI 
            out.X{i} = tmid;
            out.Y{i} = Ct(i,:);
            
            out.Xmodel{i} = out.X{i};
            out.Ymodel{i} = ( A * X )'; % X is the parameters found in model
            out.residual{i} = out.Y{i} - out.Ymodel{i};
        end

    end
    
    % Rename K1
    f = K1;

          
    % --------
    %  Output
     % --------  
    f = reshape(f, outsize);

    out.pars = {f, k2};
    
    out.xlabel = 'time';
    out.ylabel = 'C_t';
      
    if IS_ROI 
        out.Xref = out.X{i};
        out.Yref = Cinp;
    end
    
    % NOTE: There is not enough information for short water scans on GE
    % scanner, where the T and dT:s don't add up.
    % Store for use in SaveTact, when called from modelWindow
    out.extras.frameStartTime = t;
    out.extras.frameDuration = dt_in;
    
    % --------
    % Clean up
    % --------
   
    warning('on','MATLAB:lscov:RankDefDesignMat')
    warning('on','MATLAB:nearlySingularMatrix')
    
end
