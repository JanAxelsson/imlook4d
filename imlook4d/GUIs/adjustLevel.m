% Standard GUIDE code

function varargout = adjustLevel(varargin)
% ADJUSTLEVEL MATLAB code for adjustLevel.fig
%      ADJUSTLEVEL, by itself, creates a new ADJUSTLEVEL or raises the existing
%      singleton*.
%
%      H = ADJUSTLEVEL returns the handle to a new ADJUSTLEVEL or the handle to
%      the existing singleton*.
%
%      ADJUSTLEVEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADJUSTLEVEL.M with the given input arguments.
%
%      ADJUSTLEVEL('Property','Value',...) creates a new ADJUSTLEVEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before adjustLevel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to adjustLevel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help adjustLevel

% Last Modified by GUIDE v2.5 28-Sep-2018 12:13:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @adjustLevel_OpeningFcn, ...
                   'gui_OutputFcn',  @adjustLevel_OutputFcn, ...
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
function varargout = adjustLevel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [];


% On Open   
function adjustLevel_OpeningFcn(hObject, eventdata, handles, varargin)


    imlook4d_handle = varargin{1};
    handles.imlook4d_handles = varargin{3};
    
    handles.imlook4d_handles.autoColorScaleRadioButton.Value = 0; % Turn off auto colorscale on imlook4d

    slice=round(get(handles.imlook4d_handles.SliceNumSlider,'Value'));
    frame=round(get(handles.imlook4d_handles.FrameNumSlider,'Value'));

    Limits=handles.imlook4d_handles.ColorBar.YLim;  % Read limits from current color bar
    currentMin = Limits(1);
    currentMax = Limits(2);
    
    handles.initial.min = currentMin;
    handles.initial.max = currentMax;
    
    pixelVector = handles.imlook4d_handles.image.Cdata(:,:,:,frame);
    minValue = min( pixelVector(:) );
    maxValue = max( pixelVector(:) );
    
    if currentMax > maxValue
        maxValue = currentMax;
    end    
    if currentMin < minValue
        minValue = currentMin;
    end
    
    % Define sliders
    handles.minSlider.Min = minValue;
    handles.minSlider.Max = maxValue;
    handles.minSlider.Value = currentMin;
    
    handles.maxSlider.Min = minValue;
    handles.maxSlider.Max = maxValue;
    handles.maxSlider.Value = currentMax;
    
    % Set edits
    handles.minEdit.String = num2str(currentMin);
    handles.maxEdit.String = num2str(currentMax);
    
  

    
    tempData = handles.imlook4d_handles.image.CachedImage;      % Read cached image, Image data (not flipped or rotated)
    
    %
    % Continous update on sliders
    %
    
        % Tip from http://www.alecjacobson.com/weblog/?p=4098
        hs1 = handles.minSlider;
        hs1.addlistener('Value','PostSet',...
            @(src,data) data.AffectedObject.Callback(data.AffectedObject,struct('Source',data.AffectedObject,'EventName','Action')) ...
            );


        hs2 = handles.maxSlider;
        hs2.addlistener('Value','PostSet',...
            @(src,data) data.AffectedObject.Callback(data.AffectedObject,struct('Source',data.AffectedObject,'EventName','Action')) ...
            );

    

    % Update handles structure
    guidata(hObject, handles);

%
% Utility functions
%
function update_imlook4d( handles)

    CLim=[ handles.minSlider.Value, ...
        handles.maxSlider.Value ...
        ]; 
    imlook4d( 'setColorBar',  handles.imlook4d_handles, CLim);
    imlook4d('updateImage',handles.imlook4d_handles.figure1, [], handles.imlook4d_handles);
    
%
% Callbacks
%
function minSlider_Callback(hObject, eventdata, handles)
    handles.minEdit.String = num2str( handles.minSlider.Value);
    if handles.minSlider.Value > handles.maxSlider.Value 
        handles.maxSlider.Value  = handles.minSlider.Value ;
    end
    update_imlook4d(handles);
function maxSlider_Callback(hObject, eventdata, handles)
    handles.maxEdit.String = num2str( handles.maxSlider.Value);
    if handles.maxSlider.Value < handles.minSlider.Value  
        handles.minSlider.Value = handles.maxSlider.Value - 1e-12; % Make slightly less than max value
    end
    update_imlook4d(handles);
function minEdit_Callback(hObject, eventdata, handles)
    if ( str2num( handles.minEdit.String ) < handles.minSlider.Min ) 
        % Lower minimum value for slider
        handles.minSlider.Min = str2num( handles.minEdit.String );
        handles.maxSlider.Min = str2num( handles.minEdit.String );
    end
    handles.minSlider.Value = str2num(handles.minEdit.String);
function maxEdit_Callback(hObject, eventdata, handles)
    if ( str2num( handles.maxEdit.String ) > handles.maxSlider.Max ) 
        % Raise maximum value for slider
        handles.minSlider.Max = str2num( handles.maxEdit.String );
        handles.maxSlider.Max = str2num( handles.maxEdit.String );
    end
    handles.maxSlider.Value = str2num(handles.maxEdit.String);

function ResetPushButton_Callback(hObject, eventdata, handles)
    initialMin = handles.initial.min;
    initialMax = handles.initial.max;
    
    handles.minSlider.Min = initialMin;
    handles.minSlider.Max = initialMax;
    
    handles.maxSlider.Min = initialMin;
    handles.maxSlider.Max = initialMax;
    
    frame=round(get(handles.imlook4d_handles.FrameNumSlider,'Value'));
    pixelVector = handles.imlook4d_handles.image.Cdata(:,:,:,frame);
    minValue = min( pixelVector(:) );
    maxValue = max( pixelVector(:) );
    
    handles.minSlider.Value = minValue;
    handles.maxSlider.Value = maxValue;
    
    minEdit_Callback(hObject, eventdata, handles)
    maxEdit_Callback(hObject, eventdata, handles)

function closereq_Callback(hObject, eventdata, handles)
    if handles.imlook4d_handles.record.enabled % Script recording on
        recordInputsText(handles.imlook4d_handles,{ handles.minEdit.String, handles.maxEdit.String});  % Insert text at caret
    end
    closereq
