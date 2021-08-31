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

    % Last Modified by GUIDE v2.5 25-Aug-2021 16:15:49

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
    
    % Don't show hidden rois
    [roinames, datastruct] = removeHiddenRoisFromStruct( roinames, datastruct);

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
            handles.uitable.ColumnWidth = {250, 'auto'};
         end


    % Draw initial graphs 
        numberOfRois = length( roinames );
        roinumbers = 1; % Guess only first ROI
        if numberOfRois < 10 % Draw all ROIs if less than 10 rois
            roinumbers = 1 : numberOfRois;
        end
        drawPlots( handles,roinumbers);
        handles.selectedRow = roinumbers;

    % % Make uitable sortable
    % % (From https://undocumentedmatlab.com/blog/uitable-sorting)
    % jscrollpane = findjobj(handles.uitable);
    % jtable = jscrollpane.getViewport.getView;
    % jtable.setSortable(true);		% or: set(jtable,'Sortable','on');
    % jtable.setAutoResort(true);
    % jtable.setMultiColumnSortable(true);
    % jtable.setPreserveSelectionsAfterSorting(true);
    
    %
    % Gray out menues 
    %
        % if Logan or Patlak (because export/copy curves is not implemented)
        test = [ title '                    '];
        if  strcmp( test(1:5), 'Logan') || ...
                strcmp( test(1:4), 'Zhou') || ...
                strcmp( test(1:6), 'Patlak') 
       
            handles.copy_curves.Enable='off';
            handles.copy_all_curves.Enable='off';
            handles.export_curve_menu.Enable='off';
        end
        
    %
    % Adjust layout for 'Time-activity curve'
    %
        if strcmp( 'Time-activity curve', title)
            %
            % Hide residual axis and buttons for residual
            %
                handles.residualAxes.Visible='off';
                handles.residual_uibuttongroup.Visible='off';
                
            %
            % Change dimensions of window, uitable
            %

                 % Pixel units on objects in figure
                 hObject = figureUnits( hObject, 'pixels');

                 heightChange = -240;  % Change in y to remove residual axis
                 widthChange = -280;   % Change in x to make uitable more narrow
                 y_move = [ 0 heightChange 0 0]; % Move down
                 y_shrink = [ 0 0 0 heightChange];
                 x_move = [ widthChange 0 0 0];  % Move left
                 x_shrink = [ 0 0 widthChange 0];

                 % Shrink
                 handles.modelWindow.Position = handles.modelWindow.Position + y_shrink + x_shrink;
                 handles.uitable.Position = handles.uitable.Position  + y_shrink + x_shrink;

                 % Move down and left
                 handles.mainAxes.Position = handles.mainAxes.Position + y_move + x_move; 
                 handles.lockedYradiobutton.Position = handles.lockedYradiobutton.Position + y_move + x_move; 
                 handles.setAxesRange.Position = handles.setAxesRange.Position + y_move + x_move; 

                % Normalized units on objects in figure (objects will change size on window resize)
                hObject = figureUnits( hObject, 'normalized');
        end
        
        %
        % Data cursor
        %
              % Set data cursor function
              dcm = datacursormode(hObject);
              set(dcm,'UpdateFcn',@modelWindowDataCursorUpdateFunction)
        

        % Update handles structure
        guidata(hObject, handles);
        
        % Adjust for Dark mode in 2020a
        dark_mode_adjust(hObject, [], handles)
        
    function hObject = figureUnits( hObject, unitname) % Modify drawing units 
            hObject.Units = unitname; 
            objects = hObject.Children;
            for i = 1 : length(objects)
                try
                    objects(i).Units = unitname; 
                catch
                end
            end
        
            
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

        % Data
        held = false;
        for i = 1:length(roinumbers)
            roinumber = roinumbers(i);
            
            
            try 
                h = plot (handles.datastruct.X{roinumber},handles.datastruct.Y{roinumber},...
                    'Marker','o', ...
                    'MarkerSize',6, ...                
                    'LineStyle','none',...
                    'Parent',handles.mainAxes ...
                    );
                % Get ROI color
                try
                    imlook4d_current_handles=evalin('base', 'imlook4d_current_handles');
                    c{i} = imlook4d_current_handles.roiColors(i,:);
                    set(h, 'MarkerFaceColor', c{i} );
                    set(h, 'MarkerEdgeColor', c{i} );
                catch
                    disp('Data Marker Color Error');
                end
                
                myLegends = [ myLegends handles.roinames{roinumber}  ];
                
                if held == false
                    hold(handles.mainAxes,'on');
                    held = true;
                end
            catch
                disp('data plot error');
            end
        end
        
        legend(handles.mainAxes,myLegends, 'Interpreter', 'none','Location','east');  
     
        % Reference
        try 
            plot (handles.datastruct.Xref,handles.datastruct.Yref,...
                'Marker','o', ...
                'MarkerSize',10, ...
                'LineStyle','none',...
                'Color','black',...
                'Parent',handles.mainAxes ...
                );
            myLegends = [ myLegends 'Reference'];

        catch
            disp('reference plot error');
        end      
        
        


        
        % Model
        for i = 1:length(roinumbers)
            roinumber = roinumbers(i);
            try 
                h = plot (handles.datastruct.Xmodel{roinumber},handles.datastruct.Ymodel{roinumber},...
                'LineStyle','-', ...
                'Parent',handles.mainAxes ...
                );
            
                try
                    %c{i} = get(h, 'Color'); % Store colors for each ROI
                    set(h, 'Color', c{i});
                    set(h, 'PickableParts', 'none'); % Disable Data selection (Want only to select data point)
                catch
                    disp('Model Marker Color Error');
                end
            catch
                disp('model plot error');
            end
        end

        
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
        delta = [ -1e-12 1e-12];
        handles.mainAxes.YLim = [Vmin +Vmax] + delta;

        if get(handles.lockedYradiobutton,'Value')
            handles.mainAxes.YLim = previousMainYLim;
        end
        
        hold(handles.mainAxes,'off'); 
    
    %
    % Write info
    %
        xlab = xlabel(handles.mainAxes,datastruct.xlabel);
        ylab = ylabel(handles.mainAxes,datastruct.ylabel);
        title(handles.mainAxes,'Data');

        legend(handles.mainAxes,myLegends, 'Interpreter', 'none','Location','east');    
        hold(handles.mainAxes,'off');

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
                    %disp('residual plot error');
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
%             handles.mainAxes.Legend.Position = [
%                 previousMainAxisLegendPosition(1), ... 
%                 previousMainAxisLegendPosition(2) + previousMainAxisLegendPosition(4) - handles.mainAxes.Legend.Position(4), ... 
%                 handles.mainAxes.Legend.Position(3), ... 
%                 handles.mainAxes.Legend.Position(4), ... 
%                 ];
%             handles.residualAxes.Legend.Position = [
%                 previousResidualAxisLegendPosition(1), ... 
%                 previousResidualAxisLegendPosition(2) + previousResidualAxisLegendPosition(4) - handles.residualAxes.Legend.Position(4), ... 
%                 handles.residualAxes.Legend.Position(3), ... 
%                 handles.residualAxes.Legend.Position(4), ... 
%                 ];
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
function output_txt = modelWindowDataCursorUpdateFunction(~,event_obj)     
        % ~            Currently not used (empty)
        % event_obj    Object containing event data structure
        % output_txt   Data cursor text (string or cell array 
        %              of strings)

        
        pos = get(event_obj,'Position')          
        x = pos(1);
        y = pos(2);

        frame = find( abs(event_obj.Target.XData -x) < 1e-6);
        
        %output_txt = {['X=',num2str(x) '\n  Y=',num2str(y)  '   frame =' num2str(frame) ]};
        output_txt = sprintf(['X=',num2str(x) '\nY=',num2str(y)  '\nframe =' num2str(frame) ]);
    
function export_curve_menu_Callback(hObject, eventdata, handles)
    TACThandles = buildTACTs(handles); % TODO : Use this in below functions, to get time info into copied TACTS
    SaveTact(hObject, eventdata, TACThandles)
function copy_curves_Callback(hObject, eventdata, handles)
        selectedRoinumbers = handles.selectedRow; 
        s = selectedTACTs(handles, selectedRoinumbers);
        clipboard('copy',s)
function copy_all_curves_Callback(hObject, eventdata, handles)
        numberOfRois = length( handles.roinames );
        allroinumbers = 1 : numberOfRois;
        s = selectedTACTs(handles, allroinumbers);
        clipboard('copy',s)
    function s = selectedTACTs(handles,roinumbers)
        % Initiate
            TAB=sprintf('\t');
            EOL=sprintf('\n');

            TACThandles = buildTACTs(handles);
            activity = TACThandles.TACT.tact;
            contents = TACThandles.TACT.roiNames;

            N=size(activity,1);  %Number of ROIs
            M=size(activity,2);  %Number of frames

        % Build header
            s=['frame' TAB 'time [s]' TAB 'duration [s]' TAB];

            for i = 1:length(roinumbers) % Loop number of ROIs
                index = roinumbers(i);
                s=[ s contents{index} TAB];
            end
            s=[ s(1:end-1) EOL];

        % Build data
            for i=1:N % Loop number of frames
                timeCols = [ num2str(uint8(i)) TAB num2str( TACThandles.TACT.startTime(i) ) TAB num2str( TACThandles.TACT.duration(i) ) TAB];
                s = [ s timeCols ];
                for j = 1:length(roinumbers); % Loop number of ROIs
                    index = roinumbers(j);
                    s=[ s num2str(activity(i,index)) TAB];
                end
                s=[ s(1:end-1) EOL];
            end
    function TACThandles = buildTACTs(handles)
        datastruct = handles.datastruct;

        %
        % Make struct to export to button
        %

        TACThandles = [];
        TACThandles.TACT.roiNames = handles.roinames;
        TACThandles.TACT.frameNumber = ( 1 : length(datastruct.X{1}) )';

         % Times
         T = 60 * datastruct.X{1};  % Modelwindow has time in minutes, convert to seconds for SaveTact
         TACThandles.TACT.startTime = T';


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
function copy_table_Callback(hObject, eventdata, handles)
    TAB=sprintf('\t');
    EOL=sprintf('\n');
    
    header = handles.uitable.ColumnName';
    data = handles.uitable.Data;
    
    numberOfRois = length( handles.roinames );
    numberOfColumns = length(header);
    
    % Build header
    s = [];
    for i = 1 : numberOfColumns - 1
        s=[ s header{i} TAB ];
    end
    s=[ s header{numberOfColumns} EOL ];
    
    % Replace '|' which is new row, with '/' for units
    s = strrep(s, '|', ' / ');
    
    % Build data
    for j = 1 : numberOfRois

        for i = 1 : numberOfColumns - 1
            s=[ s num2str( data{j,i}) TAB ];
        end
        s=[ s num2str( data{j,numberOfColumns}) EOL ];
    end
 
    clipboard('copy',s)   
function copy_plot_Callback(hObject, eventdata, handles)
    disp('Copy Plot Callback');
    GenerateScreenDump(hObject,{},handles);% Call function
function GenerateScreenDump(hObject, eventdata, handles,DISPLAY_ON_SCREEN)
            
            % Display clipboard on screen?
              DISPLAY_ON_SCREEN=false;
              %DISPLAY_ON_SCREEN=true;

 
            % New figure
            h1=figure('Visible','off','NumberTitle','off','Name', 'Clipboard');         % New HIDDEN figure
            if DISPLAY_ON_SCREEN
                set(h1,'Visible','on');
            end
            
            % Copy Axis and Legend
            copyobj([handles.mainAxes, handles.mainAxes.Legend ],h1); 

            
            % Set aspect ratio
            objects=get(h1,'Children');
            c = objects(2); % Axes
            c.PlotBoxAspectRatioMode = handles.mainAxes.PlotBoxAspectRatioMode
            c.PlotBoxAspectRatio = handles.mainAxes.PlotBoxAspectRatio

            % Figures
            origUnitsModelWindow = handles.modelWindow.Units;
            handles.modelWindow.Units = 'centimeters';
            h1.Units = 'centimeters';
            
            % Axes
            origUnitsModelWindowAxis = handles.mainAxes.Units;
            handles.mainAxes.Units = 'centimeters';
            c.Units = 'centimeters';

            % Legends
            origUnitsModelWindowLegend = handles.mainAxes.Legend.Units;
            handles.mainAxes.Legend.Units = 'centimeters';
            c.Legend.Units = 'centimeters';            
            
            c.Position(3:4) = handles.mainAxes.Position(3:4); % Copy Axes widths and height
            h1.Position(3:4) = c.Position(3:4) + [3 3]; % Set figure widths and heights 3 cm larger
            
            axisOffset = [2 2];
            
            c.Position(1) =  axisOffset(1); % Set axis position 2 cm
            c.Position(2) =  axisOffset(2); % Set axis position 2 cm
        
            %pause(0.5) % Give time to settle, before moving legend
            drawnow
            c.Legend.Position(1) = axisOffset(1) + handles.mainAxes.Legend.Position(1) - handles.mainAxes.Position(1);
            c.Legend.Position(2) = axisOffset(2) + handles.mainAxes.Legend.Position(2) - handles.mainAxes.Position(2);
           
            % Restore Units in ModelWindow (from my centimeters, to what was from beginning)
            handles.modelWindow.Units = origUnitsModelWindow;
            handles.mainAxes.Units = origUnitsModelWindowAxis;
            handles.mainAxes.Legend.Units = origUnitsModelWindowLegend;
            
            

           % set(h1,'PaperPositionMode','auto')
            %print(h1,'-dbitmap')
            
            try
                set(h1, 'InvertHardCopy', 'off');   % off = Use the same colors as the colors on the display. 
                h1.Color = [ 1 1 1];                % Make background of figure white
                print(h1,'-clipboard','-dbitmap'); 
            catch
                print(h1,'-dmeta')
            end
            
            if ~DISPLAY_ON_SCREEN
                close(h1)
            end   
function workspaceMenu_Callback(hObject, eventdata, handles)
    if (handles.selectedRow ==1)
        handles.SaveAsInputFunction.Enable = 'on';
    else
        handles.SaveAsInputFunction.Enable = 'off';
    end
    
function SaveVariableToWorkspace_Callback(hObject, eventdata, handles)
    selectedRoinumbers = handles.selectedRow;
    temp = cell2mat(handles.datastruct.Y')';
    assignin('base', 'StoredTACT', temp(:, selectedRoinumbers));
    
function SaveAsInputFunction_Callback(hObject, eventdata, handles)
    selectedRoinumbers = handles.selectedRow; 
    assignin('base', 'Cinp', handles.datastruct.Y{selectedRoinumbers});


% --- Executes on button press in setAxesRange.
function setAxesRange_Callback(hObject, eventdata, handles)
% hObject    handle to setAxesRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    XLim = handles.mainAxes.XLim;
    YLim = handles.mainAxes.YLim;
    name='Input for plot limits';
    numlines=1;

    prompt={'Xmin:','Xmax:','Ymin:','Ymax:'};
    defaultanswer={num2str(XLim(1)),num2str(XLim(2)),num2str(YLim(1)),num2str(YLim(2))};
    answer = inputdlg(prompt,name,numlines,defaultanswer);
    handles.mainAxes.XLim = [ str2num(answer{1}), str2num(answer{2}) ];
    handles.mainAxes.YLim = [ str2num(answer{3}), str2num(answer{4}) ];
    
    handles.lockedYradiobutton.Value = true;
