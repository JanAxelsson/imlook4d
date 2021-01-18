function out =  jjpatlak_ref_with_k3( k3, matrix, t, dt, Cinp, range)


    % TEST:
    % jjpatlak_ref_with_k3(0.01, imlook4d_ROI_data.mean, imlook4d_time, imlook4d_duration, mean( imlook4d_ROI_data.mean,2), [10 24])
    %

    % Patlak modified for reference region with specific uptake
    %
    % Calls jjpatlak with a Cinp modified with k3.  
    %
    % Inputs:
    %   k3 = rate constant for specific irreversible binding in reference region
    %
    %   See jjpatlak for other inputs
    %
    %   If zero inputs arguments, then out.names and out.units are
    %   returned.  This may be used for dialog boxes previous to running
    %   this function
    %
    % Outputs:
    %   out.pars  = cell array with matrices { Ki, intercept}; 
    %   out.names = { 'Ki', 'intercept'};
    %   out.units = { 'min-1','1'};
    %  
    %   Cell array with cells for each ROI:
    %     out.X = Patlak X-axis 
    %     out.Y = Patlak Y-axis 
    %     out.Xmodel = Patlak X-axis for fitted range
    %     out.Ymodel = Patlak Y-axis for fitted range
    %     out.residual = Y - Ymodel, diff for fitted range

    % Integrate to mid times
    function value_vector = integrate( C, dt)
        value_vector = cumsum( C.*dt);% -0.5 * C .* dt; % exclude activity from second half (after midtime)
    end       

    % Function to integrate to modify Cinp

    C = 0;
    for i = 1 : length(t)
        C(i) = C_inp(i) -  k3 * Cinp( i ) * exp( k3 * ( t(i) - t ) ) * dt(i);
    end

    % ----------------
    %  Create new input function
    % ----------------  
    
    
%     modified_Cinp = Cinp - k3 * integrate( ... 
%         exp( k3 * ( ( ) ) , ...
%         dt);
%     
    
    
    newX = integrate(Cinp,dt) ./ Cinp; % integeral{Cinp}/Cinp 
    

    out =  jjpatlak(  matrix, t, dt, modified_Cinp, range)
          
    % --------
    %  Output
     % --------  
    Ki = reshape(Ki, outsize);
    intercept = reshape(intercept, outsize);
    
    out.pars = {Ki, intercept};
    
    out.xlabel = '\int_{0}^{t} C_a dt / C_a';
    out.ylabel = 'C_t / C_a';

    
    % --------
    % Clean up
    % --------
   
    warning('on','MATLAB:lscov:RankDefDesignMat')
    warning('on','MATLAB:nearlySingularMatrix')
    
end
