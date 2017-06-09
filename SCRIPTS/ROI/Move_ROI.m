function varargout = Move_ROI(varargin)
% MOVE_ROI MATLAB code for Move_ROI.fig
%      MOVE_ROI, by itself, creates a new MOVE_ROI or raises the existing
%      singleton*.
%
%      H = MOVE_ROI returns the handle to a new MOVE_ROI or the handle to
%      the existing singleton*.
%
%      MOVE_ROI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOVE_ROI.M with the given input arguments.
%
%      MOVE_ROI('Property','Value',...) creates a new MOVE_ROI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Move_ROI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Move_ROI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Move_ROI

% Last Modified by GUIDE v2.5 06-Dec-2012 18:03:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Move_ROI_OpeningFcn, ...
                   'gui_OutputFcn',  @Move_ROI_OutputFcn, ...
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


% --- Executes just before Move_ROI is made visible.
function Move_ROI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Move_ROI (see VARARGIN)

% Choose default command line output for Move_ROI
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Move_ROI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Move_ROI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pushbutton_left.
function pushbutton_left_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('LEFT');
move_ROI( -1 , hObject, eventdata, handles);


% --- Executes on button press in pushbutton_right.
function pushbutton_right_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('RIGHT');
move_ROI( +1 , hObject, eventdata, handles);




function stepSizeText_Callback(hObject, eventdata, handles)
% hObject    handle to stepSizeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stepSizeText as text
%        str2double(get(hObject,'String')) returns contents of stepSizeText as a double


% --- Executes during object creation, after setting all properties.
function stepSizeText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepSizeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function move_ROI(direction, hObject, eventdata, handles)

imlook4d_current_handle=evalin('base', 'imlook4d_current_handle');
imlook4d_current_handles=guidata(imlook4d_current_handle);

% Export variables to work space
ExportUntouched 

% Get direction
strcmp('on', get(handles.X_radioButton,'Value') );

% Move ROI
ROIToMove=evalin('base', 'imlook4d_ROI_number');
imlook4d_ROI=evalin('base', 'imlook4d_ROI');

% Move all ROIs
if get(handles.AllROIsRadioButton,'Value')==1
    % Move all ROIs, using: 
    %   vector describing direction [ 1 0 0] or similar, 
    %   direction (+1 / -1)
    %   stepSixe  ( get(handles.stepSizeText,'String') )
    imlook4d_ROI=circshift(imlook4d_ROI, ...
        str2num( get(handles.stepSizeText,'String'))*direction*[ get(handles.X_radioButton,'Value') get(handles.Y_radioButton,'Value') get(handles.Z_radioButton,'Value') ]...
        ); 
end

% Move current ROI
if get(handles.CurrentROIRadioButton,'Value')==1
    % Move current ROI, using: 
    %   vector describing direction [ 1 0 0] or similar, 
    %   direction (+1 / -1)
    %   stepSixe  ( get(handles.stepSizeText,'String') )
           

   % Set pixels in all other ROIs
   logicalA=(imlook4d_ROI==ROIToMove);          % Active ROI
   %logicalB=(imlook4d_ROI~=0);                  % All ROIs
   %logicalC=xor(logicalA , logicalB);           % Removes Active ROI from All ROIs

   imlook4d_ROI(logicalA)=0;
   
    % Move current ROI
    logicalA=circshift(logicalA, ...
        str2num( get(handles.stepSizeText,'String'))*direction*[ get(handles.X_radioButton,'Value') get(handles.Y_radioButton,'Value') get(handles.Z_radioButton,'Value') ]...
        ); 
    % Put moved ROI into other ROIs
    imlook4d_ROI(logicalA)=ROIToMove;
end

% Import
assignin('base', 'imlook4d_ROI', imlook4d_ROI); 
%ImportUntouched
Import


