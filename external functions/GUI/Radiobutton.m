function RadioButton(name,varargin)
  % Getting Button callback function from the name displayed on the actual Button
  %
  % 
 
      try
          menuObject = findobj(gcf,'String',name);
          eventdata = {};
          callbackFunctionHandle = get(menuObject,'Callback');
          hObject = menuObject;
          gcbo = menuObject;  % Set in case needed for callback
          
          % Toggle value
          if (get(gcbo,'Value')==0 )
              set(gcbo, 'Value',1);
          else
              set(gcbo, 'Value',0);
          end
          
          % Massage callback function (remove initial "@(a b )" if exists)
          callbackString = char(callbackFunctionHandle)  % Go from function handle to string: @(hObject,eventdata)imlook4d('Hot_Callback',hObject,eventdata,guidata(hObject))
          
          if strcmp( callbackString(1),'@' )
              i=findstr(callbackString,')');  % index of first ')'
              if ~(i(1)==length(callbackString) )
                  callbackString = callbackString(i+1:end);  % imlook4d(''Hot_Callback'',hObject,eventdata,guidata(hObject))
              end
          end
          
          % Callback
          eval(callbackString);
          
      catch
            disp('error in Radiobutton.m')
      end
