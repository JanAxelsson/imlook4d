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

% Add 'ref' to ROIName
REFLABEL = '* ';
temp = imlook4d_ROINames;
for i = 1 : ( length(temp)-1 )
    if startsWith(temp{i},REFLABEL)
        temp{i} = temp{i}( length(REFLABEL)+1 : end);
        disp( ['Clear ' temp{i} ]);
    end
end
for i = s
    temp{i} = [ REFLABEL temp{i}];
    disp( ['Set ' temp{i} ]);
end

imlook4d_current_handles.model.common.ReferenceROINumbers = s;

imlook4d_ROINames = temp;

Import;
ClearVariables;