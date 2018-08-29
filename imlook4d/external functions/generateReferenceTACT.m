function [activity, NPixels, stdev, maxActivity]=generateReferenceTACT(handles)
    roisToCalculate = handles.model.common.ReferenceROINumbers;
    ROI = handles.image.ROI;
    
    tempROI = zeros( size(ROI));
    for i = roisToCalculate
        tempROI( ROI == i ) = 1;
    end
    
    if isempty(roisToCalculate)
       errordlg('No reference region defined'); 
       error('No reference region defined');
    end
    
    ROI(ROI>0) = 1;
    [activity, NPixels, stdev, maxActivity] = generateTACT( handles, tempROI, 1);