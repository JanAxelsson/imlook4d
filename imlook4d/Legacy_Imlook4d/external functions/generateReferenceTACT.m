function [activity, NPixels, stdev, maxActivity]=generateReferenceTACT(handles)
    try
        roisToCalculate = handles.model.common.ReferenceROINumbers;
    catch
        handles.model.common.ReferenceROINumbers = []; % Was not defined, lets make an empty one
        roisToCalculate = [];
    end
    
    % Make ROI containing only reference ROI
    ROI = handles.image.ROI;
    tempROI = zeros( size(ROI),'uint8');
    for i = roisToCalculate
        tempROI( ROI == i ) = 1;
    end
    
    if isempty(roisToCalculate)
%        errordlg({'No reference region defined.', ...
%            'Please Select Reference Region from ', ...
%            ' SCRIPTS/Models on ROIs/Select Reference ROIs'} );
       
       disp('No reference region defined'); 
       disp('Please Select Reference Region from ');
       disp(' SCRIPTS/Models on ROIs/Select Reference ROIs');
    end

    
    % Stop generateTACT from calling imlook4d/generateImage with model function
    handles.model.functionHandle = []; 
    
    % Calculate PCA-filtered TACT
    [activity, NPixels, stdev, maxActivity] = generateTACT( handles, tempROI, 1);