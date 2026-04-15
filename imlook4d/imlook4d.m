%
% imlook4d 
%
% Author:   Jan Axelsson
%
% Purpose:  Used for display and ROI-analysis of 4D images.
%
% EXAMPLE USE
% --------------------------------------------------------------------
% OPEN FILE DIALOG
%   imlook4d   
%   h=imlook4d (returns an old fashioned guide-like handle)  NOTE:imlook4d_App returns an app object instead
%
% OPEN A MATRIX
%   imlook4d(matrix)
%   imlook4d(matrix, time_vector, duration_vector)  % time points and duration
%
% OPEN FILES 
%   DICOM: Open all files in same directory as selected file
%   imlook4d(path_to_one_file_in_directory) 
%
%   ECAT, SHR, Analyze, Interfile, ITK, binary single files: 
%   imlook4d(path_to_file) 
%

%
% This is a wrapper to imlook4d_App, so the imlook4d program can be started
% the same way as before migration away from guide-based GUI
%
% It will call imlook4d_App to start GUI app
%
% It will emulate directly calling old callbacks as used in scripts, in the form 
%    imlook4d('exportAsViewedToWorkspace_Callback', imlook4d_current_handle, {}, guidata(imlook4d_current_handle) );
%
% 
% This script also has an additional function:
%    It will change path to the legacy guide-based imlook4d, if Matlab
%    version is too old.
%    This happens once per Matlab session.


function out = imlook4d(varargin)


        disp('Calling imlook4d wrapper');
        disp(varargin);
    
    %
    % Set Legacy imlook4d if Matlab too old
    %

        % Configures paths only once per MATLAB session using root appdata
    
        % Read session flags
        configured  = getappdata(0, 'imlook4d_path_configured');
        selected    = getappdata(0, 'imlook4d_selected_version');
    
        % Only first time running imlook4d each session
        if isempty(configured) || ~configured
    
            rootDir     = fileparts(mfilename('fullpath'));     % Folder of this script
            legacyPath  = fullfile(rootDir, 'Legacy_Imlook4d'); % Path to legacy imlook4d
    
            % Decide version and set paths
            matlabIsOld = verLessThan('matlab', '24');  % adjust cutoff to your actual requirement
    
            % Always start with new imlook4d -- remove legacy
            rmpath(genpath(legacyPath));

            % TEST -- force legacy.  Run this from cli first : setappdata(0, 'imlook4d_path_configured', false);
            %matlabIsOld = true; 
    
            if matlabIsOld
                % Use LEGACY → add legacy path on top
                addpath(genpath(legacyPath), '-begin');
                selected = "legacy";
            else
                % Use NEW → keep legacy off the path
                selected = "new";
            end
    
            % Save session flags
            setappdata(0, 'imlook4d_path_configured', true);
            setappdata(0, 'imlook4d_selected_version', selected);
    
            % Launch based on stored selection
            switch string(selected)
                case "legacy"
                    % Run the legacy entrypoint explicitly from its folder
                    disp('--------------------------------------');
                    disp('Running legacy imlook4d from now on')
                    which imlook4d
                    disp('--------------------------------------');
                    imlook4d; % Repeat call to this function to legacy imlook4d (which is now in path)
                    return
                case "new"
                    % Run the new App Designer app (just keep going in script below)
                    disp('--------------------------------------');
                    disp('Running modern imlook4d from now on')
                    which imlook4d
                    disp('--------------------------------------');
                    % continue running this script
                otherwise
                    error('imlook4d: Unknown version selection in session state.');
            end
        end
    
    

    %
    % The new imlook4d script
    %
    
       % Run if-statements to identify case, in this order :
       % 1) first argument = non-path string
       % 2) forward all arguments
       % 3) forward all arguments + return handle to figure
       % 4) no arguments
    
       % 1) first argument = non-path string
       %
       % [    ] Old callback format starting with non-path string : imlook4d('LoadRoiPushbutton_Callback', imlook4d_current_handles.LoadROI, {} ,imlook4d_current_handles, filePath)
       % [    ] Old callback format with
       try            
                % Has characters in first argument
                if nargin && ischar(varargin{1}) 
    
                   [pathstr,name,ext] = fileparts(varargin{1});  % 
                   % If string is not a path -- Open old callback format 
                   if ~exist(pathstr,'dir') % Not an existing file path (thus, must be other option which is a function name)
    
                        % TODO: Write code for a callback
                        %%app = evalin('base', 'imlook4d_app'); % Get from 'app' in 'base' workspace -- which should have been exported
    
    
                        disp('   1) first argument = non-path string');
                        
                        callbackName = varargin{1}; 
    
                        % Handles at different positions, use figure1 field to determine if handles structure
                        if isfield( varargin{2}, 'figure1')
                            handles = varargin{2};
                        elseif isfield( varargin{4}, 'figure1')
                            handles = varargin{4};
                        end
    
                        app = handles.figure1.UserData.app;
                        %app.callOldCallback(callbackName, varargin{2:end});  % I need app instance here, to call private function callOldCallback
                  
                        newVarargin = varargin(2:end);
                        out = app.callOldCallback(callbackName, newVarargin{:});  % I need app instance here, to call private function callOldCallback
                  
                        return
                   end
                end
       catch
           disp('   ERROR IN imlook4d wrapper -- handling "1) first argument = non-path string"');
           if (nargin < 4)
                disp(['   Expected 4 arguments, received ' num2str(nargin) ' arguments']);
           end
           disp(' '); % New row
           return
    
       end
       
    
    
        % 2) forward all arguments
        %
        % [ OK ] Starts with path:          imlook4d('/Users/jan/Desktop/IMAGES/ATTR/PETMR-2024-102 (2024-OCT-03) - 250846/[MR] Ax FIESTA ungated - serie7/6')
        % [ OK ] Data matrix  :             imlook4d( imlook4d_Cdata)
        % [ OK ] Data matrix + time info :  imlook4d( imlook4d_Cdata, imlook4d_time, imlook4d_duration) 
        if ~nargout
    
            disp('   2) forward all arguments');
    
            imlook4d_App(varargin{:});
            disp(['Leave imlook4d -- called with one or several arguments'])
            return
        end
    
        % 3) forward all arguments + return handle to figure
        %
        %  [    ] Return handle to figure (and forward input arguments) : h = imlook4d('/Users/jan/Desktop/IMAGES/ATTR/PETMR-2024-102 (2024-OCT-03) - 250846/[MR] Ax FIESTA ungated - serie7/6')
        if nargout
             disp('   3) forward all arguments + return handle to figure');
             [varargout{1:nargout}] = imlook4d_App( varargin{:});   % TODO: imlook4d_App returns app, not handle / handles.  handles.image is lost in app !
             out = gcf;
        end
    
    
        % 4) no arguments
        %
        % [ OK ] imlook4d
        % [ OK ] imlook4d()
        if isempty(varargin)
            disp('   4) no arguments');
            imlook4d_App
            disp('Leave imlook4d -- called with zero arguments')
            return
        end
            
    
    end
    
    % [ OK ] imlook4d
    % [ OK ] imlook4d('/Users/jan/Desktop/IMAGES/ATTR/PETMR-2024-102 (2024-OCT-03) - 250846/[MR] Ax FIESTA ungated - serie7/6')
    % [    ] h = imlook4d('/Users/jan/Desktop/IMAGES/ATTR/PETMR-2024-102 (2024-OCT-03) - 250846/[MR] Ax FIESTA ungated - serie7/6')
    % [    ] imlook4d(imlook4d_Cdata) % Matrix, after Export performed
    %