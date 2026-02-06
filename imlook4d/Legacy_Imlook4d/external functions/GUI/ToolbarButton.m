function ToolbarButton(name,varargin)
  % Getting Button callback function from the name displayed on the actual Button
  %
  % 
 
      try
          menuObject = findobj(gcf,'Tag',name);
          eventdata = {};
          callbackFunctionHandle = get(menuObject,'ClickedCallback');
          hObject = menuObject;
          gcbo = menuObject;  % Set in case needed for callback
          
          % Massage callback function (remove initial "@(a b )" if exists)
          callbackString = char(callbackFunctionHandle);  % Go from function handle to string: @(hObject,eventdata)imlook4d('Hot_Callback',hObject,eventdata,guidata(hObject))
          
          if strcmp( callbackString(1),'@' )
              i=findstr(callbackString,')');  % index of first ')'
              if ~(i(1)==length(callbackString) )
                  callbackString = callbackString(i+1:end);  % imlook4d(''Hot_Callback'',hObject,eventdata,guidata(hObject))
              end
          end
          
          % Callback
          eval(callbackString);
          
      catch
            disp('error in Button.m')
      end
