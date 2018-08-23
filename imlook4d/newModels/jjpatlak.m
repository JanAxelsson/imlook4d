function out =  jjpatlak( matrix, t, dt, Cinp, range)

    % Patlak
    %
    % Inputs:
    %   matrix = data with last dimension being frames (could be image matrix, or ROI values)
    %   t = frame start times in seconds
    %   dt = frame duration in seconds
    %   Cinp = input function [ 1 N ] 
    %   range = [ startFrame endFrame].  If endFrame is missing, then  endFrame = last frame number
    %
    % Outputs:
    %   out.pars  = cell array with matrices { Ki, intercept}; 
    %   out.names = { 'Ki', 'intercept'};
    %   out.units = { 'min-1','1'};
    
    
    
    warning('off','MATLAB:lscov:RankDefDesignMat')
    warning('off','MATLAB:nearlySingularMatrix')
    
    
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
  
  
    % Integrate to mid times
    function value_vector = integrate( C, dt)
        value_vector = cumsum( C.*dt);% -0.5 * C .* dt; % exclude activity from second half (after midtime)
    end        

    % ----------------
    %  Patlak model
    % ----------------  
    
    newX = integrate(Cinp,dt) ./ Cinp; % integeral{Cinp}/Cinp 
    % Limit range
    newX =  newX(regressionRange)';  % X-values in range
    
    for i = 1:n       
        newY = Ct(i,:)./Cinp;    % Ct / Cinp
        
        % Limit range
        tempY = newY(regressionRange)';  % Y-values in range
        
        % Two alternatives:
        %p = linortfit2(double(newX), double(tempY)); % Orthogonal regression
        p = [newX ones(length(newX),1) ] \ tempY;    % Normal regression
      
        Ki(i) = p(1);
        intercept(i) = p(2);

    end
          
    % --------
    %  Output
     % --------  
    Ki = reshape(Ki, outsize);
    intercept = reshape(intercept, outsize);
    
    out.pars = {Ki, intercept};
    out.names = { 'Ki', 'intercept'};
    out.units = { 'min-1','1'};

    
    % --------
    % Clean up
    % --------
   
    warning('on','MATLAB:lscov:RankDefDesignMat')
    warning('on','MATLAB:nearlySingularMatrix')
    
end