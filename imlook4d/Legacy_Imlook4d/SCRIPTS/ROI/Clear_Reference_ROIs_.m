StoreVariables;
ExportUntouched;

try
    s = imlook4d_current_handles.model.common.ReferenceROINumbers;
catch
    s = imlook4d_ROI_number;
end


% Remove 'ref' from ROIName
REFLABEL = '* ';
temp = imlook4d_ROINames;
for i = 1 : ( length(temp)-1 )
    if startsWith(temp{i},REFLABEL)
        temp{i} = temp{i}( length(REFLABEL)+1 : end);
        disp( ['Clear ' temp{i} ]);
    end
end


imlook4d_current_handles.model.common.ReferenceROINumbers = [];

imlook4d_ROINames = temp;

ImportUntouched;
ClearVariables;