function out =  jjwater_doubleintegralmethod( matrix, t, dt, Ct1)

    % PET Water - double integral method
    %
    % Inputs:
    %   matrix = data with last dimension being frames (could be image matrix, or ROI values)
    %   t = frame start times in minutes
    %   dt = frame duration in minutes
    %   Ct1 = reference time-activity curve [ 1 N ], should be over whole brain
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
    %     out.Yref = Ct1
    %
    % Example: 
    %   % Export from imlook4d, where a whole-brain ROI is the current ROI. Then run: 
    %   tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs
    %   ref = tacts(imlook4d_ROI_number,:); % Current ROI
    %   a = jjwater_doubleintegralmethod( imlook4d_Cdata, imlook4d_time/60, imlook4d_duration/60, ref); % Fit to end frame
    %   flow = a.pars{1};
    %   imlook4d(flow);
    
    
    
    warning('off','MATLAB:lscov:RankDefDesignMat')
    warning('off','MATLAB:nearlySingularMatrix')
    
    % time
    tmid = t + 0.5 * dt;
    dt      = [tmid(1), tmid(2:length(tmid))-tmid(1:length(tmid)-1)];

    
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

    % ----------------
    %  Double integral method
    % ----------------

    %Define constants
    VT=0.86;
    VT1=0.86;
    f1=0.5;
    
    % Setup variables
    f = zeros(1,n);

    for i = 1:n
        % Elin Wallsten created the model from 
        % Koopman et al, J Cerb Blood Flow & Met

        %int(Ct*dt)
        %alpha=sum(Ct.*dt, 2); 
        alpha = sum( Ct(i,:).* dt);
        
        %(1/f1)*int(Ct1*dt)
        %beta=(1/f1)*sum(Ct1.*dt);
        beta = (1/f1)*sum( Ct1.* dt);
        
        %(1/VT1)*int(int(Ct1*du)*dt)
        %gamma=(1/VT1)*sum(cumsum(Ct1.*dt).*dt);  
        gamma = (1/VT1) * sum( integrate( Ct1, dt).*dt);
        
        %(1/VT)*int(int(Ct*du)*dt)
        %kappa=(1/VT)*sum(cumsum(Ct.*dt, 2).*dt, 2);
        kappa = (1/VT1) * sum( integrate( Ct(i,:), dt).*dt);

        f(i) = alpha ./ (beta + gamma - kappa);

        
        
        % For modelWindow compatibility: 
        if IS_ROI 
            out.X{i} = tmid;
            out.Y{i} = Ct(i,:);

            % TODO -- can the model fit be simulated as a C-tissue curve?
            
%             out.Xmodel{i} = out.X{i};
%             out.Ymodel{i} = ( A * X )'; % X is the parameters found in model
%             out.residual{i} = out.Y{i} - out.Ymodel{i};
        end

    end
          
    % --------
    %  Output
     % --------  
    f = reshape(f, outsize);

    
    out.pars = {f};
    out.names = { 'f'};
    out.units = { 'mL/cm3/min'};
    
    out.xlabel = 'time';
    out.ylabel = 'C_t';
      
    if IS_ROI 
        out.Xref = out.X{i};
        out.Yref = Ct1;
    end
    
    % --------
    % Clean up
    % --------
   
    warning('on','MATLAB:lscov:RankDefDesignMat')
    warning('on','MATLAB:nearlySingularMatrix')
    
end