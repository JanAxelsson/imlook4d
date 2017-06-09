function No_Model_control(varargin)
%
%  This model removes the handle to the selected model function
%  so that no model is used in generateImage
%

   disp('Entered No_Model_control');
   
    %
    % INITIALIZATION of important communication between imlook4d and 
    %
        % Save link back to calling imlook4d instance
        handles.imlook4d_handle=varargin{1};                    % Handle to imlook4d instance
        imlook4d_handles=guidata(handles.imlook4d_handle);      % Handles to calling imlook4d instance (COPY OF HANDLES)

   
    %
    % USER INITIALIZATION  ( CHANGE THIS ONE )         
    %   
        imlook4d_handles.model.functionHandle=[];
    %
    % FINISH
    %
        guidata(handles.imlook4d_handle,imlook4d_handles); % Export modified handles back to imlook4d
        
        % Update imlook4d image
        imlook4d('updateImage',handles.imlook4d_handle, [], imlook4d_handles);
