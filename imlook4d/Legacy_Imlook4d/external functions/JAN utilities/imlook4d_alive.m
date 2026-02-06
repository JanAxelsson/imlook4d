function t = imlook4d_alive( string)
% checks if string at one of the highest levels of function stack
% and prints a '.'

COLUMN_WIDTH = 60;  % column width (60 = one row per minute)
imlook4d_running_counter = 1;

% Close old open timers that failed to close
delete(timerfindall)

% Setup new timer
t = timer('StartDelay', 4, 'Period', 1, 'ExecutionMode', 'fixedRate');

t.StartFcn = { @my_callback_fcn , 'Running : ' };
t.TimerFcn = { @my_timer_fcn, string  };
t.StopFcn = { @my_callback_fcn, 'Stopped timer' };
t.ErrorFcn = { @my_callback_fcn, 'imlook4d_alive  timer error' };

start(t)



%% Stop

% stop(timerfind)
% delete(timerfindall)

%
% Local functions
%

    %% Timer start callback
    function my_callback_fcn(obj, event, string)
        
        txt1 = ' event occurred at ';
        txt2 = string;
        
        event_type = event.Type;
        event_time = datestr(event.Data.time);
        
        msg = [event_type txt1 event_time];
        disp(msg)
        disp(txt2)
    end

    % Timer triggered callback
    function my_timer_fcn(obj, event, string)
        [ST, I] = dbstack('-completenames', 1);
        n = size(ST,1);
        if contains(ST(n-1).file,string)||contains(ST(n).file,string)
            fprintf('%s', '.');
        end
        
        imlook4d_running_counter = imlook4d_running_counter + 1;
        if ~mod(imlook4d_running_counter,COLUMN_WIDTH)
            disp(' '); % New line
        end
        
    end

end


