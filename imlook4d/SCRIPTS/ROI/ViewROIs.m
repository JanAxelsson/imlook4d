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

EndScript
