% ROI_to_brush.m
%
% SCRIPT for imlook4d to make brush size of current ROI
%
%
% Jan Axelsson

%
% INITIALIZE
%
    StoreVariables  % Remember variables
    Export
    ROI_data_to_workspace;
    
%
% Calculate
%     
    tempROIOneSlice=imlook4d_ROI(:,:,imlook4d_slice);  
    Xmin=min(find(sum( tempROIOneSlice== imlook4d_ROI_number,2))); 
    Ymin=min(find(sum(tempROIOneSlice== imlook4d_ROI_number,1)));  
    Xmax=max(find(sum( tempROIOneSlice== imlook4d_ROI_number ,2))); 
    Ymax=max(find(sum(tempROIOneSlice== imlook4d_ROI_number,1))); 
    
    imlook4d_current_handles.image.brush=imlook4d_ROI( Xmin:Xmax, Ymin:Ymax, imlook4d_slice);
        
    

    
    
%
% Finalize
% 
Import
ClearVariables  % Clear remembered variables