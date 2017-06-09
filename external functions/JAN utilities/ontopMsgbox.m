function handle=ontopMsgbox(parentWindowHandle, message, title)
% ONTOPMSGBOX opens on top, then pops up when leaving parentWindow
% Message box that pops up on top, when changing window
%
% Returns handle to selected window

        h = msgbox(message,title)
        while ishandle(h)
            pause(3)
            if gcf~=parentWindowHandle
                try set(h, 'Visible', 'on');  % Move window to top
                catch end
            end
        end
        handle=gca;
        
end

