% Standard GUIDE code
    function varargout = tactWindow(varargin)
        % TACTWINDOW MATLAB code for tactWindow.fig
        %      TACTWINDOW, by itself, creates a new TACTWINDOW or raises the existing
        %      singleton*.
        %
        %      H = TACTWINDOW returns the handle to a new TACTWINDOW or the handle to
        %      the existing singleton*.
        %
        %      TACTWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
        %      function named CALLBACK in TACTWINDOW.M with the given input arguments.
        %
        %      TACTWINDOW('Property','Value',...) creates a new TACTWINDOW or raises the
        %      existing singleton*.  Starting from the left, property value pairs are
        %      applied to the GUI before modelWindow_OpeningFcn gets called.  An
        %      unrecognized property name or invalid value makes property application
        %      stop.  All inputs are passed to modelWindow_OpeningFcn via varargin.
        %
        %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
        %      instance to run (singleton)".
        %
        % See also: GUIDE, GUIDATA, GUIHANDLES

        % Edit the above text to modify the response to help tactWindow

        % Last Modified by GUIDE v2.5 16-Sep-2018 22:39:33

        % Begin initialization code - DO NOT EDIT
    gui_Singleton = 0;
        gui_State = struct('gui_Name',       mfilename, ...
                           'gui_Singleton',  gui_Singleton, ...
                           'gui_OpeningFcn', @tactWindow_OpeningFcn, ...
                           'gui_OutputFcn',  @tactWindow_OutputFcn, ...
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
    function varargout = tactWindow_OutputFcn(~, ~, handles) 
        % --- Outputs from this function are returned to the command line.
        % varargout  cell array for returning output args (see VARARGOUT);
        % hObject    handle to figure
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)

        % Get default command line output from handles structure
        varargout{1} = handles.output;

