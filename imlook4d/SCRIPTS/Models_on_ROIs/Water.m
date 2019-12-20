StoreVariables;

% Inhibit model image (which is triggered by existence of functionHandle)
keepFunctionHandle = imlook4d_current_handles.model.functionHandle;
imlook4d_current_handles.model.functionHandle = [];
guidata( imlook4d_current_handle, imlook4d_current_handles);


Export;

model_name = 'Water';
ref_name = imlook4d_ROINames{imlook4d_ROI_number};

disp('Calculating time-activity curves ...');
tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs
tact = tacts;  % all ROIs


%
% Dialog
%

prompt={'Input Function variable-name (time points should be same as frame times)' };
[answer, imlook4d_current_handles] = ModelDialog( imlook4d_current_handles, ...
    model_name, ...
    prompt, ...
    {  'Cinp' } ...
    );

Cinp_variableName = answer{1};

Cinp_for_this_script = eval( Cinp_variableName );  
Cinp_for_this_script = Cinp_for_this_script(:)'; % Allow both column and row vectors (make a row vector)

%
% Model
%
size( Cinp_for_this_script)

disp('Calculating model ...');
a = jjwater( tact, imlook4d_time/60, imlook4d_duration/60, Cinp_for_this_script); 

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
    [model_name ' (Cinp = ' Cinp_variableName ')' ] ...
    );

disp('Done!');

ClearVariables;
