StoreVariables;
Export;

model_name = 'Zhou';

%
% Dialog
%
prompt={'Start Frame ',...
    'Last Frame ',...
    'k2'};
title=[ model_name ' inputs'];
numlines=1;

defaultanswer = RetriveEarlierValues('Zhou', { num2str(imlook4d_frame), num2str( size(imlook4d_Cdata,4) ), ''}  );  % Read default if exists, or apply these as default
answer=inputdlg(prompt,title,numlines,defaultanswer);

startFrame = str2num( answer{1});
endFrame = str2num( answer{2});
[k2ref, k2ref_existing] = str2num(answer{3} );

StoreValues('Zhou', answer); % Store answer as new dialog default


%
% Model
%
disp('Calculating time-activity curves ...');
tacts = generateTACT(imlook4d_current_handles,imlook4d_ROI);  % ROIs

ref = generateReferenceTACT( imlook4d_current_handles)
tact = tacts;  % all ROIs


disp('Calculating model ...');
a = jjzhou( tact, imlook4d_time/60, imlook4d_duration/60, ref, [ startFrame endFrame]); % Fit to end frame

% Get Zhou Logan-like axes for reference tissue
r = jjlogan( ref, imlook4d_time/60, imlook4d_duration/60, ref, [ startFrame endFrame]);
a.Yref = r.Y{1};
a.Xref = r.X{1};

% Display
modelWindow( ...
    a , ...
    imlook4d_ROINames(1:end-1), ...
    [model_name ' (First frame = '  num2str(startFrame) ')'] ...
    );

disp('Done!');

ClearVariables;