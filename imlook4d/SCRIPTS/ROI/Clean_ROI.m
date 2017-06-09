
% Initialize
    StartScript
    
  
    
    
fsize=8;

% Flat Filter kernel
h=ones(fsize);
h=h/sum(h(:));  % Normalize to sum 1

bROI = (imlook4d_ROI == imlook4d_frame);
bROIout = false( size(bROI));  % Preallocate logical matrix

% Loop slices
for i=1:size(bROI,3)
 disp(i)

 % Remove narrow features
    X = bROI(:,:,i);
    Y = filter2(h,X,'same');
    Z = (Y>0.7);
    
 % Fill holes
    X2 = Z;
    Y2 = filter2(h,X2,'same');
    Z2 = (Y2>0.4);
    
  bROIout(:,:,i) = Z2; 
end

% Clear current ROI, and set to filtered verion
imlook4d_ROI(imlook4d_ROI == imlook4d_frame) = 0;
imlook4d_ROI( bROIout ) = imlook4d_frame;




% Finalize
    EndScript