StoreVariables;

% Inhibit model image (which is triggered by existence of functionHandle)
keepFunctionHandle = imlook4d_current_handles.model.functionHandle;
imlook4d_current_handles.model.functionHandle = [];
guidata( imlook4d_current_handle, imlook4d_current_handles);


Export;

model_name = 'Patlak';
ref_name = imlook4d_ROINames{imlook4d_ROI_number};

disp('Calculating time-activity curves ...');
tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs
tact = tacts;  % all ROIs


%
% Dialog
%

prompt={'Start Frame ', 'Last Frame ', 'Input Function variable-name (time points should be same as frame times)' };
[answer, imlook4d_current_handles] = ModelDialog( imlook4d_current_handles, ...
    model_name, ...
    prompt, ...
    { num2str(imlook4d_frame), num2str( size(imlook4d_Cdata,4) ), '' } ...
    );

startFrame = str2num( answer{1});
endFrame = str2num( answer{2});
Cinp_variableName = answer{3};

range = [startFrame endFrame];
Cinp_for_this_script = eval( Cinp_variableName );  
Cinp_for_this_script = Cinp_for_this_script(:)'; % Allow both column and row vectors (make a row vector)

%
% Model
%
size( Cinp_for_this_script)

disp('Calculating model ...');
a = jjpatlak( tact, imlook4d_time/60, imlook4d_duration/60, Cinp_for_this_script, range); % Fit to end frame

% Get Patlak axes for reference tissue
% r = jjpatlak( Cinp, imlook4d_time/60, imlook4d_duration/60, Cinp, range);
% 
% 
% a.Yref = r.Y{1};
% a.Xref = r.X{1};

% Display
modelWindow( ...
    a , ...
    imlook4d_ROINames(1:end-1), ...
    [model_name ' (Cinp = ' Cinp_variableName ',  (Frames = '  num2str(startFrame) ' - ' num2str(endFrame) ')' ] ...
    );

disp('Done!');

ClearVariables;
