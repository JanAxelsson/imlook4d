function varargout = imlook4d_model(varargin)
%
% IMLOOK4D_MODEL
%
% GUI for pharmaco-kinetic modelling for PET
%
% Example:
% imlook4d_model % Opens an empty window 
% imlook4d_model( tact-struct) % Opens a tact-struct, created by imlook4d / SCRIPTS /ROI /Export-to-workspace
%
%
%
% Author:  Jan Axelsson

% IMLOOK4D_MODEL MATLAB code for imlook4d_model.fig
%
% DEVELOP, when updating classes
% h=findobj('Tag', 'imlook4d_model');close(h)
%
% -----------------------------------------------------------------------------------
%      IMLOOK4D_MODEL, by itself, creates a new IMLOOK4D_MODEL or raises the existing
%      singleton*.
%
%      H = IMLOOK4D_MODEL returns the handle to a new IMLOOK4D_MODEL or the handle to
%      the existing singleton*.
%
%      IMLOOK4D_MODEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMLOOK4D_MODEL.M with the given input arguments.
%
%      IMLOOK4D_MODEL('Property','Value',...) creates a new IMLOOK4D_MODEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imlook4d_model_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imlook4d_model_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imlook4d_model

% Last Modified by GUIDE v2.5 17-Nov-2015 14:32:45

%
% Global constants
%
global TIMEFACTOR;  % multiply all times in imlook4d_model with TIMEFACTOR, to select display in seconds or minutes
TIMEFACTOR = 1;     % SECONDS
TIMEFACTOR = 1/60;  % MINUTES

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imlook4d_model_OpeningFcn, ...
                   'gui_OutputFcn',  @imlook4d_model_OutputFcn, ...
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

% --------------------------------------------------------------------
% imlook4d_model create functions
% --------------------------------------------------------------------

% --- Executes just before imlook4d_model is made visible.
function imlook4d_model_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imlook4d_model (see VARARGIN)

% Choose default command line output for imlook4d_model
    handles.output = hObject;

% Update handles structure
    guidata(hObject, handles);
    
    % Bail out if no arguments when calling imlook4d_model
    if nargin==3
        return
    end
    
% get data from workspace
    %ROI_data=evalin('base', 'imlook4d_ROI_data');
    try
    ROI_data=varargin{1};
    catch
        ROI_data=[];
    end
    
% set window title
    try
        set(handles.imlook4d_model,'Name', [ 'No model: ' ROI_data.window_title] );
    catch
        set(handles.imlook4d_model,'Name', [ 'No model: '] );
    end

% version text
    str =  fileread('version.txt');
    t=str2double( regexp(str,'\d+', 'match') ); % get all double values
    version = num2str( t(end) + 1);  
    set(handles.versionText,'String',['imlook4d_model(' version ') /Jan Axelsson ']) 

% make model object
try
    handles.model =  BasicTact( ROI_data);
catch
end
    guidata(hObject, handles);
    
% store original ROI-data
    handles.ROI_data = ROI_data;
    
% refRegionSelector
    set(handles.refRegionSelector,'String',ROI_data.names);
    
% modelSelector
    % filled in from modelSelector_CreateFcn
    handles.ROI_data.currentModel = 'No model';
    
% model cache
     % Create empty cache storage of models (so that it will remember state when
     % changing between models)
     strings = get(handles.modelSelector, 'String'); % Populated in modelSelector_CreateFcn 
     for i=1:length(strings)
         handles.modelCache{i} = {};
     end
     handles.modelCacheIndex = 1;
     handles.modelCache{handles.modelCacheIndex} = handles.model;  % Set to above defined model
    
% UIWAIT makes imlook4d_model wait for user response (see UIRESUME)
% uiwait(handles.imlook4d_model);

    guidata(hObject, handles);
    % update plot 
    update(handles);

return;

% --- Outputs from this function are returned to the command line.
function varargout = imlook4d_model_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function out = generateWindowTitle(handles)
    
    out = [ handles.ROI_data.currentModel  ': ' handles.ROI_data.window_title];

