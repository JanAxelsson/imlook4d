
% Export PCA-filtered
imlook4d('exportAsViewedToWorkspace_Callback', imlook4d_current_handles.exportAsViewedToWorkspace,{} ,imlook4d_current_handles)
F=imlook4d_Cdata;

% Export original
imlook4d('exportToWorkspace_Callback', imlook4d_current_handles.exportToWorkspace,{} ,imlook4d_current_handles)
O=imlook4d_Cdata;

% Calc residual 
% (which has a histogram being more symmetric original distribution)
slice=imlook4d_slice;
frame=imlook4d_frame;


%
% PCA-filter the residual
%
    R=O-F;  % Residual
    RF=zeros(size(imlook4d_Cdata));
    
    %for i=1:size(imlook4d_Cdata,3)
    for i=slice
        disp(i);
        handles=imlook4d_current_handles;
        [RF(:,:,i,:), explainedFraction, fullEigenValues,fullEigenVectors,PCMatrix]= ...
                                        PCAFilter(R(:,:,i,:),...
                                        1,...
                                        3);
    end    
    newImage=O-RF;  % New Image
    newImage=F+RF;  % New Image
    
    imlook4d(newImage);
    WindowTitle('Double-Hotelling');

%
% ANALYZE
%
    % Analyze Single-Hotelling
    x=O(:,:,slice,frame);
    difference=F(:,:,slice,frame)-O(:,:,slice,frame);

    h=figure;scatter(x(:),difference(:),'.')
    line([min(x(:)) max(x(:))],[0 0],'LineStyle','-');  % Line at y=0
    xlabel('pixel values');
    ylabel('% diff');
    WindowTitle('%diff Single-Hotelling');
    
    % Analyze Double-Hotelling
    x=O(:,:,slice,frame);
    difference=newImage(:,:,slice,frame)-O(:,:,slice,frame);

    h=figure;scatter(x(:),difference(:),'.')
    line([min(x(:)) max(x(:))],[0 0],'LineStyle','-');  % Line at y=0
    xlabel('pixel values');
    ylabel('% diff');
    WindowTitle('%diff Double-Hotelling');

