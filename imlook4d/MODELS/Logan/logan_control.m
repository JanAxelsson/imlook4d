function varargout  =  logan_control(varargin)

% LOGAN_CONTROL M-file for logan_control.fig
%      LOGAN_CONTROL, by itself, creates a new LOGAN_CONTROL or raises the existing
%      singleton*.
%
%      H  =  LOGAN_CONTROL returns the handle to a new LOGAN_CONTROL or the handle to
%      the existing singleton*.
%
%      LOGAN_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOGAN_CONTROL.M with the given input arguments.
%
%      LOGAN_CONTROL('Property','Value',...) creates a new LOGAN_CONTROL
%      or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before logan_control_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to logan_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help logan_control

% Last Modified by GUIDE v2.5 01-Oct-2008 15:48:46

% Begin initialization code - DO NOT EDIT
gui_Singleton  =  1;
gui_State  =  struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @logan_control_OpeningFcn, ...
                   'gui_OutputFcn',  @logan_control_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback  =  str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}]  =  gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
% --- Executes just before logan_control is made visible.
function logan_control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to logan_control (see VARARGIN)

% Choose default command line output for logan_control
handles.output  =  hObject;


%
% MODIFIED - HERE GOES SETUP OF GUI, ETC
%
   disp('Entered logan_control_OpeningFcn');
   
    %
    % INITIALIZATION of important communication between imlook4d and 
    %
        % Obtain link back to calling imlook4d instance
        handles.imlook4d_handle = varargin{1};                    % Handle to imlook4d instance
        imlook4d_handles = guidata(handles.imlook4d_handle);      % Handles to calling imlook4d instance (COPY OF HANDLES)
    %
    % USER INITIALIZATION  ( CHANGE THIS ONE )         
    %            
            
            numberOfFrames = size(imlook4d_handles.image.Cdata,4);
            set(handles.startFrameSlider,'Max', numberOfFrames);
            set(handles.endFrameSlider,'Max', numberOfFrames);
    
    
            endFrame = round(get(handles.endFrameSlider,'Value'));

            % 
            % If model parameters are set at previous call, recreate
            %
            try
                % Set radio buttons
                if (strcmp(imlook4d_handles.model.Logan.type, 'slope') )
                    set(handles.slopeRadiobutton,'Value',1);
                    set(handles.interceptRadiobutton,'Value',0);
                else
                    set(handles.slopeRadiobutton,'Value',0);
                    set(handles.interceptRadiobutton,'Value',1);
                end

                % Set list-box
                set(handles.referenceDataEdit,'String', imlook4d_handles.model.Logan.referenceData);

                % Set GUI according to imlook4d model handles
                imlook4d_handles.model.Logan.referenceData   % Save TACT curve 
                set(handles.startFrameSlider,'Value', imlook4d_handles.model.Logan.startFrame);
                set(handles.startFrameEdit  ,'String',imlook4d_handles.model.Logan.startFrame);
                set(handles.endFrameSlider  ,'Value', imlook4d_handles.model.Logan.endFrame);
                set(handles.endFrameEdit    ,'String',imlook4d_handles.model.Logan.endFrame);
                
                
                set(handles.referenceDataEdit    ,'String',num2cell(imlook4d_handles.model.Logan.referenceData));
           catch
                disp('First time opening Logan from this instance of imlook4d');
                set(handles.endFrameSlider  ,'Value', numberOfFrames);
                set(handles.endFrameEdit    ,'String',num2str(numberOfFrames));
           end
    %
    % FINISH
    %
        % Save data to imlook4d
        %guidata(handles.imlook4d_handle,imlook4d_handles); % Export modified handles back to imlook4d
        guidata(hObject,handles); % Export modified handles back to imlook4d
%
% END MODIFIED
%

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes logan_control wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout  =  logan_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1}  =  handles.output;


