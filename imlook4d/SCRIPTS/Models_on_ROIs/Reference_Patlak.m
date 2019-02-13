StoreVariables;
ReferenceModel; % Makes sure Reference Region is defined

% Inhibit model image (which is triggered by existence of functionHandle)
keepFunctionHandle = imlook4d_current_handles.model.functionHandle;
imlook4d_current_handles.model.functionHandle = [];
guidata( imlook4d_current_handle, imlook4d_current_handles);


Export;

model_name = 'Patlak_ref';
ref_name = imlook4d_ROINames{imlook4d_ROI_number};

disp('Calculating time-activity curves ...');
tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs
tact = tacts;  % all ROIs


%
% Dialog
%

prompt={'Start Frame ', 'Last Frame '};
[answer, imlook4d_current_handles] = ModelDialog( imlook4d_current_handles, ...
    model_name, ...
    prompt, ...
    { num2str(imlook4d_frame), num2str( size(imlook4d_Cdata,4) )} ...
    );

startFrame = str2num( answer{1});
endFrame = str2num( answer{2});
range = [startFrame endFrame];

%Cinp_for_this_script = tacts(imlook4d_ROI_number,:); % Input function in current ROI
Cinp_for_this_script = generateReferenceTACT( imlook4d_current_handles);

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
    [model_name ' (Ref=' ref_name ',  First frame = '  num2str(imlook4d_frame) ')' ] ...
    );

disp('Done!');

ClearVariables;
