% TODO : Open in new window (StartScript?) and return reoriented image

% Use absor.m code from https://se.mathworks.com/matlabcentral/fileexchange/26186-absolute-orientation-horn-s-method

% Use current image as moving image
ExportUntouched;
B_4D = imlook4d_Cdata; % Possibly 4D matrix
B_windowName = imlook4d_current_handles.figure1.Name;


B_ROI = imlook4d_ROI; 
B_ROI_names = imlook4d_ROINames;

% ORIGINAL (called B)

% Read fiducial markers for current image
PB0 = getRoiCGs(imlook4d_ROI)';
sizeB = size(imlook4d_ROI);
x = 0.5 * sizeB(1) * imlook4d_current_handles.image.pixelSizeX;
y = 0.5 * sizeB(2) * imlook4d_current_handles.image.pixelSizeY;
z = 0.5 * sizeB(3) * imlook4d_current_handles.image.sliceSpacing;
RB = imref3d(sizeB,[-x x],[-y y],[-z z]); %  real world coordinates

% PB in world coordinates
[xWorld, yWorld, zWorld] = intrinsicToWorld(RB,PB0(1,:)', PB0(2,:)',PB0(3,:)');
PB = [ xWorld'; yWorld'; zWorld'];


% TEMPLATE (called A)

% Select template image (non-moving image)
templateHandle = SelectWindow({'Select template image (from imlook4d/Windows menu)', '(image that we want slices to match'});
imlook4d_current_handle = figure(templateHandle.Parent); % Selected window

% Read fiducial markers for template image
ExportUntouched;
A_windowName = imlook4d_current_handles.figure1.Name;
PA0 = getRoiCGs(imlook4d_ROI)';

sizeA = size(imlook4d_ROI);
x = 0.5 * sizeA(1) * imlook4d_current_handles.image.pixelSizeX;
y = 0.5 * sizeA(2) * imlook4d_current_handles.image.pixelSizeY;
z = 0.5 * sizeA(3) * imlook4d_current_handles.image.sliceSpacing;
RA = imref3d(sizeA,[-x x],[-y y],[-z z]); %  real world coordinates

% PA in world coordinates
[xWorld, yWorld, zWorld] = intrinsicToWorld( RB, PA0(1,:)', PA0(2,:)',PA0(3,:)');
PA = [ xWorld'; yWorld'; zWorld'];


% Print points
disp([ 'Register window "' B_windowName ' :' ]);
disp([ [ '  x: ';'  y: ';'  z: '] num2str(PB) ]);


disp([ 'to window "' A_windowName ' :' ]);
disp([ [ '  x: ';'  y: ';'  z: '] num2str(PA) ]);

% % Graph points
% figure;
% scatter3( PB(1,:), PB(2,:), PB(3,:));
% hold on;
% p=PA;scatter3( PA(1,:), PA(2,:), PA(3,:));
% for i = 1 : size( PB,2)
%     line( [PB(1,i), PA(1,i)], [PB(2,i), PA(2,i)], [PB(3,i), PA(3,i)],'Color','black');
% end
% 
% xlabel('x');ylabel('y');zlabel('z');
% hold off;
% legend('b','a');

% Calculate Registration Parameters
%[regParams,Bfit,ErrorStats]=absor(PA,PB,'DoScale',1);
%[regParams,Bfit,ErrorStats]=absor(PA,PB,'doTrans',0);

[regParams,Bfit,ErrorStats]=absor(PA,PB,...
    'doTrans',true,...
    'doScale',true);

T = regParams.M.';  % See https://se.mathworks.com/help/images/matrix-representation-of-geometric-transformations.html
AT = affine3d(T);


% Register 3D volumes (loop frames)
numberOfFrames = size( B_4D,4);
for i = 1 : numberOfFrames
    disp(['Registering frame = ' num2str(i) ' ( of ' num2str(numberOfFrames) ' )' ]);
   
    B = B_4D(:,:,:,i);
    B( isnan(B) ) = 0;  
    
    % https://se.mathworks.com/matlabcentral/answers/328737-how-can-i-do-a-homogeneous-transform-of-data-to-a-different-coordinate-system
    [C,RC] = imwarp(B,RB,AT,'OutputView',RA); % transform into coordinate system of image B
 
    newDyn(:,:,:,i) = C;
end


% DO ROIs
    disp(['Registering ROIs ' ]);
    B = imlook4d_ROI;
    B( isnan(B) ) = 0;  
    % https://se.mathworks.com/matlabcentral/answers/328737-how-can-i-do-a-homogeneous-transform-of-data-to-a-different-coordinate-system
    [C_ROI,RC] = imwarp(B,RB,AT,'OutputView',RA); % transform into coordinate system of image B


disp('DONE!');

h = imlook4d(newDyn);
ExportUntouched;
imlook4d_ROI = C_ROI;
imlook4d_ROINames = B_ROI_names;
ImportUntouched
