% TODO : Open in new window (StartScript?) and return reoriented image

% Use absor.m code from https://se.mathworks.com/matlabcentral/fileexchange/26186-absolute-orientation-horn-s-method

% Use current image as moving image
ExportUntouched;
B_dyn = imlook4d_Cdata; % Possibly 4D matrix

% Read fiducial markers for current image
PB = getRoiCGs(imlook4d_ROI)';
disp('Move from points :');
disp([ [ 'x: ';'y: ';'z: '] num2str(PB) ]);
sizeB = size(imlook4d_ROI);
x = sizeB(1) * imlook4d_current_handles.image.pixelSizeX;
y = sizeB(2) * imlook4d_current_handles.image.pixelSizeY;
z = sizeB(3) * imlook4d_current_handles.image.sliceSpacing;
RB = imref3d(sizeB,[-x x],[-y y],[-z z]); %  real world coordinates


% Select template image (non-moving image)
templateHandle = SelectWindow({'Select template image (from imlook4d/Windows menu)', '(image that we want slices to match'});
imlook4d_current_handle = figure(templateHandle.Parent); % New window

% Read fiducial markers for template image
ExportUntouched;
PA = getRoiCGs(imlook4d_ROI)';
disp('to points :');
disp([ [ 'x: ';'y: ';'z: '] num2str(PA) ]);
sizeA = size(imlook4d_ROI);
x = sizeA(1) * imlook4d_current_handles.image.pixelSizeX;
y = sizeA(2) * imlook4d_current_handles.image.pixelSizeY;
z = sizeA(3) * imlook4d_current_handles.image.sliceSpacing;
RA = imref3d(sizeA,[-x x],[-y y],[-z z]); %  real world coordinates


% Calculate Registration Parameters
[regParams,Bfit,ErrorStats]=absor(PA,PB,'DoScale',1);
T = regParams.M.';

T = [regParams.s * regParams.R ,[0 0 0]';[0 0 0 1] ]'; % Ignore translation

AT=affine3d(T);


% Register 3D volumes (loop frames)

for i = 1 : size( B_dyn,4)
    B = B_dyn(:,:,:,i);
    B( isnan(B) ) = 0;  
    
    % https://se.mathworks.com/matlabcentral/answers/328737-how-can-i-do-a-homogeneous-transform-of-data-to-a-different-coordinate-system
    [C,RC]=imwarp(B,RB,AT,'OutputView',RA); % transform into coordinate system of image B
 
    newDyn(:,:,:,i) = C;
end

imlook4d(newDyn)
