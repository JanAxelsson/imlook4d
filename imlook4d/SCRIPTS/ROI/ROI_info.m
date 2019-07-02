% Current_ROI_info.m
% Script for displaying info about current ROI
% Jan Axelsson 2011-10-27

%
% Initialize
%
    StoreVariables  % Remember variables
    Export
    %ROI_data_to_workspace;
    ExportROIs(imlook4d_ROI_number)
    
    TAB=sprintf('\t');

%
% Get parameters
%
try
    dX=imlook4d_current_handles.image.pixelSizeX;  % mm
    dY=imlook4d_current_handles.image.pixelSizeY;  % mm
    dZ=imlook4d_current_handles.image.sliceSpacing;% mm
catch
    dX=1;
    dY=1;
    dZ=1;
end

% Find frame to use (set to frame=1 when a model is used)
frame=imlook4d_frame;
if (frame>size(imlook4d_ROI_data.mean,1))
     frame=1;
end

%
% Get STATISTICS and GEOMETRY from imlook4d_ROI_data
%
meanActivityConcentrationInROI=imlook4d_ROI_data(1).mean';
%numberOfVoxels=size(imlook4d_ROI_data(1).pixels{imlook4d_ROI_number},imlook4d_ROI_number);
numberOfVoxels= imlook4d_ROI_data(1).Npixels(imlook4d_ROI_number);
stdev=imlook4d_ROI_data(1).stdev';
maxActivity=imlook4d_ROI_data(1).max';
ROIVolumeInML=dX*dY*dZ*numberOfVoxels/1000;   % cm3
activity=meanActivityConcentrationInROI(imlook4d_ROI_number,frame)*ROIVolumeInML;
numberOfPixels=size(imlook4d_ROI_data.pixels{imlook4d_ROI_number},1);

try  % If unit is missing
   test=imlook4d_current_handles.image.unit;
catch
   imlook4d_current_handles.image.unit='unit' 
end

% DISPLAY ROI info
dialogText = { char( {...
    ['Number of pixels= ' TAB  TAB num2str(numberOfPixels)]; ...  
    [' '];...
    ['Average activity concentration     [' imlook4d_current_handles.image.unit '] =' TAB num2str(meanActivityConcentrationInROI(imlook4d_ROI_number,frame)) ];...
    ['Volume [mL]=                                      ' TAB num2str(ROIVolumeInML) ];...
    ['Total activity [' imlook4d_current_handles.image.unit '*mL] =                     ' TAB num2str(activity) ]; ... 
    ['Max activity concentration [' imlook4d_current_handles.image.unit '] =        '  TAB  num2str(maxActivity(imlook4d_ROI_number,frame) ) ]; ... 
    ['Std activity concentration [' imlook4d_current_handles.image.unit '] =        '  TAB  num2str(stdev(imlook4d_ROI_number,frame) ) ]; ...  
    [' '];...
    ['Centroid position (pixels) [x,y,z]= ' TAB  num2str(imlook4d_ROI_data.centroid{imlook4d_ROI_number}.x) TAB  num2str(imlook4d_ROI_data.centroid{imlook4d_ROI_number}.y) TAB  num2str(imlook4d_ROI_data.centroid{imlook4d_ROI_number}.z)]; ... 
    ['ROI dimensions    (pixels) [x,y,z]=    ' TAB  num2str(imlook4d_ROI_data.dimension{imlook4d_ROI_number}.x) TAB  num2str(imlook4d_ROI_data.dimension{imlook4d_ROI_number}.y) TAB  num2str(imlook4d_ROI_data.dimension{imlook4d_ROI_number}.z)]; ...
    [' '];...
    ['Centroid position (mm) [x,y,z]=     ' TAB  num2str(dX*imlook4d_ROI_data.centroid{imlook4d_ROI_number}.x) TAB  num2str(dY*imlook4d_ROI_data.centroid{imlook4d_ROI_number}.y) TAB  num2str(dZ*imlook4d_ROI_data.centroid{imlook4d_ROI_number}.z)]; ... 
    ['ROI dimensions    (mm) [x,y,z]=        ' TAB  num2str(dX*imlook4d_ROI_data.dimension{imlook4d_ROI_number}.x) TAB  num2str(dY*imlook4d_ROI_data.dimension{imlook4d_ROI_number}.y) TAB  num2str(dZ*imlook4d_ROI_data.dimension{imlook4d_ROI_number}.z)]; ... 
   })};

temp=dialogText{1};num_lines=[size(temp)];
options.Resize='on';
options.WindowStyle='normal';
%answer = inputdlg(   {['Data for ROI=' imlook4d_ROINames{ 1+imlook4d_ROI_number} ':']},   'ROI data',   num_lines,   dialogText,[1 100]);
inputdlg(   {['ROI-Data for ' imlook4d_ROINames{ imlook4d_ROI_number} ' (frame=' num2str(frame) ') :']},...
    'ROI data',  [10 100], dialogText, options) 

%
% Finalize
% 
ClearVariables  % Clear remembered variables