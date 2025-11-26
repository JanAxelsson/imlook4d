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
%   h=imlook4d 
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


function varargout = imlook4d(varargin)

   
   % [    ] Old callback format : imlook4d('LoadRoiPushbutton_Callback', imlook4d_current_handles.LoadROI,{} ,imlook4d_current_handles, filePath)
   % try            
            % Has characters in first argument
            if nargin && ischar(varargin{1}) 

               [pathstr,name,ext] = fileparts(varargin{1});  % 
               % Open old callback format 
               if ~exist(pathstr,'dir') % Not an existing file path (thus, must be other option which is a function name)

                    % TODO: Write code for a callback
                    app = evalin('base', 'app'); % Get from 'app' in 'base' workspace -- which should have been exported
                    callbackName = varargin{1}; 
                    disp( [ 'imlook4d  -- callbackName = ' callbackName ]);
                    disp( [ 'imlook4d  -- size(varargin{4}.image.Cdata) = ' num2str( size(varargin{4}.image.Cdata)) ]);
                    app.callOldCallback(callbackName, varargin{2:end})
                    disp('Leave imlook4d -- handle old callback format')
                    return
               end
            end
   % catch
   %     disp('ERROR IN imlook4d function')
   % end


    % Has input arguments
    % [ OK ] imlook4d('/Users/jan/Desktop/IMAGES/ATTR/PETMR-2024-102 (2024-OCT-03) - 250846/[MR] Ax FIESTA ungated - serie7/6')
    % [ OK ] imlook4d( imlook4d_Cdata)
    % [ OK ] imlook4d( imlook4d_Cdata, imlook4d_time, imlook4d_duration) 
    if ~nargout
        imlook4d_App(varargin{:});
        disp(['Leave imlook4d -- called with one or several arguments'])
        return
    end

    % [    ] h = imlook4d('/Users/jan/Desktop/IMAGES/ATTR/PETMR-2024-102 (2024-OCT-03) - 250846/[MR] Ax FIESTA ungated - serie7/6')
    if nargout
         [varargout{1:nargout}] = imlook4d_App( varargin{:});   % TODO: imlook4d_App returns app, not handle / handles.  handles.image is lost in app !
    end


    % [ OK ] imlook4d
    % [ OK ] imlook4d()
    if isempty(varargin)
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