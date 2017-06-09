        function displayMessageRowError( s)
                % Display information row at bottom of GUI
                
                % gcf if running script without gui, or running from within imlook4d
                  
                % Get handles to imlook4d
                try
                    
                    if strcmp( 'imlook4d', get(gcf,'Tag'))
                        % If current figure is of type imlook4d, then we can
                        % just get the handles
                        handles=guidata(gcf);
                    else
                        % This means that another figure is more recent, such
                        % as a script with a GUI.
                        % Assume a script => imlook4d_current_handles is set
                        imlook4d_current_handle=evalin('base', 'imlook4d_current_handle');
                        handles=guidata(imlook4d_current_handle);
                    end
                    
                    set(handles.infoText1,'ForegroundColor',[1 0 0]);   % Red

                    
                    if ~isequal(get(handles.infoText1, 'String'), s')
                        set(handles.infoText1, 'String', s);
                        %drawnow
                    end
                 catch
                    disp('displayMessageRow exception');
                end