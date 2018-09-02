function out =  jjzhou( matrix, t, dt, Cr, range)

    % Reference Logan, Zhou method
    %
    % Inputs:
    %   matrix = data with last dimension being frames (could be image matrix, or ROI values)
    %   t = frame start times in seconds
    %   dt = frame duration in seconds
    %   Cr = reference time-activity curve [ 1 N ] 
    %   range = [ startFrame endFrame].  If endFrame is missing, then  endFrame = last frame number
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
    %     out.X = Zhou X-axis 
    %     out.Y = Zhou Y-axis 
    %     out.Xref = Cr x-axis (same times, most often)
    %     out.Yref = Cr
    %     out.Xmodel = Zhou X-axis for fitted range
    %     out.Ymodel = Zhou Y-axis for fitted range
    %     out.residual = Y - Ymodel, diff for fitted range
    
    warning('off','MATLAB:lscov:RankDefDesignMat')
    warning('off','MATLAB:nearlySingularMatrix')
        
    out.names = { 'BPND', 'DVR', 'intercept'};
    out.units = { '1','1','min'};
        
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

    % ----------------
    %  Logan model
    % ----------------   
  
    for i = 1:n
        
        newX=cumsum(Cr.*dt)./Cr; % integeral{REF}/ROI(t)
        newY=cumsum(Ct(i,:).*dt)./Cr;    % integeral{ROI}/ROI(t)
        
        % Limit range
        tempX =  newX(regressionRange)';  % X-values in range
        tempY = newY(regressionRange)';  % Y-values in range
        
        % Two alternatives:
        %p = linortfit2(double(newX), double(tempY)); % Orthogonal regression
        p = [tempX ones(length(tempX),1) ] \ tempY;    % Normal regression
      
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
        
    out.xlabel = '\int_{0}^{t} C_{ref} dt / C_{ref}';
    out.ylabel = '\int_{0}^{t} C_t dt / C_{ref}';
  
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