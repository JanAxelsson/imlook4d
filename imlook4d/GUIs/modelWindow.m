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

    % Last Modified by GUIDE v2.5 14-Sep-2018 18:21:39

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
    varargout{1} = handles;

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
            handles.uitable.Data = [roinames num2cell( cell2mat(datastruct.pars) )];
            for i = 1:length(datastruct.names)
                datastruct.names{i} = [datastruct.names{i} '|' datastruct.units{i} ];
            end
            handles.uitable.ColumnName =  ['ROI' datastruct.names ];
            %handles.uitable.RowName = roinames ;
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
function drawPlots( handles,roinumbers)

    datastruct = handles.datastruct;
    myLegends = {};
    
    try % May not be set first time
        previousMainYLim = handles.mainAxes.YLim;
        previousMainAxisLegendPosition = handles.mainAxes.Legend.Position;
        previousResidualAxisLegendPosition = handles.residualAxes.Legend.Position;
    catch
    end
     
    %
    % Draw reference, data, model 
    %   
    
        % Reference
        try 
            plot (handles.datastruct.Xref,handles.datastruct.Yref,...
                'Marker','o', ...
                'MarkerSize',7, ...
                'LineStyle','none',...
                'Color','black',...
                'Parent',handles.mainAxes ...
                );
            myLegends = [ myLegends 'Reference'];

            hold(handles.mainAxes,'on');
        catch
            %disp('reference plot error');
        end

        
        % Data
        for i = 1:length(roinumbers)
            roinumber = roinumbers(i);
            try 
                h = plot (handles.datastruct.X{roinumber},handles.datastruct.Y{roinumber},...
                    'Marker','o', ...
                    'MarkerSize',6, ...                
                    'LineStyle','none',...
                    'Parent',handles.mainAxes ...
                    );
                
                c{i} = get(h, 'Color'); % Store colors for each ROI
                
                set(h, 'MarkerFaceColor', c{i} );
                myLegends = [ myLegends handles.roinames{roinumber}  ];
                
                hold(handles.mainAxes,'on');
            catch
                disp('data plot error');
            end
        end

        
        % Model
        for i = 1:length(roinumbers)
            roinumber = roinumbers(i);
            try 
                h = plot (handles.datastruct.Xmodel{roinumber},handles.datastruct.Ymodel{roinumber},...
                'LineStyle','-', ...
                'Parent',handles.mainAxes ...
                );
            
                set(h, 'Color', c{i} ); % Stored when plotting Data, above
                hold(handles.mainAxes,'on');
            catch
                disp('model plot error');
            end
        end
        hold(handles.mainAxes,'off');
        
    %
    % Set axes
    %

        % Find max absolute value (exclude non-numbers)
        v = [0 100]; % Default value, one lowest and one highest
        try v = [ handles.datastruct.Y{roinumbers} ]; catch; end
        try v = [ handles.datastruct.Y{roinumbers} handles.datastruct.Yref ] ; catch; end

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
        xlabel(handles.mainAxes,datastruct.xlabel);
        ylabel(handles.mainAxes,datastruct.ylabel);
        title(handles.mainAxes,'Data');

        legend(handles.mainAxes,myLegends, 'Interpreter', 'none','Location','east');    

 
    %
    % Draw residuals
    %
        myLegends = {};
        try
            if handles.PercentResidualRadioButton.Value
                residual = handles.datastruct.residual;
                for i = 1:length(roinumbers)
                    roinumber = roinumbers(i);
                    residual{roinumber} = 100 * handles.datastruct.residual{roinumber} ./ handles.datastruct.Ymodel{roinumber};
                end
                residualLabel = '% Diff';
            end
            if handles.AbsoluteResidualRadioButton.Value
                residual = handles.datastruct.residual;
                residualLabel = 'Diff';
            end
            
            myLegends = {};

            for i = 1:length(roinumbers)
                roinumber = roinumbers(i);
                try 
                    h =  plot (handles.datastruct.Xmodel{roinumber},residual{roinumber},...
                        'Marker','o', ...
                        'MarkerSize',6, ...
                        'LineStyle','none',...
                        'Parent', handles.residualAxes ...
                        );
                    set(h, 'MarkerFaceColor', c{i} );% Stored when plotting Data, above
                    hold(handles.residualAxes,'on');
                catch
                    disp('residual plot error');
                end
            end
            hold(handles.residualAxes,'off');

            title(handles.residualAxes,'Residual');

            handles.residualAxes.XAxisLocation = 'origin';
            handles.residualAxes.XLim = handles.mainAxes.XLim; % Same x-axis on both graphs
            m = max( abs(residual{roinumbers} )); % Find max absolute value
            m = m * 1.25 + 0.1; % Get some space
            handles.residualAxes.YLim = [ -m +m]; % Symmetric Y-residual axis around zero

            ylabel(handles.residualAxes,residualLabel);
        catch
        end
   %
   % Restore positions
   %
        try % May not be set first time
            handles.mainAxes.Legend.Position = [
                previousMainAxisLegendPosition(1), ... 
                previousMainAxisLegendPosition(2) + previousMainAxisLegendPosition(4) - handles.mainAxes.Legend.Position(4), ... 
                handles.mainAxes.Legend.Position(3), ... 
                handles.mainAxes.Legend.Position(4), ... 
                ];
            handles.residualAxes.Legend.Position = [
                previousResidualAxisLegendPosition(1), ... 
                previousResidualAxisLegendPosition(2) + previousResidualAxisLegendPosition(4) - handles.residualAxes.Legend.Position(4), ... 
                handles.residualAxes.Legend.Position(3), ... 
                handles.residualAxes.Legend.Position(4), ... 
                ];
        catch
        end