% -------------------------------------------------------------------------
% 
% GUI CREATION, this is where a GUI is defined
%
% -------------------------------------------------------------------------
    function endFrameEdit_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to endFrameEdit (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called

        % Hint: edit controls usually have a white background on Windows.
        %       See ISPC and COMPUTER.
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end
    function startFrameSlider_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to startFrameSlider (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called

        % Hint: slider controls usually have a light gray background.
        if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor',[.9 .9 .9]);
        end
    function startFrameEdit_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to startFrameEdit (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called

        % Hint: edit controls usually have a white background on Windows.
        %       See ISPC and COMPUTER.
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end
    function referenceDataEdit_CreateFcn(hObject, eventdata, handles)
        % hObject    handle to referenceDataEdit (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    empty - handles not created until after all CreateFcns called
        % Hint: edit controls usually have a white background on Windows.
        %       See ISPC and COMPUTER.
        %set(handles.referenceDataEdit,'Max',8);  % Make multi-line
        if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor','white');
        end
    function endFrameSlider_CreateFcn(hObject, eventdata, handles)
        % Hint: slider controls usually have a light gray background.
        if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
            set(hObject,'BackgroundColor',[.9 .9 .9]);
        end
  
% -------------------------------------------------------------------------
% 
% GUI CALLBACKS , this is where a GUI event goes into the code
%
% -------------------------------------------------------------------------
function startFrameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to startFrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
NewVal =  round(get(hObject,'Value'));
set(handles.startFrameEdit,'String',num2str(NewVal));
function startFrameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to startFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startFrameEdit as text
%        str2double(get(hObject,'String')) returns contents of startFrameEdit as a double
strg  =  get(hObject,'String');
set(handles.startFrameSlider,'Value', str2num(strg));
function copyFromROIPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to copyFromROIPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
            

        % 
        % INITIALIZE
        %
            
            endFrame = round(get(handles.endFrameSlider,'Value'));

            % Setup handles to imlook4d
            imlook4d_handles = guidata(handles.imlook4d_handle);
            
            % Get ROI info
            numberOfROIs = size(imlook4d_handles.image.ROI,3);
            
            % Get image matrix info
            numberOfFrames = size(imlook4d_handles.image.Cdata,4);
            numberOfSlices = size(imlook4d_handles.image.Cdata,3);
            
        %
        % CALCULATE TACT
        %

            % Read ROI number from GUI
            activeROI = get(imlook4d_handles.ROINumberMenu,'Value');
            disp( ['ROI number = ' num2str(activeROI)] );

            % Calculate new values
            imlook4d_handles.model.functionHandle = [];  % Stops model to be used in TACT calculations
            guidata(handles.imlook4d_handle,  imlook4d_handles); 
            %[activity, NPixels] = generateTACT(imlook4d_handles, imlook4d_handles.image.Cdata, imlook4d_handles.image.ROI);
            [activity, NPixels] = generateTACT(imlook4d_handles, imlook4d_handles.image.ROI);
  
        %
        % UPDATE LIST-BOX 
        %
            texts = num2cell(activity(activeROI,:));
            set(handles.referenceDataEdit,'String', texts);
            referenceDataEdit_Callback(hObject, eventdata, handles);  % Update referenceDataEdit
function referenceDataEdit_Callback(hObject, eventdata, handles)
% hObject    handle to referenceDataEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of referenceDataEdit as text
%        str2double(get(hObject,'String')) returns contents of referenceDataEdit as a double
lines = size(  get(handles.referenceDataEdit,'String') ,1);
set(handles.headerText, 'String', ['Blood/Reference data (' num2str(lines) ' lines)']);
function activeCheckbox_Callback(hObject, eventdata, handles)
function endFrameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to endFrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
NewVal =  round(get(hObject,'Value'));
set(handles.endFrameEdit,'String',num2str(NewVal));
function endFrameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to endFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endFrameEdit as text
%        str2double(get(hObject,'String')) returns contents of endFrameEdit as a double
strg  =  get(hObject,'String');
set(handles.endFrameSlider,'Value', str2num(strg));


% --- Executes on button press in donePushbutton.
function donePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to donePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        % Setup handles to imlook4d
            imlook4d_handles = guidata(handles.imlook4d_handle);

        % Define imlook4d callback function
            imlook4d_handles.model.functionHandle = @logan;              % CHANGE THIS ONE
            
        % Save into imlook4d handles
            %imlook4d_handles.model.Logan.referenceData = activity(activeROI,:);   % Save TACT curve 
            imlook4d_handles.model.Logan.startFrame = round(get(handles.startFrameSlider,'Value'));
            endFrame = round(get(handles.endFrameSlider,'Value'));
            imlook4d_handles.model.Logan.endFrame = endFrame;
            %imlook4d_handles.model.Logan.integrationRange = startFrame:endFrame;
            
        % Determine if slope/intercept image
            if (get(handles.slopeRadiobutton,'Value') == 1)
                imlook4d_handles.model.Logan.type = 'slope';
            end

            if (get(handles.interceptRadiobutton,'Value') == 1)
                imlook4d_handles.model.Logan.type = 'intercept';
            end  
          
        % Get reference data from text field, line-by-line
             referenceDataString = get(handles.referenceDataEdit,'String');
             %for i = 1:endFrame
             for i = 1:size(imlook4d_handles.image.Cdata,4)
                 %disp('size ref data');
                 %disp(size(imlook4d_handles.image.Cdata,4))
                 try
                    referenceData(i,1) = str2num(referenceDataString{i});
                 catch
                    referenceData(i) = str2num(referenceDataString(i,:));
                 end
             end
            imlook4d_handles.model.Logan.referenceData = referenceData;

        % Export modified handles back to imlook4d
            guidata(handles.imlook4d_handle,  imlook4d_handles);        % Copy handles back to imlook4d

        % Close window when pressing DONE
            delete(handles.figure1);
            
        % Update imlook4d image
        %imlook4d('updateImage',handles.imlook4d_handle, [], imlook4d_handles);



