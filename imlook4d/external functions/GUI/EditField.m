function EditField(name,varargin)
% Getting EditField callback function from the name displayed on the actual Button
%
%

try
    h = gcf;
    menuObject = findobj(h,'Tag',name);
    eventdata = {};
    callbackFunctionHandle = get(menuObject,'ValueChangedFcn');
    hObject = menuObject;
    set(hObject,'Value',varargin{1});
    gcbo = menuObject;  % Set in case needed for callback

    % % Massage callback function (remove initial "@(a b )" if exists)
    % callbackString = char(callbackFunctionHandle);  % Go from function handle to string: @(hObject,eventdata)imlook4d('Hot_Callback',hObject,eventdata,guidata(hObject))
    %
    % if strcmp( callbackString(1),'@' )
    %     i=findstr(callbackString,')');  % index of first ')'
    %     if ~(i(1)==length(callbackString) )
    %         callbackString = callbackString(i(1)+1:end);  % imlook4d(''Hot_Callback'',hObject,eventdata,guidata(hObject))
    %     end
    % end

    % hObject is your edit field handle
    oldVal = hObject.Value;       % Spara gamla värdet
    hObject.Value = varargin{1};         % Sätt nya värdet


    % Fire its ValueChangedFcn:

    evt = struct( ...
        'Source',       hObject, ...
        'EventName',    'ValueChanged', ...
        'Value',        hObject.Value, ...
        'PreviousValue', oldVal);

    fcn = hObject.ValueChangedFcn;
    if ~isempty(fcn)
        feval(fcn, hObject, evt);
    end

catch
    disp('error in Button.m')
end