%
% Callbacks
%
function uitable_CellSelectionCallback(~, eventdata, handles)
    roinumbers = unique( eventdata.Indices(:,1) );
    drawPlots( handles,roinumbers);
    handles.selectedRow = roinumbers;
    guidata(handles.modelWindow, handles);
function AbsoluteResidualRadioButton_Callback(~, eventdata, handles)
     drawPlots( handles, handles.selectedRow);
function PercentResidualRadioButton_Callback(~, eventdata, handles)
     drawPlots( handles,handles.selectedRow); 
function LockYradiobutton_Callback(~, eventdata, handles)
     drawPlots( handles,handles.selectedRow); 
function export_curve_menu_Callback(hObject, eventdata, handles)
    datastruct = handles.datastruct;

    %
    % Make struct to export to button
    %

    TACThandles = [];
    TACThandles.TACT.roiNames = handles.roinames;
    TACThandles.TACT.frameNumber = ( 1 : length(datastruct.X{1}) )';
    
    % Times
    try
        midtime = 60 * datastruct.X{1};  % Modelwindow has time in minutes, convert to seconds for SaveTact
        TACThandles.TACT.midTime = midtime;
        
        % Jans way to get start time and dT from midtime
        %
        % NOTE: There is not enough information for short water scans on GE
        % scanner, where the T and dT:s don't add up.

        % tmid(i) = T(i) + 0.5 * dT(i);
        % T(i) = tmid(i) - 0.5 * dT(i);
        
        %  <-  dT(1)  -><-  dT(2)  ->    ...   <-  dT(i-1) -><-  dT(i)  -> 
        %  |           |            |    ...   |            |            | 
        % T(1)    .   T(2)   .    T(3)   ...  T(i-1)  .   T(i)   .    T(i+1)   
        %         .          .           ...          .           .
        %       mid(1)      mid(2)       ...       mid(i-1)      mid(i)
        %
        dT(1) = 2 * midtime(1);
        T(1) = 0;
        
        for i = 2:length(midtime)
            T(i)  = T(i-1) + dT(i-1);
            dT(i) = 2 * ( midtime(i) - T(i) );
        end
        
        
        TACThandles.TACT.startTime = T';
        TACThandles.TACT.duration = dT';
    catch
        disp('newTACT error -- time information missing?');
    end
    
    % If startTime and duration stored in extras
    try
        TACThandles.TACT.startTime = 60 * datastruct.extras.frameStartTime';
        TACThandles.TACT.duration = 60 * datastruct.extras.frameDuration';
    catch
        
    end

    % Statistics
    TACThandles.TACT.tact = cell2mat(datastruct.Y')'; % ROI value for each frame
    try
        TACThandles.TACT.std = datastruct.extras.stdev';
        TACThandles.TACT.pixels = datastruct.extras.N';
    catch
        disp('Statistics info missing');
        TACThandles.TACT.std = zeros( size(T))';
        TACThandles.TACT.pixels = zeros( size(T))'; 
    end
    
    % Additional
    try
        TACThandles.image.unit = datastruct.extras.unit;
    catch
        TACThandles.image.unit = ' ';
    end

    SaveTact(hObject, eventdata, TACThandles)
