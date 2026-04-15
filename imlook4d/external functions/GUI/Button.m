function Button(name,varargin)
  % Getting Button callback function from the name displayed on the actual Button
  %
  % 
 
      try
          %menuObject = findobj(gcf,'String',name);
          menuObject = findobj(gcf,'Text',name,'Type','uibutton')
          eventdata = {};
          callbackFunctionHandle = get(menuObject,'ButtonPushedFcn');
          hObject = menuObject;
          gcbo = menuObject;  % Set in case needed for callback
          
          % Massage callback function (remove initial "@(a b )" if exists)
          % callbackString = char(callbackFunctionHandle);  % Go from function handle to string: @(hObject,eventdata)imlook4d('Hot_Callback',hObject,eventdata,guidata(hObject))
          % 
          % if strcmp( callbackString(1),'@' )
          %     i=findstr(callbackString,')');  % index of first ')'
          %     if ~(i(1)==length(callbackString) )
          %         callbackString = callbackString(i+1:end);  % imlook4d(''Hot_Callback'',hObject,eventdata,guidata(hObject))
          %     end
          % end
          % 
          % 

              % Fire its ValueChangedFcn:

              evt = struct( ...
                  'Source',       hObject, ...
                  'EventName',    'ValueChanged');

              fcn = hObject.ButtonPushedFcn;
              if ~isempty(fcn)
                  feval(fcn, hObject, evt);
              end
          
      catch
            disp('error in Button.m')
      end
