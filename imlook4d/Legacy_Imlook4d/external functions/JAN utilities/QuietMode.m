%
% QuietMode - gives true if global
% variable SETTINGS.QUIET==true
%
% Jan Axelsson, 070420
function quiet=QuietMode()
    global SETTINGS;
    
    quiet=false;        % Guess
    if exist('SETTINGS') 
         try     
            if SETTINGS.QUIET==true
                quiet=true;
            end;
        catch;  
            disp('SETTINGS.QUIET may not exist');
        end
    end
 