% On Open    
    function tactWindow_OpeningFcn(hObject, ~, handles, ROI_data_struct, title, varargin)
    % --- Executes just before tactWindow is made visible.
        % This function has no output args, see OutputFcn.
        % hObject    handle to figure
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        % varargin   command line arguments to tactWindow (see VARARGIN)

        % Choose default command line output for tactWindow
        handles.output = hObject;

        % Update handles structure
        guidata(hObject, handles);

        % UIWAIT makes tactWindow wait for user response (see UIRESUME)
        % uiwait(handles.tactWindow);

        % Store in handles
        roinames = ROI_data_struct.names;

        datastruct.names = {'mean', 'volume', 'pixels','max', 'min', 'std'};
        datastruct.units = {'', '', '', '', '', ''};
            datastruct.pars = { ROI_data_struct.mean', ...
            ROI_data_struct.volume', ...
            ROI_data_struct.Npixels', ...
            ROI_data_struct.max', ...
            ROI_data_struct.min', ...
            ROI_data_struct.stdev', ...
        };

    
    
        datastruct.names = {'mean', 'volume', 'pixels','max', 'min', 'std','skew','kurt','uniformity','entropy'};
        datastruct.units = {'', '', '', '', '', '', '', '', '', ''};
            datastruct.pars = { ROI_data_struct.mean', ...
            ROI_data_struct.volume', ...
            ROI_data_struct.Npixels', ...
            ROI_data_struct.max', ...
            ROI_data_struct.min', ...
            ROI_data_struct.stdev', ...
            ROI_data_struct.skewness', ...
            ROI_data_struct.kurtosis', ...
            ROI_data_struct.uniformity', ...
            ROI_data_struct.entropy', ...
        };
    
    
    
        handles.datastruct = datastruct;
        handles.ROI_data_struct = ROI_data_struct;
        handles.roinames = ROI_data_struct.names;
        handles.title = title;    

        % Set figure name
        set(handles.tactWindow, 'Name', title);

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
                handles.uitable.ColumnName =  {'ROI'};
                handles.uitable.ColumnWidth = {200, 'auto'};
             end

         % Set defaults
         setappdata(handles.tactWindow, 'previousRoiNumbernumber',1);



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
            previousRoiNumbernumber = getappdata(handles.tactWindow, 'previousRoiNumbernumber');
            previousMainXLim = getappdata(handles.tactWindow, 'previousMainXLim');
            previousMainXTickLabel = getappdata(handles.tactWindow, 'previousMainXTickLabel');
            %previousMainYLim = getappdata(handles.tactWindow, 'previousMainYLim');
            %previousSecondXLim = getappdata(handles.tactWindow, 'previousSecondXLim');
            %previousSecondYLim = getappdata(handles.tactWindow, 'previousSecondYLim');

        catch
            previousRoiNumbernumber = 1;
        end

        %
        % Draw histograms
        %
            myLegends = {};


            try % Histogram
                histogram( handles.ROI_data_struct.pixels{roinumber}, ...
                    'Parent', handles.mainAxes)
            catch
            end

            try % Histogram previous
                histogram( handles.ROI_data_struct.pixels{previousRoiNumbernumber}, ...
                    'Parent', handles.secondAxes)
            catch
            end

        %
        % Set axes
        %
            % Set to previous or optimum
            try
                optimumXLim = [ min( handles.ROI_data_struct.min )  max( handles.ROI_data_struct.max ) ];
                handles.mainAxes.XLim = optimumXLim;
                handles.secondAxes.XLim = optimumXLim;

                if get(handles.lockedXradiobutton,'Value')
                    handles.mainAxes.XLim = previousMainXLim;
                    handles.secondAxes.XLim = previousSecondXLim;

                    handles.mainAxes.XTickLabel = previousMainXLim;
                end

            catch
            end

            % Same x-axis on both histograms
            handles.secondAxes.XLim = handles.mainAxes.XLim;


        %
        % Write info
        %
            handles.mainAxesRoiName.String = [ 'ROI = ' handles.roinames{roinumber} ];
            handles.secondAxesRoiName.String = [ 'ROI = ' handles.roinames{previousRoiNumbernumber} ];
            title(handles.mainAxes,'ROI pixel values');
            title(handles.secondAxes,'Previous ROI');

            %legend(handles.mainAxes,myLegends, 'Interpreter', 'none');    


       %
       % Restore positions
       %



       %
       % Store for next time
       %
            if (previousRoiNumbernumber ~= roinumber)
                setappdata(handles.tactWindow, 'previousRoiNumbernumber', roinumber);
                setappdata(handles.tactWindow, 'previousMainXLim',handles.mainAxes.XLim);
                %setappdata(handles.tactWindow, 'previousMainXTickLabel',handles.mainAxes.XTickLabel);
            end

    % Shading of Pressed Toolbar Buttons
    function pressedToggleButton( hObject)
       if ismac
           icon = hObject.CData;
           hObject.UserData = icon; % Remember original icon

           % Determine background from NaN in first dimension (which is
           % what Matlab seems to use for built in togglebuttons)
           background(:,:,3) = isnan( icon(:,:,1) );
           background(:,:,2) = isnan( icon(:,:,1) );
           background(:,:,1) = isnan( icon(:,:,1) );

           newIcon = icon;
           newIcon( background) = 0.8;

           hObject.CData = newIcon;
       end  
    function releasedToggleButton( hObject)
        if ismac
            hObject.CData = hObject.UserData;  % Restore
        end
%
% Callbacks
%
function uitable_CellSelectionCallback(~, eventdata, handles)
    roinumber = eventdata.Indices(1);
    drawPlots( handles,roinumber);
    handles.selectedRow = roinumber;
    guidata(handles.tactWindow, handles);
function lockedXradiobutton_Callback(~, ~, handles)
    roinumber = handles.selectedRow;
    setappdata(handles.tactWindow, 'previousMainXLim',handles.mainAxes.XLim);
    drawPlots( handles,roinumber)
