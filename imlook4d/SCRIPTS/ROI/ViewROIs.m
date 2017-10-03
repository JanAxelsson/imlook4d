% ViewROIs.m
%
% SCRIPT for imlook4d to view ROI pixels
%
%
% Jan Axelsson

StartScript

imlook4d_Cdata = single(imlook4d_current_handles.image.ROI);
imlook4d_current_handles.image.modality = 'OT';
WindowTitle('ROIs','prepend')

% Turn off all interpolations
set(imlook4d_current_handles.interpolate2,'Checked','off');
set(imlook4d_current_handles.interpolate4,'Checked','off');

% Hide ROI overlay
set(imlook4d_current_handles.hideROIcheckbox,'Value',1);

EndScript
