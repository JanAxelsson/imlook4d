function [activity, NPixels, stdev, maxActivity]=generateReferenceTACT(handles)
    try
        roisToCalculate = handles.model.common.ReferenceROINumbers;
    catch
        handles.model.common.ReferenceROINumbers = []; % Was not defined, lets make an empty one
        roisToCalculate = [];
    end
    
    ROI = handles.image.ROI;
    
    tempROI = zeros( size(ROI));
    for i = roisToCalculate
        tempROI( ROI == i ) = 1;
    end
    
    if isempty(roisToCalculate)
       errordlg({'No reference region defined.', ...
           'Please Select Reference Region from ', ...
           ' SCRIPTS/Models on ROIs/Select Reference ROIs'} );
       
       error('No reference region defined'); 
    end
    
    ROI(ROI>0) = 1;
    [activity, NPixels, stdev, maxActivity] = generateTACT( handles, tempROI, 1);