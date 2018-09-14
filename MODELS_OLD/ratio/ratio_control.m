function varargout = ratio_control(varargin)
% RATIO_CONTROL M-file for ratio_control.fig
%      ratio_CONTROL, by itself, creates a new ratio_CONTROL or raises the existing
%      singleton*.
%
%      H = RATIO_CONTROL returns the handle to a new ratio_CONTROL or the handle to
%      the existing singleton*.
%
%      RATIO_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ratio_CONTROL.M with the given input arguments.
%
%      RATIO_CONTROL('Property','Value',...) creates a new ratio_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ratio_control_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ratio_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ratio_control

% Last Modified by GUIDE v2.5 22-Sep-2008 16:08:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ratio_control_OpeningFcn, ...
                   'gui_OutputFcn',  @ratio_control_OutputFcn, ...
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


% --- Executes just before ratio_control is made visible.
function ratio_control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ratio_control (see VARARGIN)

% Choose default command line output for ratio_control
handles.output = hObject;

%
% MODIFIED - HERE GOES SETUP OF GUI, ETC
%
   disp('Entered ratio_control_OpeningFcn');
   
    %
    % INITIALIZATION of important communication between imlook4d and 
    %
        % Save link back to calling imlook4d instance
        handles.imlook4d_handle=varargin{1};                    % Handle to imlook4d instance
        imlook4d_handles=guidata(handles.imlook4d_handle);      % Handles to calling imlook4d instance (COPY OF HANDLES)

   
    %
    % USER INITIALIZATION  ( CHANGE THIS ONE )         
    %   
        % Create ROIPopupmenu from ROINames in imlook4d 
        ROINames=get(imlook4d_handles.ROINumberMenu,'String')
        ROINames{end}='No ROI defined';                         % Change last ROI name to "No ROI..."
        if size(ROINames,1)>1 ROINames={ROINames{1:end-1}}; end % If ROI names defined, remove last ROI name (otherwise keep "No ROI ...")
        set(handles.ROIPopupmenu, 'String', ROINames);
        
        % If model used before, set same parameters as before:
        try
            set(handles.ROIPopupmenu, 'Value', imlook4d_handles.model.ratio.ROINumber);
        catch
        end
    
    %
    % FINISH
    %
        guidata(handles.imlook4d_handle,imlook4d_handles); % Export modified handles back to imlook4d
        
%
% END MODIFIED
%


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ratio_control wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ratio_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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
        disp('Entered ratio_control/DonePushbutton_Callback');

        % Read local copy of imlook4d handles (directly from imlook4d)
        imlook4d_handles=guidata(handles.imlook4d_handle);  % New copy of imlook4d handles

        % Clear function handle (stops image generation from this function handle)
        imlook4d_handles.model.functionHandle=[];
    
    %
    % Apply settings
    %
    
        % Read value from GUI
        index=get(handles.ROIPopupmenu, 'Value');
        ROIStrings=get(handles.ROIPopupmenu, 'String');
        disp( ['ROI name=' ROIStrings{index} ] );

        % Modify local copy of imlook4d handles
        imlook4d_handles.model.ratio.ROIString=ROIStrings{index};
        imlook4d_handles.model.ratio.ROINumber=index;

        
        % Calculate new values, and put into imlook4d handles
        %[activity, NPixels]=generateTACT(imlook4d_handles, imlook4d_handles.image.Cdata, imlook4d_handles.image.ROI);
        [activity, NPixels]=generateTACT(imlook4d_handles, imlook4d_handles.image.ROI);
        imlook4d_handles.model.ratio.TACT=activity(index,:)
        
    %
    % Finish
    %

        % Define imlook4d callback function
        imlook4d_handles.model.functionHandle=@ratio;            % CHANGE THIS ONE 
        
        % Export modified handles back to imlook4d
        guidata(handles.imlook4d_handle,  imlook4d_handles); % Copy handles back to imlook4d

        % Close window when pressing DONE
        delete(handles.figure1);
        
        % Update imlook4d image
        imlook4d('updateImage',handles.imlook4d_handle, [], imlook4d_handles);



