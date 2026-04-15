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

    % ROI extra size
    R=5;
    
    % Find center of current ROI
    ROI_data_to_workspace;
    
    dx = round( 0.5 * imlook4d_ROI_data.dimension{imlook4d_ROI_number}.x +R);
    dy = round( 0.5 * imlook4d_ROI_data.dimension{imlook4d_ROI_number}.y +R);
    dz = round( 0.5 * imlook4d_ROI_data.dimension{imlook4d_ROI_number}.z +R);
    
    x = round( imlook4d_ROI_data.centroid{imlook4d_ROI_number}.x);
    y = round( imlook4d_ROI_data.centroid{imlook4d_ROI_number}.y);
    z = round( imlook4d_ROI_data.centroid{imlook4d_ROI_number}.z);
    
    R2 = dx*dx + dy*dy + dz*dz; % For sphere equation
    
    % Add new ROI
    temp=get(imlook4d_current_handles.ROINumberMenu,'String');
    newROIName=[ 'Background' temp{imlook4d_ROI_number} ]
    newROINumber = MakeROI(newROIName);
    
    % Make matrix with locked pixels
    ROILock = zeros( size(imlook4d_ROI) ,'uint8');
    numberOfROIs = max( imlook4d_ROI(:));
    for i=1:numberOfROIs
        ROILock(imlook4d_ROI == i ) =  imlook4d_current_handles.image.LockedROIs(i) ; % Set to 1 if Locked ROI
    end

    
    % Draw ROI
    for i=-dx:dx
        for j=-dy:dy
            for k=-dz:dz
                if ( ( i*i/dx^2 +j*j/dy^2 +k*k/dz^2 ) <= 1 ) ...
                        & ( imlook4d_ROI(x+i,y+j,z+k) ~= imlook4d_ROI_number ) ...
                        & ROILock(x+i,y+j,z+k) == 0 
                        imlook4d_ROI(x+i,y+j,z+k) = newROINumber;
                end
            end
        end
    end
    
    % 
    guidata(imlook4d_current_handle,imlook4d_current_handles);
 
 
EndScript

