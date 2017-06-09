function [TACT_out] = resample1D( TACT, method, varargin)
% Resample a 1D sequence.  
% The sequence is stored in a tact-struct, defined below.
% The method describes how the resampling is done, which may be a
% resampling in time, in amplitude, or both (depending on method).
%
% IN :
%   TACT.mean
%   TACT.midtime
%   TACT.duration
%   TACT.names
%   ....
%
%   method = 'evenly_distributed'  
%      descrip:   resamples to same time steps, for instance 30 s
%      varargin = DeltaT after resampling
%      example:   a = resample1D( imlook4d_ROI_data, 'evenly_distributed', 30)
%
%
%   method = 'to_new_time'
%      descrip:   resamples to same time as RefTACT
%      varargin = RefTACT % a tact-struct containing time points to which we resample
%      example:   a = resample1D( imlook4d_ROI_data, 'to_new_time', Cblood)  % Cblood is a tact-struct
%
%
%   method = 's_to_min', 
%      descrip:   converts times in tact-struct from seconds to
%      example:   TACT = resample1D( TACT, 's_to_min')
%
%
%   method = 'logan', 
%      descrip:   converts times and activity to logan versions
%      varargin{1} = Cref  % a tact-struct containing time points to which we resample
%      varargin{2} = k2    % a tact-struct containing time points to which we resample
%      example:   TACT = resample1D( TACT, 'logan', Cref, k2 ) % 
%
%
%   method = 'sub_range', 
%      descrip:   extracts a subrange of data
%      varargin{1} = startFrame             % frame number for the first frame in subrange
%      varargin{2} = lastFrame or 'end'     % frame number for the last frame in subrange.  'end' can be used to indicate that last frame  
%      example:  TACT_subrange = resample1D( TACT_logan, 'sub_range',32,'end');
% 
%
% OUT:
%   TACT_out.mean
%   TACT_out.midtime
%   TACT_out.duration
%   TACT_out.names
%
% Jan Axelsson 2015-NOV-23

t  = TACT.midtime;
dt = TACT.duration;

TACT_out.names = TACT.names;

switch method
    case 'evenly_distributed'
        % new x-data
        N = varargin{1} % Number of seconds per sample
        start =t(1);
        stop = t(end);
        TACT_out.midtime = (start:N:stop)' ;
        TACT_out.duration = N * ones( size(TACT_out.midtime ))  ;
        
        % new y-data
        TACT_out.mean = interp1(t, TACT.mean, TACT_out.midtime,'linear'); % Resample to x-values=TACT_out.midtime
        
     case 'to_new_time'
        % new x-data
        RefTACT = varargin{1} % Reference TACT to which we want to resample
        TACT_out.midtime = RefTACT.midtime ;
        TACT_out.duration = RefTACT.duration ;
        % new y-data
        TACT_out.mean = interp1(TACT.midtime, TACT.mean, RefTACT.midtime,'linear'); % Resample to x-values=TACT_out.midtime
               
    case 's_to_min'
        TACT_out.midtime = TACT.midtime / 60 ;
        TACT_out.duration = TACT.duration /60;
        TACT_out.mean = TACT.mean;
               
    case 'sub_range'
        start = varargin{1};
        stop = varargin{2};
        if strcmp( 'end', stop)
            stop = size(TACT.midtime,1);
        end
        TACT_out.midtime = TACT.midtime(start:stop,:) ;
        TACT_out.duration = TACT.duration(start:stop,:);
        TACT_out.mean = TACT.mean(start:stop,:);
        
    case 'logan'
        TACT_out.midtime = TACT.midtime ;
        TACT_out.duration = TACT.duration;
        TACT_out.mean = TACT.mean;
        
        % Use default ROI data
        t = TACT.midtime;   % In seconds
        dt = TACT.duration; % In seconds
        
        % ( use unit minutes for the whole calculation)
      %  t = t / 60;   % In minutes
      %  dt = dt / 60; % In minutes
        k2 = str2num( varargin{2} );  % same time unit as in midtime and duration
        
        referenceData =  varargin{1}; 
        tact = TACT.mean;
        cols = size(tact,2);
        
        counts = referenceData.*dt;       % integral over duration of one frame
        
        % Repeat columns
        countsN = repmat( counts, [1 cols]);
        dtN = repmat( dt, [1 cols]);
        referenceDataN = repmat( referenceData , [1 cols]);
        
        % New coordinates
        
        newX = cumsum(countsN)./tact;     % integeral{REF}/ROI(t)
        newX = cumsum(countsN)./tact + (referenceDataN/k2)./tact;     % integeral{REF}/ROI(t) + (REF/k2)/ROI(t)
        countsY = tact.*dtN;      % integral over duration of one frame
        newY = cumsum(countsY)./tact;    % integeral{ROI}/ROI(t)
        
        TACT_out.midtime = newX;
        TACT_out.mean = newY;
        
end

