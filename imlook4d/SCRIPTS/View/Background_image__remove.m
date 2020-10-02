StoreVariables
Export
%imlook4d_current_handles.image.backgroundImageHandle=SelectWindow({'Select template image (from imlook4d/Windows menu)', ...
%                '(image that we want slices to match'});
imlook4d_current_handles.image.backgroundImageHandle = [];
imlook4d_current_handles.image.CachedImage2 = [];
Import


% Show transparancy setting
imlook4d_current_handles.transparancyEdit.Visible = 'off';
imlook4d_current_handles.transparancyText.Visible = 'off';
imlook4d_current_handles.transparancyPanel.Visible = 'off'; 

% Finish
ClearVariables

clear imlook4d_current_handles.image.backgroundImageHandle