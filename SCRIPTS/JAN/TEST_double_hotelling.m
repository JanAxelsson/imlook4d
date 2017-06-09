
% One slice

% Export filtered
imlook4d('exportAsViewedToWorkspace_Callback', imlook4d_current_handles.exportAsViewedToWorkspace,{} ,imlook4d_current_handles)
F=imlook4d_Cdata;

% Export original
imlook4d('exportToWorkspace_Callback', imlook4d_current_handles.exportToWorkspace,{} ,imlook4d_current_handles)
O=imlook4d_Cdata;

% Calc residual 
% (which has a histogram being more symmetric original distribution)
slice=imlook4d_slice;
frame=imlook4d_frame;
x=O(:,:,slice,:);
y=F(:,:,slice,:);
R=F-O;
imlook4d(R);
WindowTitle('Residual');


%
% Single-Hotelling
%

    % PCA-filter the residual
    handles=imlook4d_current_handles;
      [RF, explainedFraction, fullEigenValues,fullEigenVectors,PCMatrix]= ...
                                    PCAFilter(R(:,:,slice,:),...
                                    1,...
                                    5);

    % Analyze Single-Hotelling
    x=O(:,:,slice,frame);
    difference=RF(:,:,1,frame)-O(:,:,slice,frame);

    h=figure;scatter(x(:),difference(:)./x(:),'.')
    line([min(x(:)) max(x(:))],[0 0],'LineStyle','-');  % Line at y=0
    xlabel('pixel values');
    ylabel('% diff');

    WindowTitle('%diff Single-Hotelling');

%
% Double-Hotelling
%

    % Create a new image using the residual
    newImage=O(:,:,slice,:)+RF;
    imlook4d(newImage);
    WindowTitle('Double-Hotelling');

    % Analyze Double-Hotelling
    x=O(:,:,slice,frame);
    difference=newImage(:,:,1,frame)-O(:,:,slice,frame);

    h=figure;scatter(x(:),difference(:)./x(:),'.')
    line([min(x(:)) max(x(:))],[0 0],'LineStyle','-');  % Line at y=0
    xlabel('pixel values');
    ylabel('% diff');

    WindowTitle('%diff Double-Hotelling');

