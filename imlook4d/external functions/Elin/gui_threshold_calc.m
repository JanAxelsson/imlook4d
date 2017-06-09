function varargout = gui_threshold_calc(varargin)
% GUI_THRESHOLD_CALC MATLAB code for gui_threshold_calc.fig
%      GUI_THRESHOLD_CALC, by itself, creates a new GUI_THRESHOLD_CALC or raises the existing
%      singleton*.
%
%      H = GUI_THRESHOLD_CALC returns the handle to a new GUI_THRESHOLD_CALC or the handle to
%      the existing singleton*.
%
%      GUI_THRESHOLD_CALC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_THRESHOLD_CALC.M with the given input arguments.
%
%      GUI_THRESHOLD_CALC('Property','Value',...) creates a new GUI_THRESHOLD_CALC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_threshold_calc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_threshold_calc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_threshold_calc

% Last Modified by GUIDE v2.5 23-Apr-2012 13:46:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_threshold_calc_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_threshold_calc_OutputFcn, ...
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

% --- Executes just before gui_threshold_calc is made visible.
function gui_threshold_calc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_threshold_calc (see VARARGIN)

reconstruction_methods
set(handles.popupmenu1, 'String', rec_meth)

% Choose default command line output for gui_threshold_calc
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_threshold_calc wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_threshold_calc_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_end.
function pushbutton_end_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(handles.popupmenu1,'String')); 
reconstruction_method=contents{get(handles.popupmenu1,'Value')};
reconstruction_methods;
for i=1:size(rec_meth, 2)
    if strcmp(reconstruction_method,rec_meth{i})==1
        epsilon=epsilon_vector(i);
    end
end

assignin('base', 'epsilon', epsilon);

%bild=evalin('base', 'imlook4d_Cdata');
close('gui_threshold_calc')
return

% --- Executes on button press in pushbutton_TACT.
function pushbutton_TACT_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_TACT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

assignin('base', 'go_on', 1);
contents = cellstr(get(handles.popupmenu1,'String')); 
reconstruction_method=contents{get(handles.popupmenu1,'Value')};
reconstruction_methods;

for i=1:size(rec_meth, 2)
    if strcmp(reconstruction_method,rec_meth{i})==1
        epsilon=epsilon_vector(i);
        psf_values=psf_data(i, :);
    end
end

assignin('base', 'epsilon', epsilon);
assignin('base', 'psf_values', psf_values);

%bild=evalin('base', 'imlook4d_Cdata');
close('gui_threshold_calc')
return


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1



% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_TACT2.
function pushbutton_TACT2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_TACT2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin('base', 'own_roi', 1);
assignin('base', 'go_on', 1);
contents = cellstr(get(handles.popupmenu1,'String')); 
reconstruction_method=contents{get(handles.popupmenu1,'Value')};

reconstruction_methods;

for i=1:size(rec_meth, 2)
    if strcmp(reconstruction_method,rec_meth{i})==1
        epsilon=epsilon_vector(i);
        psf_values=psf_data(i, :);
    end
end

% switch reconstruction_method
%     case 'SharpIR 3 iterations'
%         epsilon=0.3; % Temporary value
%         psf_values=[1.48, 2.01]; %standard deviations in mm for x/y-direction and z-direction
%     case 'SharpIR 6 iterations'
%         epsilon=0.275;
%         psf_values=[1.37, 2.03];
%     case 'Vue Point HD'
%         epsilon=0.35;
%         psf_values=[3.15, 2.58];
% end
assignin('base', 'epsilon', epsilon);
assignin('base', 'psf_values', psf_values);

%bild=evalin('base', 'imlook4d_Cdata');
close('gui_threshold_calc')
return
