% Standard GUIDE code
function varargout = modelWindow(varargin)
    % MODELWINDOW MATLAB code for modelWindow.fig
    %      MODELWINDOW, by itself, creates a new MODELWINDOW or raises the existing
    %      singleton*.
    %
    %      H = MODELWINDOW returns the handle to a new MODELWINDOW or the handle to
    %      the existing singleton*.
    %
    %      MODELWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in MODELWINDOW.M with the given input arguments.
    %
    %      MODELWINDOW('Property','Value',...) creates a new MODELWINDOW or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before modelWindow_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to modelWindow_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help modelWindow

    % Last Modified by GUIDE v2.5 28-Aug-2018 16:46:30

    % Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @modelWindow_OpeningFcn, ...
                       'gui_OutputFcn',  @modelWindow_OutputFcn, ...
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
    dummy=1; % Dummy to hide when code folding
function varargout = modelWindow_OutputFcn(~, ~, handles) 
    % --- Outputs from this function are returned to the command line.
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;

% On Open    
function modelWindow_OpeningFcn(hObject, ~, handles, datastruct, roinames, title, varargin)
% --- Executes just before modelWindow is made visible.
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to modelWindow (see VARARGIN)

    % Choose default command line output for modelWindow
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes modelWindow wait for user response (see UIRESUME)
    % uiwait(handles.modelWindow);

    % Store in handles
    handles.datastruct = datastruct;
    handles.roinames = roinames;
    handles.title = title;
    
    % Set figure name
    set(handles.modelWindow, 'Name', title);
    
    % Populate table
    handles.uitable.Data = [roinames, num2cell( cell2mat(datastruct.pars) )];
    handles.uitable.ColumnWidth = {200, 'auto'};
    
    for i = 1:length(datastruct.names)
        datastruct.names{i} = [datastruct.names{i} '|' datastruct.units{i} ];
    end;
    handles.uitable.ColumnName = [ 'name' datastruct.names];

    % Draw initial graphs
    handles.selectedRow = 1;    
    drawPlots( handles,handles.selectedRow);

    % % Make uitable sortable
    % % (From https://undocumentedmatlab.com/blog/uitable-sorting)
    % jscrollpane = findjobj(handles.uitable);
    % jtable = jscrollpane.getViewport.getView;
    % jtable.setSortable(true);		% or: set(jtable,'Sortable','on');
    % jtable.setAutoResort(true);
    % jtable.setMultiColumnSortable(true);
    % jtable.setPreserveSelectionsAfterSorting(true);


    % Update handles structure
    guidata(hObject, handles);
    
%
% Utility functions
%
function drawPlots( handles,roinumber)
    datastruct = handles.datastruct;
    previousMainYLim = handles.mainAxes.YLim;
    
    %
    % Write info
    %
    handles.mainAxesRoiName.String = [ 'ROI = ' handles.roinames{roinumber} ];
    
    %
    % Draw data and model
    %
    try
        plot (handles.datastruct.X{roinumber},handles.datastruct.Y{roinumber},...
            'Marker','o', ...
            'LineStyle','none',...
            'Color','blue',...
            'Parent',handles.mainAxes)
        
        xlabel(handles.mainAxes,datastruct.xlabel);
        ylabel(handles.mainAxes,datastruct.ylabel);
        title(handles.mainAxes,'Model');
    catch
    end
    
    try
        hold(handles.mainAxes,'on');
        plot (handles.datastruct.Xmodel{roinumber},handles.datastruct.Ymodel{roinumber},...
            'LineStyle','-', ...
            'Color','blue',...
            'Parent',handles.mainAxes)
        hold(handles.mainAxes,'off');

    catch
        hold(handles.mainAxes,'off');
    end
    
    m = max( abs(handles.datastruct.Y{roinumber}) ); % Find max absolute value
    m = m * 1.2; % Get some space
    handles.mainAxes.YLim = [0 +m];
    
    if get(handles.lockedYradiobutton,'Value')
        handles.mainAxes.YLim = previousMainYLim; 
    end

    %
    % Draw residuals
    %
    try
        if handles.PercentResidualRadioButton.Value
            residual = 100 * handles.datastruct.residual{roinumber} ./ handles.datastruct.Ymodel{roinumber};
            residualLabel = '% Diff';
        end
        if handles.AbsoluteResidualRadioButton.Value
            residual = handles.datastruct.residual{roinumber};
            residualLabel = 'Diff';
        end
        plot (handles.datastruct.Xmodel{roinumber},residual,...
            'Marker','o', ...
            'LineStyle','none',...
            'Color','blue',...
            'Parent',handles.residualAxes)
        
        title(handles.residualAxes,'Residual');
        handles.residualAxes.XAxisLocation = 'origin';
        handles.residualAxes.XLim = handles.mainAxes.XLim;
        m = max( abs(residual) ); % Find max absolute value
        m = m * 1.25 + 0.1; % Get some space
        handles.residualAxes.YLim = [ -m +m]; % Symmetric Y-residual axis around zero
        
        ylabel(handles.residualAxes,residualLabel);
    catch
    end
    
%
% Callbacks
%
function uitable_CellSelectionCallback(~, eventdata, handles)
    roinumber = eventdata.Indices(1);
    drawPlots( handles,roinumber);
    handles.selectedRow = roinumber;
    guidata(handles.modelWindow, handles);
function AbsoluteResidualRadioButton_Callback(~, ~, handles)
    roinumber = handles.selectedRow;
    drawPlots( handles,roinumber)
function PercentResidualRadioButton_Callback(~, ~, handles)
    roinumber = handles.selectedRow;
    drawPlots( handles,roinumber)  
function LockYradiobutton_Callback(~, ~, handles)
    roinumber = handles.selectedRow;
    drawPlots( handles,roinumber)
