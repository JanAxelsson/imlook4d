% ViewROIs.m
%
% SCRIPT for imlook4d to view ROI pixels
%
%
% Jan Axelsson

% INITIALIZE
StoreVariables

tempHandle=imlook4d( single(imlook4d_current_handles.image.ROI) );
tempHandles=guidata(tempHandle);

set( tempHandles.figure1, 'Name', [ 'ROIs: ' get(imlook4d_current_handles.figure1, 'Name') ]);

%clear tempHandle tempHandles
ClearVariables