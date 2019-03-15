
function out =  jjratio( matrix, t, dt, Cr, frame)

    % Ratio
    %
    % Inputs:
    %   matrix = data with last dimension being frames (could be image matrix, or ROI values)
    %   t = frame start times in minutes
    %   dt = frame duration in minutes
    %   Cr = reference time-activity curve [ 1 N ] 
    %   range = [ startFrame endFrame].  If endFrame is missing, then  endFrame = last frame number
    %
    % Outputs:
    %   out.pars  = cell array with matrices { ratio}; 
    %   out.names = { 'ratio'};
    %   out.units = { '1'};
    %
    %   If zero inputs arguments, then out.names and out.units are
    %   returned.  This may be used for dialog boxes previous to running
    %   this function
    %  
    %   Cell array with cells for each ROI:
    %     out.X = X-axis 
    %     out.Y = Y-axis  
    %     out.Xref = Cr x-axis (same times, most often)
    %     out.Yref = Cr
  
    
    
    warning('off','MATLAB:lscov:RankDefDesignMat')
    warning('off','MATLAB:nearlySingularMatrix')
    
    out.names =  { 'ratio'};
    out.units = { '1'}; 
    
    % Keep frame start time and duration (in seconds)
    out.extras.frameStartTime = t;
    out.extras.frameDuration = dt;
        
    if nargin == 0
        return
    end

    
    % time
    %t = t + 0.5 * dt;
    %dt      = [tmid(1), tmid(2:length(tmid))-tmid(1:length(tmid)-1)];
    
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
    %  Ratio model
    % ----------------   

    for i = 1:n
        
        newY = Ct(i,:)./Cr(:)';  % ratio 
                
        % For modelWindow compatibility: Store X,Y
        if IS_ROI 
            newY( find(~isfinite(newY)) ) = 0; % Make NaN or Inf = 0;
            
            tmid = t + 0.5 * dt;
            out.X{i} = tmid;
            out.Y{i} = newY;
            
            out.Xmodel{i} = out.X{i};
            out.Ymodel{i} = out.Y{i};
            out.residual{i} = zeros(size(out.Y{i}));
            
        end
        
        ratio(i) = newY(frame);

    end
          
    % --------
    %  Output
     % --------  
    ratio = reshape(ratio, outsize);
    out.pars = {ratio};
 
    out.xlabel = 'time';
    out.ylabel = 'C_t / C_r';
    
    if IS_ROI
        out.Xref = out.X{i};
        out.Yref = ones(size(out.Xref)); % Cr / Cr
    end

    
    % --------
    % Clean up
    % --------
   
    warning('on','MATLAB:lscov:RankDefDesignMat')
    warning('on','MATLAB:nearlySingularMatrix')
    
end