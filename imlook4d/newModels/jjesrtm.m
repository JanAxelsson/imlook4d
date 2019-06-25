function out =  jjesrtm( matrix, t, dt, Cr, Frame0)

    % Extended SRTM (Simplified Reference Tissue Model)
    % (https://doi.org/10.1016/j.neuroimage.2006.06.038)
    %
    % Inputs:
    %   matrix = data with last dimension being frames (could be image matrix, or ROI values)
    %   t = frame start times in minutes
    %   dt = frame duration in minutes
    %   Cr = reference time-activity curve [ 1 N ] 
    %   Frame0 = frame for start of task (BP0 calculated prior to f, BP1 post frame f)
    %
    %   If zero inputs arguments, then out.names and out.units are
    %   returned.  This may be used for dialog boxes previous to running
    %   this function
    %
    % Outputs:
    %   out.pars  = cell array with matrices {BP0, BP1, R1, k2, k2p, k2a, k2b}; 
    %   out.names = { 'dBP', 'BP0', 'BP1','R1', 'k2', 'k2p','k2a','k2b'};
    %   out.units = { '1', '1','1','1', 'min-1', 'min-1','min-1','min-1'};
    %  
    %   Cell array with cells for each ROI:
    %     out.X = X-axis 
    %     out.Y = Y-axis  
    %     out.Xref = Cr x-axis (same times, most often)
    %     out.Yref = Cr
    %     out.Xmodel = model X-axis
    %     out.Ymodel = model Y-axis 
    %     out.residual = Y - Ymodel
    
    warning('off','MATLAB:lscov:RankDefDesignMat')
    warning('off','MATLAB:nearlySingularMatrix')
    warning('off','MATLAB:rankDeficientMatrix')
    
    out.names = { 'dBP', 'BP0', 'BP1','R1', 'k2', 'k2p','k2a','k2b'};
    out.units = { '1','1','1','1', 'min-1', 'min-1','min-1','min-1'};   
        
    if nargin == 0
        return
    end
    
   % Keep frame start time and duration (in seconds)
    out.extras.frameStartTime = t;
    out.extras.frameDuration = dt;
    
    % time
    tmid = t + 0.5 * dt;
    dt      = [tmid(1), tmid(2:length(tmid))-tmid(1:length(tmid)-1)]; % For integration
    
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
    
    % TODO: Is this closer to Jarkkos ?
    Ct  = [Ct(:,1)/2, (Ct(:,2:end)+Ct(:,1:end-1))/2];
    Cr  = [Cr(:,1)/2, (Cr(:,2:end)+Cr(:,1:end-1))/2];
    

    % Derived variables
    t_points = length(tmid);
  

    % ----------------
    %  Extended SRTM model
    % ---------------- 
    % 
    % Y = eq 6, 7 from reference (https://doi.org/10.1016/j.neuroimage.2006.06.038)
    % but using notation from https://doi.org/10.1016/S1053-8119(03)00186-1
    %
    % k2a = k2 / ( 1 + BP0)
    % k2b = k2 / (1 + BP1)
    %
    % Solve for R1, k2a, k2b, k2. Calculate BP0, BP1 afterwards
    %
    % Set up the linear system of equations (SRTM):
    % 
    %
    % C(t0)=R1*CR(t0)+k2*int(CR(0:t0))-k2a*int(C(0:t0))-k2b*int2(C(0:t0))
    % C(t1)=R1*CR(t1)+k2*int(CR(0:t1))-k2a*int(C(0:t1))-k2b*int2(C(0:t1))
    % ...
    % C(tn)=R1*CR(tn)+k2*int(CR(0:tn))-k2a*int(C(0:tn))-k2b*int2(C(0:tn))
    % i.e. C = A * X, where A(:,1)=CR(t), A(:,2)=int(CR(t)), A(:,4)=int(C(t)), A(:,3)=int2(C(t))
    % 
    % int(C(0:t0)) is simply area under curve in first frame = C(frame1) * dt(frame1)
    % int  is integrated up to T0, and is then set constant to last value for remaining frames
    % int2 is integral from time T0 onwards (and set to zero for all frames before T0)
    % 
    %
    % C = measured roi curve ( one time-activity curve in each column)  
    % CR= ref curve
    %
    % A = [ CR(t) int(CR(t)) -int(C(t))  -int2(C(t)) ]   (columns) called A below. Integral int is from 0-T0, and int2 from T0-end
    %                                    
    %     | R1  |
    % X = | k2  |
    %     | k2a |  
    %     | k2b |
    
    N = length(Ct); % Number of frames
    rangePreT0 = 1 : Frame0-1;
    rangePastT0 = Frame0 : N;

    % Integral of Cr
    integral_Cr =  cumsum( Cr .* dt );

    
    A = zeros(t_points ,3); % Design matrix is [t_points x 3 parameters] matrix
   
    A(:,1) = Cr;  % CR(t0)
    A(:,2) = cumsum( Cr .* dt);  % int(CR(0:t))
    
    for i = 1:n
        % Time T0 is when task switch occurs.
        % Frame0 starts at T0
        % Frame0-1 ends at T0
            
        % Integral of Ct pre Frame 0
        integral_Ct =  cumsum( Ct(i,:) .* dt );
        integral_Ct(rangePastT0) = integral_Ct( Frame0-1); % Points after T0 are set to integral up to T0

        % Integral of Ct post Frame0 
        integral_Ct_from_T0 = cumsum( Ct(i,:) .* dt ) - integral_Ct( Frame0-1); 
        integral_Ct_from_T0(rangePreT0) = 0;

        A(:,3) = -integral_Ct; % -int(C(t)) prior to T0
        A(:,4) = -integral_Ct_from_T0; % -int(C(t)) from T0 to end

        %LSQ-estimation using, solving for X = lscov(A,C)
            %[X se mse]   = lscov(A,Ct(i,:)'); 
            %X = A\Ct(i,:)';  % Faster!
        
        % Faster!
        if ( rank(A) == 4)
            X = A\Ct(i,:)';  
        else
            X = [0; 0; 0; 0];
        end
        

        % modfit_srtm = A * X;
        R1(i)  = X(1); %K1/K1p
        k2(i)  = X(2); % k2 of target region
        k2p(i) = k2(i)/R1(i); % k2 of ref region (used in SRTM2 as a fixed parameter; should be determined for ONE high binding region)
        k2a(i) = X(3); % k2a=k2/(1+BP0)
        k2b(i) = X(4); % k2b=k2/(1+BP1)
        BP0(i)  = k2(i)/k2a(i) - 1;
        BP1(i)  = k2(i)/k2b(i) - 1;
        dBP(i) = BP1(i) - BP0(i);

        
        % For modelWindow compatibility: 
        if IS_ROI 
            out.X{i} = tmid;
            out.Y{i} = Ct(i,:);
            
            out.Xmodel{i} = out.X{i};
            out.Ymodel{i} = ( A * X )'; % X is the parameters found in model
            out.residual{i} = out.Y{i} - out.Ymodel{i};
        end

    end
          
    % --------
    %  Output
     % --------  
    R1 = reshape(R1, outsize);
    k2 = reshape(k2, outsize);
    k2p = reshape(k2p, outsize);
    k2a = reshape(k2a, outsize);
    k2b = reshape(k2b, outsize);
    BP0 = reshape(BP0, outsize);
    BP1 = reshape(BP1, outsize);
    dBP = reshape(dBP, outsize);
    
    out.pars = {dBP, BP0, BP1, R1, k2, k2p, k2a, k2b};
 
    out.xlabel = 'time';
    out.ylabel = 'C_t';

    if IS_ROI
        out.Xref = out.X{i};
        out.Yref = Cr;
    end

    
    % --------
    % Clean up
    % --------
   
    warning('on','MATLAB:lscov:RankDefDesignMat')
    warning('on','MATLAB:nearlySingularMatrix')
    warning('on','MATLAB:rankDeficientMatrix')
    
end
