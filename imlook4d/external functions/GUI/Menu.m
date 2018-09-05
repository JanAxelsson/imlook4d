function Menu(name,varargin)
  % Getting menu callback function from the name displayed on the actual
  % menu
  try
      % Two options, a) Tag, b) Label
      menuObject = findobj(gcf,'Tag',name);
      if isempty( menuObject)
          menuObject = findobj(gcf,'Label',name);
      end
      eventdata = {};
      callbackFunctionHandle = get(menuObject,'Callback');
      hObject = menuObject;
      gcbo = menuObject;  % Set in case needed for callback
      
      % Massage callback function (remove initial "(a b )" if exists)
      callbackString = char(callbackFunctionHandle);  % Go from function handle to string: @(hObject,eventdata)imlook4d('Hot_Callback',hObject,eventdata,guidata(hObject))
      if startsWith(callbackString,'(') % Otherwise not "(a b) ..."
          i = findstr(callbackString,')');  % index of first ')'
          if ~(i(1)==length(callbackString) ) % 
              callbackString = callbackString(i(1)+1:end);  % imlook4d(''Hot_Callback'',hObject,eventdata,guidata(hObject))
          end
      end
      
      i = findstr(callbackString,'imlook4d');
      callbackString = callbackString(i:end);
      
      % Callback
      eval(callbackString);
      
  catch
      disp('error in Menu.m')
  end

      % imlook4d('Color_Callback',gcbo,[],guidata(gcbo),'Sokolof')
      % @(hObject,eventdata)imlook4d('Gray_Callback',hObject,eventdata,guidata(hObject))