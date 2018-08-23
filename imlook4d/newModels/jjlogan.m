function out =  jjlogan( matrix, t, dt, Cr, range, k2ref)

    % Reference Logan
    %
    % Inputs:
    %   matrix = data with last dimension being frames (could be image matrix, or ROI values)
    %   t = frame start times in seconds
    %   dt = frame duration in seconds
    %   Cr = reference time-activity curve [ 1 N ] 
    %   range = [ startFrame endFrame].  If endFrame is missing, then  endFrame = last frame number
    %   k2ref = optional, k2 for reference region (For raclopride this is often omitted)
    %
    % Outputs:
    %   out.pars  = cell array with matrices { BPND, DVR, intercept}; 
    %   out.names = { 'BPND', 'DVR', 'intercept'};
    %   out.units = { '1','1','min'};
    
    
    
    warning('off','MATLAB:lscov:RankDefDesignMat')
    warning('off','MATLAB:nearlySingularMatrix')
    
    HAS_K2_REF = (nargin == 6);
    
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
    %  Logan model
    % ----------------   
  
    for i = 1:n
        if HAS_K2_REF
            newX = ( integrate(Cr,dt) + Cr/k2ref ) ./ Ct(i,:); % integeral{REF}/ROI(t) + REF/k2ref
        else
            newX = integrate(Cr,dt)./Ct(i,:); % integeral{REF}/ROI(t)
        end
        
        newY=integrate(Ct(i,:),dt)./Ct(i,:);    % integeral{ROI}/ROI(t)
        
        % Limit range
        newX =  newX(regressionRange)';  % X-values in range
        tempY = newY(regressionRange)';  % Y-values in range
        
        % Two alternatives:
        %p = linortfit2(double(newX), double(tempY)); % Orthogonal regression
        p = [newX ones(length(newX),1) ] \ tempY;    % Normal regression
      
        DVR(i) = p(1);
        BP(i) = DVR(i) - 1;
        intercept(i) = p(2);

    end
          
    % --------
    %  Output
     % --------  
    DVR = reshape(DVR, outsize);
    BP = reshape(BP, outsize);
    intercept = reshape(intercept, outsize);
    
    out.pars = {BP, DVR, intercept};
    out.names = { 'BPND', 'DVR', 'intercept'};
    out.units = { '1','1','min'};

    
    % --------
    % Clean up
    % --------
   
    warning('on','MATLAB:lscov:RankDefDesignMat')
    warning('on','MATLAB:nearlySingularMatrix')
    
end