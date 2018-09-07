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
    
    %
    % Populate table
    %
        handles.uitable.RowStriping = 'on';
        handles.uitable.RearrangeableColumns = 'on';

        % If parameters exists, make row names into table side
        % If no parameters, write row names in table cells
        if length(datastruct.names) > 0
            handles.uitable.Data = [num2cell( cell2mat(datastruct.pars) )];
            for i = 1:length(datastruct.names)
                datastruct.names{i} = [datastruct.names{i} '|' datastruct.units{i} ];
            end;
            handles.uitable.ColumnName =  datastruct.names;
            handles.uitable.RowName = roinames ;
        else
            handles.uitable.Data = roinames;
            datastruct.names = datastruct.names;
            handles.uitable.ColumnName =  {'ROI'};
            handles.uitable.ColumnWidth = {200, 'auto'};
        end

        

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
    
    try % May not be set first time
        previousMainYLim = handles.mainAxes.YLim;
        previousMainAxisLegendPosition = handles.mainAxes.Legend.Position;
        previousResidualAxisLegendPosition = handles.residualAxes.Legend.Position;
    catch
    end

    %
    % Draw data and model
    %
        myLegends = {};
        try % Data
            plot (handles.datastruct.X{roinumber},handles.datastruct.Y{roinumber},...
                'Marker','o', ...
                'MarkerSize',6, ...
                'LineStyle','none',...
                'Color','blue',...
                'MarkerFaceColor','blue',...
                'Parent',handles.mainAxes)
            myLegends = [ myLegends 'ROI'];
        catch
        end

        try % Model
            hold(handles.mainAxes,'on');
            plot (handles.datastruct.Xmodel{roinumber},handles.datastruct.Ymodel{roinumber},...
                'LineStyle','-', ...
                'Color','blue',...
                'Parent',handles.mainAxes)
            myLegends = [ myLegends 'Model'];

        catch
        end

        try % Reference
            plot (handles.datastruct.Xref,handles.datastruct.Yref,...
                'Marker','o', ...
                'MarkerSize',7, ...
                'LineStyle','none',...
                'Color','red',...
                'Parent',handles.mainAxes)
            myLegends = [ myLegends 'Reference'];
        catch
        end
        hold(handles.mainAxes,'off');
        
    %
    % Set axes
    %

        % Find max absolute value (exclude non-numbers)
        v = [0 100]; % Default value, one lowest and one highest
        try v = [ handles.datastruct.Y{roinumber} ]; catch; end
        try v = [ handles.datastruct.Y{roinumber} handles.datastruct.Yref ] ; catch; end

        V = v( find( isfinite(v))); % Remove Inf and NaN
        Vmax = max(V);
        Vmin = min(V);
        
        % Get some space above
        Vmax = Vmax * 1.2; 
        
        % Get some space below (or start at zero)
        if Vmin >=0 % Y-axis starts at 0
            Vmin = 0;
        else 
            Vmin = Vmin * 1.2; % Get some space
        end
        
        % Set axis 
        handles.mainAxes.YLim = [Vmin +Vmax];

        if get(handles.lockedYradiobutton,'Value')
            handles.mainAxes.YLim = previousMainYLim;
        end
    
    
    %
    % Write info
    %
        handles.mainAxesRoiName.String = [ 'ROI = ' handles.roinames{roinumber} ];
        xlabel(handles.mainAxes,datastruct.xlabel);
        ylabel(handles.mainAxes,datastruct.ylabel);
        title(handles.mainAxes,'Model');

        legend(handles.mainAxes,myLegends);    


 
    %
    % Draw residuals
    %
        myLegends = {};
        try
            if handles.PercentResidualRadioButton.Value
                residual = 100 * handles.datastruct.residual{roinumber} ./ handles.datastruct.Ymodel{roinumber};
                residualLabel = '% Diff';
                myLegends = [ myLegends '100 * (ROI - Model) / Model'];
            end
            if handles.AbsoluteResidualRadioButton.Value
                residual = handles.datastruct.residual{roinumber};
                residualLabel = 'Diff';
                myLegends = [ myLegends 'ROI - Model'];
            end
            plot (handles.datastruct.Xmodel{roinumber},residual,...
                'Marker','o', ...
                'MarkerSize',6, ...
                'LineStyle','none',...
                'Color','blue',...
                'MarkerFaceColor','blue',...
                'Parent', ...
                handles.residualAxes)


            title(handles.residualAxes,'Residual');
            legend(handles.residualAxes, myLegends);

            handles.residualAxes.XAxisLocation = 'origin';
            handles.residualAxes.XLim = handles.mainAxes.XLim; % Same x-axis on graphs
            m = max( abs(residual) ); % Find max absolute value
            m = m * 1.25 + 0.1; % Get some space
            handles.residualAxes.YLim = [ -m +m]; % Symmetric Y-residual axis around zero

            ylabel(handles.residualAxes,residualLabel);
        catch
        end
   %
   % Restore positions
   %
        try % May not be set first time
            handles.mainAxes.Legend.Position = previousMainAxisLegendPosition;
            handles.residualAxes.Legend.Position = previousResidualAxisLegendPosition;
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