% --------------------------------------------------------------------
% GUI elements
% --------------------------------------------------------------------
function modelSelector_Callback(hObject, eventdata , handles)
% hObject    handle to modelSelector (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns modelSelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from modelSelector
    
    % Store model number
    selectedNumber = get(hObject,'Value');
    strings = get(hObject,'String');
    handles.ROI_data.currentModel = strings{selectedNumber};
    
    % Make model (or fetch from cache)
    if isempty( handles.modelCache{selectedNumber} )
        handles.modelCache{handles.modelCacheIndex} = handles.model;  % Cache current state
        eval([ 'handles.model = ' strings{selectedNumber} '( handles.ROI_data);']); % Create new model object
        handles.modelCacheIndex = selectedNumber;  % Store index of newly selected model object
    else
        handles.modelCache{handles.modelCacheIndex} = handles.model;  % Cache current state
        handles.model = handles.modelCache{selectedNumber}; % Retrieve cache from selected model
        handles.modelCacheIndex = selectedNumber;  % Store index of newly selected model
    end

    guidata(hObject, handles);

    % plot Workspace imlook4d_ROI_data    
    refRegionSelector_Callback(hObject, eventdata, handles)
    update(handles)
      
    
    % Change window title
   set(handles.imlook4d_model,'Name',  generateWindowTitle(handles) );
     
return
function modelSelector_CreateFcn(hObject, ~, ~)
% hObject    handle to modelSelector (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

    
% Populate models
     [pathstr1,name,ext] = fileparts(which('imlook4d'));
     
     [files dirs]=listDirectory([pathstr1 filesep 'MODELS' filesep 'imlook4d_model']);

     % Set items 
     counter = 0;
    % counter = counter + 1;
    % strings{counter}='No model';
     for i=1:length(files)
        [pathstr,name,ext] = fileparts(files{i});
        nameWithSpaces= regexprep(name,'_', ' ');  % Replace '_' with ' '

        % Setup submenu callback (for instance test_control)
        %handles.modelSelector = uimenu(handles.image.modelsMenuHandle,'Label',nameWithSpaces, 'Callback', [name '_control(gcbo)']);
        
        % Only get real directory names
        if ~any(strcmp(nameWithSpaces, {'', '.', '..'}))
            % Only .m files
            if strcmp(ext, '.m' )
                counter = counter + 1;
                strings{counter}=nameWithSpaces;
            end
        end
     end
     set(hObject,'String',strings);   

function refRegionSelector_Callback(hObject, ~, handles)        
    % Update plot
    update(handles)
function refRegionSelector_CreateFcn(hObject, ~, handles)
% hObject    handle to refRegionSelector (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function outputTextField_Callback(hObject, ~, handles)
% hObject    handle to outputTextField (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputTextField as text
%        str2double(get(hObject,'String')) returns contents of outputTextField as a double
return
function outputTextField_CreateFcn(hObject, ~, handles)
% hObject    handle to outputTextField (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    
% --------------------------------------------------------------------
% FILE menu 
% --------------------------------------------------------------------
function openTACT_Callback(hObject, eventdata, handles)
%      [file,path] = uigetfile( {...       
%                         '*.txt', 'imlook4d TABs (*.txt)'; ...
%                         '*.tac', 'Pmod (*.tac)'; ... 
%                          '*.xls', 'imlook4d (*.xls)'; ...
%                          '*.xlsx', 'imlook4d (*.xlsx)'; ...
%                         '*.sif', 'Turku (blood/weight)  (*.sif)' ...
%                         }, ... 
%                         'TACT-curve (Select type)', 'TACT.txt');%TS xlsx
     [file,path] = uigetfile( {... 
                        '*.txt;*.tac;', 'time-activity data'; ...
                        '*.txt', 'imlook4d TABs (*.txt)'; ...
                        '*.tac', 'Pmod (*.tac)'; ... 
                        }, ... 
                        'TACT-curve (Select type)');

        [pathstr,name,ext] = fileparts(file);  % To get extension 
        fullPath=[path file];     
        
        %
        % Load according to method
        %

        switch ext
            case {'.xls','.xlsx'} % imlook4d TS xls
                try  
                    %xlswrite(fullPath,A);
                catch
                   disp('ERROR -- try .txt option instead'); 
                end

            case '.txt' % imlook4d
                
                try
                    TAB=sprintf('\t');
                    
                    fid = fopen(fullPath);
                    headerLine = textscan(fid,'%s',1,'Delimiter','\n');
                    
                    % Create format
                    tabPositions = strfind(headerLine{1},TAB);
                    tabs =  length(tabPositions{1});
                    cols = tabs + 1;
                    format = repmat(['%f'],[1,cols]);
                    
                    % Read data
                    M = textscan(fid, format, 'Delimiter',TAB ,'headerLines', 1) % you will need to change the number   of values to match your file %f for numbers and %s for strings.
                    fclose (fid)
                    
                    % Create new imlook4d_model window
                    m = cell2mat(M);
                    
                    startMeanValues = 4;  %
                    numberOfRois = 0.5 * (cols - (startMeanValues - 1) );  % We have mean and stdev for each ROI
                    startStdValues = 4 + numberOfRois;  %
                    
                    headerCells = strsplit( char(headerLine{1}),TAB)';
                    tact.names = headerCells( startMeanValues:(startStdValues-1) )  ;
                    tact.midtime = m(:,2); % One column per ROI
                    tact.duration = m(:,3);
                    tact.mean = m(:, startMeanValues:(startStdValues-1) );  %
                    tact.stdev = m(:, startStdValues:end);
                    
                    tact.unit = '';
                    tact.window_title = file;
                    
                    imlook4d_model(tact);
                    
                catch
                    %disp('You selected not to save TACT curve');
                end


            case {'.tac'}
                %start[seconds]	end[kBq/cc]	Group	cer	striatum
                try
                    TAB=sprintf('\t');
                    
                    fid = fopen(fullPath);
                    headerLine = textscan(fid,'%s',1,'Delimiter','\n');
                    
                    % Create format
                    tabPositions = strfind(headerLine{1},TAB);
                    tabs =  length(tabPositions{1});
                    cols = tabs + 1;
                    format = repmat(['%f'],[1,cols]);
                    
                    % Read data
                    M = textscan(fid, format, 'Delimiter',TAB ,'headerLines', 1) % you will need to change the number   of values to match your file %f for numbers and %s for strings.
                    fclose (fid)
                    
                    % Get units
                    C = strsplit(headerLine{1,1}{1},{'[',']'});
                    unitString = strtrim( C{4} );
                    timeUnitString = strtrim( C{2} );
                    
                    % make Bq/cc
                    unitFactor = 1;
                    if strcmp( unitString, 'kBq/cc') % DICOM unit
                        unitString='Bq/cc'; 
                        unitFactor=1000; % Unit conversion factor kBq/cc -> BQML
                    end
                    
                    % make seconds
                    timeUnitFactor = 1;
                    timeUnitString = 'seconds';
                    if strcmp( timeUnitString, 'minutes') 
                        timeUnitFactor=60; % Unit conversion factor BQML->kBq/cc
                    end
                    
                    
                    m = cell2mat(M);
                    
                    startMeanValues = 3;  %
                    numberOfRois = (cols - (startMeanValues - 1) );  
                    %startStdValues = 4 + numberOfRois;  %
                    
                    headerCells = strsplit( char(headerLine{1}),TAB)';
                    tact.names = headerCells( startMeanValues:cols )  ;
                    tact.midtime = timeUnitFactor * (  m(:,1)  ); % In seconds, One column per ROI
                    endTime = timeUnitFactor * (  m(:,2)  );
                    tact.duration = endTime - tact.midtime;  
                    tact.mean = unitFactor * m(:, startMeanValues:cols );  %
                    %tact.stdev = m(:, startStdValues:end);
                    
                    tact.unit = unitString;
                    tact.window_title = file;
                    
                    % Create new imlook4d_model window
                    imlook4d_model(tact);
                    
                catch
                    %disp('You selected not to save TACT curve');
                end

            case {'.dft'}
                % Turku should go here

            case {'.sif'}
                % Turku sif file 

                % Simplified sif file, from one ROI

                % Header info
                scan_start_time = 'xx/xx/xxxx xx:xx:xx'
                number_of_frames = length(frameNumbers);
                number_of_columns = 2 + size(activity,2) ;
                SIF_version = '1';
                study_ID = 'xxxx';
                isotope = 'X-XX';


                if (  size(activity,2) == 1 )
                   activity = [ activity activity ];  % Sif seems to require 4 columns (minimum) 
                   number_of_columns = 2 + size(activity,2) ;
                end

                tactHeader=[sprintf(['%s' '\t'], scan_start_time, num2str(number_of_frames), num2str(number_of_columns), SIF_version, study_ID, isotope) ];
                tactHeader=tactHeader(1:end-1); % Remove last TAB

                unitFactor = 1; % Do nothing
                try

                    save_cellarray( num2cell([ timeScale (timeScale+duration) unitFactor*double(activity) ]), fullPath, tactHeader );
                catch
                    %disp('You selected not to save TACT curve');
                end                       



            otherwise
                warning('Unexpected file type. No file created.')
        end          
function saveTACT_Callback(hObject, eventdata, handles)


                roiNames = handles.model.getRoiNames(:);% One column per ROI
                timeScale = handles.model.getX(); % One column per ROI
                activity = handles.model.getY();  % One column per ROI
                stdev = handles.ROI_data.stdev;         % One column per ROI
                
                cols = size(activity,2);
                th = repmat( {'time'}, [1,cols]);  % Time column header. One column per ROI
                
                frameNumbers = (1:length(timeScale) )';
                duration = handles.model.getDuration() ;
                
                unitString = handles.model.TACT.unit;
                

                % Time into one column -- if applicable (same columns)
                oneTimeColumn = ( sum(sum( ~bsxfun(@eq,timeScale,timeScale(:,1)) )) == 0 ); % Compares columns
                if oneTimeColumn
                    timeScale = timeScale(:,1);
                    th = th(1); 
                end
                
                %
                % Open with applicable methods
                %
                if oneTimeColumn
                    [file,path] = uiputfile( {...       
                        '*.txt', 'imlook4d TABs (*.txt)'; ...
                        '*.tac', 'Pmod (*.tac)'; ... 
                         '*.xls', 'imlook4d (*.xls)'; ...
                         '*.xlsx', 'imlook4d (*.xlsx)'; ...
                        '*.sif', 'Turku (blood/weight)  (*.sif)' ...
                        }, ... 
                        'TACT-curve (Select type)', 'TACT.txt');
                else
                    % PMOD and SIF do not allow multiple time columns
                    [file,path] = uiputfile( {...
                        '*.txt', 'imlook4d TABs (*.txt)'; ...
                         '*.xls', 'imlook4d (*.xls)'; ...
                         '*.xlsx', 'imlook4d (*.xlsx)'; ...
                        }, ... 
                        'TACT-curve (Select type)', 'TACT.txt');
                end  

                [pathstr,name,ext] = fileparts(file);  % To get extension 
                fullPath=[path file];
                
                %
                % Save according to method
                %

                switch ext
                    case {'.xls','.xlsx'} 
                        tempHeader={'frame', th{:}, 'duration', roiNames{:} };
                        
                        % Add std columns, one per ROI
                        for i=1:length(roiNames)
                            tempHeader = [ tempHeader { ['std ' roiNames{i}] } ];
                        end
                        
                        A = [ tempHeader
                            num2cell([ frameNumbers timeScale duration double(activity) double(stdev)] ) ]
                        try  
                            xlswrite(fullPath,A);
                        catch
                           disp('ERROR -- try .txt option instead'); 
                        end

                        
                     case '.txt' % imlook4d
                        % If time scale (and not Logan etc)                
                        if oneTimeColumn
                            timeScale = (timeScale - 0.5*duration);
                        end
                         
                         
                        tempHeader={'frame', th{:}, 'duration', roiNames{:} };
                        tactHeader=[sprintf(['%s' '\t'], tempHeader{:})  sprintf(['std %s' '\t'], roiNames{:}  )];
                        %tactHeader=[sprintf(['%s' '\t'], tempHeader{:}) ];
                        tactHeader=tactHeader(1:end-1); % Remove last TAB
                        try
                            save_cellarray( num2cell([ frameNumbers timeScale duration double(activity) double(stdev)]), fullPath, tactHeader );
                        catch
                            %disp('You selected not to save TACT curve');
                        end
                        

                    case {'.tac'}
                        %start[seconds]	end[kBq/cc]	Group	cer	striatum
                        unitFactor=1;
                        

                        
                        if strcmp( unitString, 'BQML') % DICOM unit
                            unitString='kBq/cc'; 
                            unitFactor=1/1000; % Unit conversion factor BQML->kBq/cc
                        end
                        
                        tempHeader={'start[seconds]', ['end[' unitString ']'] , roiNames{:} };
                        tactHeader=[sprintf(['%s' '\t'], tempHeader{:}) ];
                        tactHeader=tactHeader(1:end-1); % Remove last TAB
                        try
                            save_cellarray( num2cell([ (timeScale - 0.5*duration) (timeScale + 0.5*duration) unitFactor*double(activity) ]), fullPath, tactHeader );
                        catch
                            %disp('You selected not to save TACT curve');
                        end

                        
                    case {'.dft'}
                        % Turku should go here

                        
                    case {'.sif'}
                        % Turku sif file 
                        
                        % Simplified sif file, from one ROI
                        
                        % Header info
                        scan_start_time = 'xx/xx/xxxx xx:xx:xx'
                        number_of_frames = length(frameNumbers);
                        number_of_columns = 2 + size(activity,2) ;
                        SIF_version = '1';
                        study_ID = 'xxxx';
                        isotope = 'X-XX';

                        
                        if (  size(activity,2) == 1 )
                           activity = [ activity activity ];  % Sif seems to require 4 columns (minimum) 
                           number_of_columns = 2 + size(activity,2) ;
                        end
                        
                        tactHeader=[sprintf(['%s' '\t'], scan_start_time, num2str(number_of_frames), num2str(number_of_columns), SIF_version, study_ID, isotope) ];
                        tactHeader=tactHeader(1:end-1); % Remove last TAB
                        
                        unitFactor = 1; % Do nothing
                        try

                            save_cellarray( num2cell([ timeScale (timeScale+duration) unitFactor*double(activity) ]), fullPath, tactHeader );
                        catch
                            %disp('You selected not to save TACT curve');
                        end                       
                        
                        

                    otherwise
                        warning('Unexpected file type. No file created.')
                end
function closeWindows_Callback(~, ~, handles)

        % Find figures
            h=findobj('Tag', 'imlook4d_model');

        % Create html-formatted list of windows
            [windowDescriptions h]= htmlWindowDescriptions(h);  % Sorted html list
        
        % Find index to current window
            thisWindow=1;
            for i=1:size(h)
                % Mark current window with a checkbox
                if (h(i) == handles.imlook4d_model)
                     thisWindow=i;
                end
            end
            
        % Display list
            [s,v] = listdlg('PromptString','Select windows to close:',...
                'SelectionMode','multiple',...
                'ListSize', [700 400], ...
                'ListString',windowDescriptions,...
                'InitialValue', thisWindow);
            

        % Close selected windows
            for i=1:size(s,2)
                close( h(s(i)) );
            end
    function [windowDescriptions, sortedListOfWindows ] = htmlWindowDescriptions( listOfWindows )
        % Create html-formatted list of windows
        % Input:    handles to all windows
        % Output:   cell array of html-strings, sorted according to
        % rules in end of this function
            %disp('ENTERED htmlWindowDescriptions');
            
            
            
                            TAB=' . .  ';
            
            %
            % Generate list
            %
                            
            for i=1:size(listOfWindows,1)
                figureName=get(listOfWindows(i),'Name');
                windowDescriptions{i}=figureName;
                
                % Guess
                table{i,1}=i;          % original index
                table{i,2}='';
                table{i,3}='';
                table{i,4}='';
                table{i,5}='';
 
                
                %
                % Fill in table, and generate html
                %
                if not( isempty( guidata(listOfWindows(i) ) ) ) 
                    
                    % Here we have gui applications (i.e. imlook4d)
                    tempHandles=guidata(listOfWindows(i));

                           temp=[ '<HTML>' ...
                                        '<FONT ' ' color="blue">'  '</FONT> '...
                                        '<FONT color="black">' figureName TAB '</FONT>' ...
                                        '</HTML>' ];                         
                        windowDescriptions{i}=strrep(temp,char(0),'');  
                else  
                        % Here we have non-gui applications (such as normal plot figures)
                end
            end
            
            %
            % Sort in a nice order
            %

                % Sort rows
                [table, index] = sortrows(table,[3,4,2,5]);

                % Set sorted handles
                sortedListOfWindows=listOfWindows(index);
                windowDescriptions=windowDescriptions(index);

% --------------------------------------------------------------------
% EDIT menu 
% --------------------------------------------------------------------
function windowTitle_Callback(~, ~, handles)
        ROI_data =  handles.ROI_data;
    
    
        % Input dialog texts     
        prompt={'New window title'};
        title='Edit window title'; 
        defaultanswer={ ROI_data.window_title };

    % Define size of text field
        numlines=1; 
        extraChars=12;  % Number of extra charactes that fit the dialog (over the current window title length)
        width=50;       % Default max length

        % Extend text field if needed
        if length(defaultanswer{1})>width
            width=length(defaultanswer{1});
        end
        numCols=width+extraChars;

    % Show dialog, and set window title    
        answer=inputdlg(prompt,title,[numlines  numCols ],defaultanswer);
        handles.ROI_data.window_title = answer{1};
        
    % Store modified data
        guidata(handles.imlook4d_model, handles);
        
    % Set window title
       set(handles.imlook4d_model,'Name',  generateWindowTitle(handles) );
function MatlabMenu_Callback(~, ~, handles)

            if  strcmp( get(handles.imlook4d_model, 'MenuBar') , 'none'  );
                set(handles.imlook4d_model, 'MenuBar', 'figure');
                set(handles.MatlabMenu, 'Checked', 'on');
            else
                set(handles.imlook4d_model, 'MenuBar', 'none');
                set(handles.MatlabMenu, 'Checked', 'off');
            end   
            
% --------------------------------------------------------------------
% CALLBACKS 
% --------------------------------------------------------------------
function inputTable_CellEditCallback(hObject, eventdata, handles) % inputTable edited
    index = eventdata.Indices;
    row = index(1);
    col = index(2);
    data = get(hObject,'Data');
    cellValue = data( row, col);
    handles.model.inputParameters( row ) = cellValue;
    update(handles);
function TransposeRadioButton_Callback(hObject, eventdata, handles) % outputTable transposed
update(handles)  
function OLDCalculatePushbutton_Callback(hObject, ~, handles)  % NOT USED
        
global Cref;
global dt;
global model;  % Type of model

    plotTACT(handles.tactAxes, handles.ROI_data.names, handles.ROI_data.midtime, handles.ROI_data.mean);  
    
    hold(handles.tactAxes,'on')
    % Test, multiple graphs:
    % handles.ROI_data.mean = handles.ROI_data.mean.*0.5;
    % plotTACT(handles.tactAxes, handles.ROI_data.names, handles.ROI_data.midtime, handles.ROI_data.mean);

%---  
model = 'Turku';

% Columns
ref = 3;  % ROI number for Cref
t = handles.ROI_data.midtime(1:end-1)' / 60;
dt = handles.ROI_data.duration(1:end-1)' / 60;
Cref = handles.ROI_data.mean(1:end-1,ref);
C = handles.ROI_data.mean(1:end-1,:);

    % Calculate model
%         xdata = handles.ROI_data.midtime' / 60;
%         ydata = handles.ROI_data.mean(:,2)';
        
        
        xdata = t;
        ydata = C(:,2);
        pguess = [0.8 , 0.2, 0.2/(1+3) ];
        
        % Statistical toolbox (lighter version)
        [p,R,J,CovB,MSE,ErrorModelInfo] = nlinfit(xdata', ydata, @SRTM_function, pguess)
        
        % Get parameters
         R1 = p(1)
         k2 = p(2)
         P0 = p(3)  % = k2/(1+BP)

         BP = (k2 / P0) - 1
%---    
        % Add fitted data
        plotTACT(handles.tactAxes, handles.ROI_data.names, handles.ROI_data.midtime, SRTM_function([R1 k2 P0 ] ,t) );
    
    hold(handles.tactAxes,'off')  
function CalculatePushbutton_Callback(hObject, ~, handles)
    update(handles);     
            
% --------------------------------------------------------------------
% UPDATE GRAPHS
% -------------------------------------------------------------------- 
function update(handles)
    obj = handles.model;
    
    %
    % Get ref region
    %
    selectedNumber = get(handles.refRegionSelector,'Value');
    try
        handles.model.setReferenceRegion(selectedNumber );

    catch
        disp('imlook4d_model/update -- ReferenceRegion not applicable');
    end
    
    %
    % Plots
    %
    plotTACT(handles, handles.tactAxes, handles.model); 
    hold(handles.tactAxes,'off')    
    plotResidual(handles.residualAxes, handles.model);
    
    %
    % Inputs
    %
  
        set(handles.inputTable, ...
            'ColumnEditable', [ false true], ...
            'Data', [obj.inputParameterNames(:) obj.inputParameters' obj.coefficientUnits'] ,...
            'ColumnName', { 'parameter', 'value', 'unit'}  ); 
                
        % Make empty table if no data
        if isempty( obj.inputParameters)
             set(handles.inputTable,  'Data', {} , 'ColumnName', {}, 'RowName', {} );
        end
    %
    % Results (Outputs)
    %

    try
        % Create the uitable
        if ( get(handles.TransposeRadioButton, 'Value') )
            set(handles.resultTable, ...
                'Data', obj.coefficients',...
                'ColumnName', obj.getRoiNames(:),...
                'RowName', obj.coefficientNames( 1 : size(obj.coefficients,2) ) );
        else        
            % Transposed
            set(handles.resultTable, ...
                'Data',  obj.coefficients ,...
                'ColumnName', obj.coefficientNames( 1 : size(obj.coefficients,2) ),...
                'RowName', obj.getRoiNames(:) );
        end
        
        % Make table empty if no data
        if isempty( obj.coefficients)
             set(handles.resultTable,  'Data', {} , 'ColumnName', {}, 'RowName', {} );
        end


    catch 
    end
    function plotTACT( handles, axes, tactObject )
        global TIMEFACTOR;
        %
        % Graphs
        % 
        hold(axes,'off')

        % plot 
        X = tactObject.getX() * TIMEFACTOR;
        Y = tactObject.getY();
 
        
        try
            % plot data points
            plot( axes, X   ,Y, '.');
            hold(axes,'on')
            children = get(axes, 'Children');
            
            % plot frame markers
            numberOfROIs = size(X,2);
            for i=1:numberOfROIs
                color = get( children( 1 + numberOfROIs - i),'Color');  % Get used colors (in reverse order)
                plot( axes,  X( tactObject.frameMarker{i}', i ) ,  Y( tactObject.frameMarker{i}', i ), 'MarkerEdgeColor', color, 'LineStyle','none','Marker' , 'o');
            end
            % plot fit
            Xfit = tactObject.getModelX();
            Yfit = tactObject.getModelY();
            plot( axes, Xfit , Yfit, '-');
        catch
           disp('imlook4d_model/plotTACT -- error updating fitted data ');
        end

        % legends
        legend( axes, tactObject.getRoiNames(:), 'Interpreter', 'none'); % Write legend without LaTex interpretation
        
        % labels
            set( handles.tactTitleText, 'String', tactObject.MainLabel);
            xlabel(axes, tactObject.XLabel);
            ylabel(axes, tactObject.YLabel, 'VerticalAlignment', 'middle');
    function plotResidual( axes, tactObject )
        global TIMEFACTOR;
        
        %
        % Residuals
        %
        
        hold(axes,'off')
        try
            plot( axes, tactObject.getX() * TIMEFACTOR  , tactObject.residual(), '.');
            xlabel(axes, tactObject.XLabel);
            
            % Plot horizontal zero line
            xlim = get(axes,'xlim');  %Get x range 
            hold on
            plot([xlim(1) xlim(2)],[0 0],'Color', [0.5, 0.5, 0.5])
        catch
            plot( axes, tactObject.getX()  * TIMEFACTOR  , 0 * tactObject.getX(), '.'); 
            disp('Residuals not applicable');
        end
