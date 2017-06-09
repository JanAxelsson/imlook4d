%
% disp2 - same as MATLAB built in function, but does not display if global
% variable SETTINGS.QUIET==false
%
% Jan Axelsson, 070420
function disp2(varargin)
    global SETTINGS;

%     try     % If SETTINGS.QUIET==false, then display
%         if SETTINGS.QUIET==false
%             disp(varargin{:});
%         end;
%     catch;  % If SETTINGS.QUIET does not exist, then display
%         disp(varargin{:});
%     end;
    
    
    if ~QuietMode()    
        disp(varargin{:});
    end