% Make_background_ROI.m
%
% SCRIPT for imlook4d to create a background ROI around an existing ROI
%
%
% Strategy:  Reuse current ROI and make circle around center
%
%
% Jan Axelsson

% INITIALIZE

StartScript;

    % ROI size
    R=5;
    dx=R;
    dy=R;
    dz=0;
    
    % Find center of current ROI
    ROI_data_to_workspace;
    x=imlook4d_ROI_data.centroid{imlook4d_slice,imlook4d_frame}.x;
    y=imlook4d_ROI_data.centroid{imlook4d_slice,imlook4d_frame}.y;
    z=imlook4d_ROI_data.centroid{imlook4d_slice,imlook4d_frame}.z;
    
    % Add new ROI
    temp=get(imlook4d_current_handles.ROINumberMenu,'String');
    newROIName=[ 'Background' temp{imlook4d_ROI_number} ]
    newROINumber=MakeROI(newROIName);

    
    % Draw ROI
    for i=-dx:dx
        for j=-dy:dy
            for k=-dz:dz
                if ( imlook4d_ROI(x+i,y+j,z+k)~=imlook4d_ROI_number )
                    imlook4d_ROI(x+i,y+j,z+k)=newROINumber;
                end
            end
        end
    end
    
    % 
    guidata(imlook4d_current_handle,imlook4d_current_handles);
 
 
EndScript

