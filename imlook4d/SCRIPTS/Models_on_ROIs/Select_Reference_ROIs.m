StoreVariables;
Export;

try
    s = imlook4d_current_handles.model.common.ReferenceROINumbers;
catch
    s = imlook4d_ROI_number;
end

if length(imlook4d_ROINames) > 1
    % Display list
    [s,ok] = listdlg('PromptString','Select one or many ROIs as Reference Region',...
        'SelectionMode','multiple',...
        'ListSize', [700 400], ...
        'ListString',imlook4d_ROINames(1:end-1),...
        'InitialValue', s );
    
    % Bail out if cancelled dialog
    if ~ok
        return
    end
else
    dispRed('Define one or more ROIs, and run this command again')
    return
end

imlook4d_current_handles.model.common.ReferenceROINumbers = s;

Import;
ClearVariables;