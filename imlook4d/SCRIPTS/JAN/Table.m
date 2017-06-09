StartScript 

% Settings
low = 200; % Table HU, low and high range
high = 400;
tableThreshold = 0.4; % Threshold of table in summed image

% Make empty ROI
INPUTS = Parameters( {'table'} );
MakeROI
Export

% Find table in 2D
M = (imlook4d_Cdata > low )&(imlook4d_Cdata < high);  % Set everything above table material HU to 1
AVG = mean(M,3);  % Gives 2D data between 0 and 1
ROI2D = (AVG > tableThreshold);  % Make 2D ROI

% test = AVG;
% test(:,:,2) = ROI2D;

% Broaden ROI -- Dilate the Jan way
 h = ones(5);       % Create filter kernel
 h = h / sum(h(:)); % Normalize area of filter to 1
 smoothedROI2D = filter2(h,ROI2D);  % Filter ROI
 ROI2D = (smoothedROI2D > 0.1);     % Include pixels just outside ROI

% Build 3D ROI
numberOfSlices = size(imlook4d_Cdata,3);
imlook4d_ROI = repmat(ROI2D, [1,1,numberOfSlices]);



% test(:,:,3) = ROI2D;
% test(:,:,4) = SD;
% imlook4d(test);

EndScript
