
% Export filtered
imlook4d('exportAsViewedToWorkspace_Callback', imlook4d_current_handles.exportAsViewedToWorkspace,{} ,imlook4d_current_handles)
filtered=imlook4d_Cdata;

% Export original
imlook4d('exportToWorkspace_Callback', imlook4d_current_handles.exportToWorkspace,{} ,imlook4d_current_handles)
untouched=imlook4d_Cdata;


slice=imlook4d_slice;
frame=imlook4d_frame;


% Calculate average and diff
average=(untouched(1:size(untouched,1),1:size(untouched,2),slice,frame)+...
    filtered(1:size(untouched,1),1:size(untouched,2),slice,frame) )/2;
average=average(:);

difference=untouched(1:size(untouched,1),1:size(untouched,2),slice,frame)-...
    filtered(1:size(untouched,1),1:size(untouched,2),slice,frame);
difference=difference(:);


% Plot untouched vs filtered
x=untouched(1:size(untouched,1),1:size(untouched,2),slice,frame);
x=x(:);
y=filtered(1:size(untouched,1),1:size(untouched,2),slice,frame);
y=y(:);

h=figure;scatter(x,y','.');
title 'untouched vs filtered'
xlabel 'original'
ylabel 'filtered'
set(h,'Name','untouched vs filtered')


% Altman plot
h=figure;scatter(average,difference','.')

stdev=std(difference)
title 'Altman plot'
%xlabel 'average (filtered + orginal)/2'
xlabel 'orginal'
ylabel 'difference (filtered - orginal)'
set(h,'Name','Altman plot')