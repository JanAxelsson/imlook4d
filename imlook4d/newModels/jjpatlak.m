function out =  jjpatlak( L3, matrix, t, dt, Cinp, range)

    % Reference Patlak 
    %
    % (with extension for specific binding in reference region, doi:10.1016/j.jns.2007.01.057 )
    %
    % Inputs:
    %   L3 = (unit min-1), rate constant for specific irreversible binding in reference region (zero when no specific binding in reference region = normal patlak)
    %   matrix = data with last dimension being frames (could be image matrix, or ROI values)
    %   t = frame start times in minutes
    %   dt = frame duration in minutes
    %   Cinp = input function [ 1 N ] 
    %   range = [ startFrame endFrame].  If endFrame is missing, then  endFrame = last frame number
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
    
    warning('off','MATLAB:lscov:RankDefDesignMat')
    warning('off','MATLAB:nearlySingularMatrix')
    
    out.names = { 'Ki', 'intercept'};
    out.units = { 'min-1','1'};
        
    if nargin == 0    
        return
    end
    
    
    if length(range) == 1
        startFrame = range(1);
        endFrame = length(t);
    end
    if length(range) == 2
        startFrame = range(1);
        endFrame = range(2);
    end
    
    regressionRange = startFrame:endFrame; % integrate from startFrame to end

    
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

    
    % time
    tmid = t + 0.5 * dt;
    dt      = [tmid(1), tmid(2:length(tmid))-tmid(1:length(tmid)-1)]; % For integration
    
  
    % Integrate to mid times
    function value_vector = integrate( C, dt)
        value_vector = cumsum( C.*dt);% -0.5 * C .* dt; % exclude activity from second half (after midtime)
    end        


    % SPECIAL Modify Cinp if specific binding in reference region
    if (L3 ~= 0)
        sub(1) = 0;
        for i = 2 : length(t)
            range = 1:i;
            sub(i) =  sum( ...
                L3 ...
                * exp(L3 * ( tmid(range) - t(i) ) ) ... 
                .* Cinp( range ) ... 
                .* dt(range) ...
            ); % Convolution for time t(i)
        end

        % Subtract specific binding from reference region
        Cinp = Cinp - sub;
    end

    % ----------------
    %  Patlak model
    % ----------------  
    
    newX = integrate(Cinp,dt) ./ Cinp; % integeral{Cinp}/Cinp 
    % Limit range
    tempX =  newX(regressionRange)';  % X-values in range
    
    for i = 1:n       
        newY = Ct(i,:)./Cinp;    % Ct / Cinp

        % Limit range
        tempY = newY(regressionRange)';  % Y-values in range
        
        % Two alternatives:
        %p = linortfit2(double(newX), double(tempY)); % Orthogonal regression
        p = [tempX ones(length(tempX),1) ] \ tempY;    % Normal regression
      
        Ki(i) = p(1);
        intercept(i) = p(2);
        
        
        % For modelWindow compatibility:
        if IS_ROI
            out.X{i} = newX; % Measured Logan X-axis
            out.Y{i} = newY; % Measured Logan Y-axis
            % Calculate Model X, Y, residual (for Pat lak fit range)
            
            out.Xmodel{i} = out.X{i}(regressionRange);
            out.Ymodel{i} = Ki(i) * out.Xmodel{i} + intercept(i); % Calculate model answer
            out.residual{i} = out.Y{i}(regressionRange) - out.Ymodel{i};
            
        end

    end
          
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
