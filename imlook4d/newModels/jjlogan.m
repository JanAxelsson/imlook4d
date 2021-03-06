
function out =  jjlogan( matrix, t, dt, Cr, range, k2ref)

    % Reference Logan
    % (https://doi.org/10.1016/S0969-8051(00)00137-2)
    %
    % Inputs:
    %   matrix = data with last dimension being frames (could be image matrix, or ROI values)
    %   t = frame start times in minutes
    %   dt = frame duration in minutes
    %   Cr = reference time-activity curve [ 1 N ] 
    %   range = [ startFrame endFrame].  If endFrame is missing, then  endFrame = last frame number
    %   k2ref = optional, k2 for reference region (For raclopride this is often omitted)
    %
    % Outputs:
    %   out.pars  = cell array with matrices { BPND, DVR, intercept}; 
    %   out.names = { 'BPND', 'DVR', 'intercept'};
    %   out.units = { '1','1','min'};
    %
    %   If zero inputs arguments, then out.names and out.units are
    %   returned.  This may be used for dialog boxes previous to running
    %   this function
    %  
    %   Cell array with cells for each ROI:
    %     out.X = Logan X-axis 
    %     out.Y = Logan Y-axis 
    %     out.Xref = Cr x-axis (same times, most often)
    %     out.Yref = Cr
    %     out.Xmodel = Logan X-axis for fitted range
    %     out.Ymodel = Logan Y-axis for fitted range
    %     out.residual = Y - Ymodel, diff for fitted range
    
    
    
    warning('off','MATLAB:lscov:RankDefDesignMat')
    warning('off','MATLAB:nearlySingularMatrix')
    
    out.names = { 'BPND', 'DVR', 'intercept'};
    out.units = { '1','1','min'}; 
     
    out.ylabel = '\int_{0}^{t} C_t dt / C_t';
    
    if nargin == 0
        return
    end
    
    
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
   

    % ----------------
    %  Logan model
    % ----------------   
    Ct = Ct +0;  % Set tolerance to avoid Ct = zero . 

    % TODO : Think about copying imlook4d_logan, instead of tolerance -- is that necessary?
  
    for i = 1:n
        % Handle two different models (with or without known k2 for reference area)
        if HAS_K2_REF
            newX = ( cumsum(Cr.*dt) + Cr/k2ref ) ./ Ct(i,:); % integeral{REF}/ROI(t) + REF/k2ref
            out.xlabel = '( \int_{0}^{t} C_{ref} dt  + C_{ref} / k_2^{ref} ) / C_t';
        else
            newX = cumsum(Cr.*dt)./Ct(i,:); % integeral{REF}/ROI(t)
            out.xlabel = '\int_{0}^{t} C_{ref} dt / C_t';
        end
        
        newY = cumsum(Ct(i,:).*dt)./Ct(i,:);    % integeral{ROI}/ROI(t)

        % Limit range
        tempX =  newX(regressionRange)';  % X-values in range
        tempY = newY(regressionRange)';  % Y-values in range
        
        % Two alternatives:
        if sum( ~isfinite(tempY) ) == 0

            p = linortfit2(double(tempX), double(tempY)); % Orthogonal regression (Best alternative)
            % p = [tempX ones(length(tempX),1) ] \ tempY;    % Normal regression (works badly, Rank deficient)
            %p = lscov(double([tempX ones(length(tempX),1) ]), double(tempY)); % Normal regression (more stable)
        else
            p(1) = 0;
            p(2) = 0;
        end
      
        DVR(i) = p(1);
        BP(i) = DVR(i) - 1;
        intercept(i) = p(2);
                
        % For modelWindow compatibility: Store X,Y
        if IS_ROI 
            out.X{i} = newX;
            out.Y{i} = newY;
            
            out.Xmodel{i} = out.X{i}(regressionRange);
            out.Ymodel{i} = DVR(i) * out.Xmodel{i} + intercept(i); % Calculate model answer
            out.residual{i} = out.Y{i}(regressionRange) - out.Ymodel{i};
        end

    end
          
    % --------
    %  Output
     % --------  
    DVR = reshape(DVR, outsize);
    BP = reshape(BP, outsize);
    intercept = reshape(intercept, outsize);
    
    out.pars = {BP, DVR, intercept};

    
    if IS_ROI
        out.Xref = out.X{i};
        out.Yref = Cr;
    end
    
    % --------
    % Clean up
    % --------
   
    warning('on','MATLAB:lscov:RankDefDesignMat')
    warning('on','MATLAB:nearlySingularMatrix')
    
end