function varargout = water_control(varargin)
% water M-file for water.fig
%      water, by itself, creates a new water or raises the existing
%      singleton*.
%
%      H = water returns the handle to a new water or the handle to
%      the existing singleton*.
%
%      water('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in water.M with the given input arguments.
%
%      water('Property','Value',...) creates a new water or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before water_control_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to water_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help water

% Last Modified by GUIDE v2.5 01-Nov-2016 10:24:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @water_control_OpeningFcn, ...
                   'gui_OutputFcn',  @water_control_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before water is made visible.
function water_control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to water (see VARARGIN)


% Choose default command line output for water
handles.output = hObject;


%
% MODIFIED - HERE GOES SETUP OF GUI, ETC
%
   disp('Entered water_control_OpeningFcn');

    %
    % INITIALIZATION of important communication between imlook4d and 
    %
        % handles to this figure
        handles.imlook4d_handle=varargin{1};                    % Handle to imlook4d instance
        imlook4d_handles=guidata(handles.imlook4d_handle);      % Handles to calling imlook4d instance (COPY OF HANDLES)

            % 
            % If model parameters are set at previous call, recreate
            %
            try

                % Set list-box
                set(handles.referenceDataEdit,'String', imlook4d_handles.model.water.TACT); 
                set(handles.referenceDataEdit    ,'String',num2cell(imlook4d_handles.model.water.TACT));
           catch
                disp('First time opening water from this instance of imlook4d');

           end        
        
        
        
        
    % RECORDING:  Display HELP (or Recording) and get out of callback   
 
         imlook4d_current_handle=varargin{1};
         imlook4d_current_handles=guidata(handles.imlook4d_handle); 
         handles.record = imlook4d_current_handles.record;                      % Recording should be done
         handles.helpToggleTool = imlook4d_current_handles.helpToggleTool;       % Help toggle button (in imlook4d instance)
         if imlook4d('DisplayHelp', hObject, [], handles )
             close(hObject);  % Stop displaying the control window
             return 
         end   

    
    %
    % FINISH
    %
        guidata(handles.imlook4d_handle, imlook4d_handles); % Export modified handles back to imlook4d
        
%
% END MODIFIED
%


% Update handles structure
guidata(hObject, handles);

        
% RECORDING:  If INPUTS from workspace
    try
       INPUTS=getINPUTS();
       answer=INPUTS;          
       set(handles.ROIPopupmenu, 'Value', str2num(INPUTS{1}) );
       evalin('base','clear INPUTS'); % Clear INPUTS from workspace
       DonePushbutton_Callback(hObject, {}, handles);
    catch   
    end

% UIWAIT makes water wait for user response (see UIRESUME)
% uiwait(handles.water);


% --- Outputs from this function are returned to the command line.
function varargout = water_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on selection change in ROIPopupmenu.
function ROIPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to ROIPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns ROIPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ROIPopupmenu




% --- Executes during object creation, after setting all properties.
function ROIPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DonePushbutton.
function DonePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DonePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        
    %
    % Initiate
    %
        disp('Entered water_control/DonePushbutton_Callback');

        % Read local copy of imlook4d handles (directly from imlook4d)
        imlook4d_handles=guidata(handles.imlook4d_handle);  % New copy of imlook4d handles

        % Clear function handle (stops image genewatern from this function handle)
        imlook4d_handles.model.functionHandle=[];
    
    %
    % Apply settings
    %

          
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
            imlook4d_handles.model.water.TACT = referenceData;

        
    %
    % Finish
    %

        % Define imlook4d callback function
        imlook4d_handles.model.functionHandle=@water;            % CHANGE THIS ONE 
        
        % Export modified handles back to imlook4d
        guidata(handles.imlook4d_handle,  imlook4d_handles); % Copy handles back to imlook4d

        % Close window when pressing DONE
        delete(handles.water);
        
        % Update imlook4d image
        imlook4d('updateImage',handles.imlook4d_handle, [], imlook4d_handles);
        
        % RECORDING:  
        if handles.record.enabled
            answer = { num2str(index) };
            recordInputsText(answer);  % Insert text at caret
        end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to referenceDataEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of referenceDataEdit as text
%        str2double(get(hObject,'String')) returns contents of referenceDataEdit as a double


% --- Executes during object creation, after setting all properties.
function referenceDataEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to referenceDataEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function referenceDataEdit_Callback(hObject, eventdata, handles)
% hObject    handle to referenceDataEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of referenceDataEdit as text
%        str2double(get(hObject,'String')) returns contents of referenceDataEdit as a double
lines = size(  get(handles.referenceDataEdit,'String') ,1);
set(handles.headerText, 'String', ['Blood/Reference data (' num2str(lines) ' lines)']);

function copyFromROIPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to copyFromROIPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
            

        % 
        % INITIALIZE
        %
            
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
