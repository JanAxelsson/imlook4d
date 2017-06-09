% NEMA2007_image_quality.m
% Script for creating ROIs for image quality phantom
% Jan Axelsson 2012-10-26
%
% Instructions:
% 1) Go to slice where the balls are
% 2) Add ROI (Use first ROI for this), and use Threshold_ROI script at 50% of background
% 3) Run this script with the radius needed
% 4) Press TACT

%
% Initialize
%
    StoreVariables  % Remember variables
    Export

    TAB=sprintf('\t');
    
    % Input diameter
    answer = inputdlg('Input ROI circle diameter (mm):')
    d=str2num(answer{1});
    
    %Radius in mm
    r=d/2;

%
% Get parameters
%
    dX=imlook4d_current_handles.image.pixelSizeX;  % mm
    dY=imlook4d_current_handles.image.pixelSizeY;  % mm
    dZ=imlook4d_current_handles.image.sliceSpacing;% mm
    
    % radius in pixels
    r=r/dX


%
% Define extent for current slice (in pixels)
%
    Z0=imlook4d_slice;
    midPoint=size(imlook4d_Cdata,1)/2
    X1=min(find(imlook4d_ROI(:,midPoint,Z0)==1))
    X2=max(find(imlook4d_ROI(:,midPoint,Z0)==1))
    Y1=min(find(imlook4d_ROI(midPoint,:,Z0)==1))
    Y2=max(find(imlook4d_ROI(midPoint,:,Z0)==1))

   
%
% Define ROI positions
%
    % 
    % ROI_coordinates=[ 
    %     127 108;
    %     152 117;
    %     159 129;
    %     165 143;
    %     165 156;
    %     199 184;
    %     138 168;
    %     124 168;
    %     101 166;
    %     88 156;
    %     84 139;
    %     98 117;   
    %     ]

    ROI_coordinates=[ ...
        0.5158    0.1266
        0.7789    0.2405
        0.8526    0.3924
        0.9158    0.5696
        0.9158    0.7342
        0.8033    0.886
        0.6316    0.8861
        0.4842    0.8861
        0.2421    0.8608
        0.1053    0.7342
        0.0632    0.5190
        0.2105    0.2405 ]

%
% Make 12 ROIs (clear existing)
%
    imlook4d_ROI(:)=0;
    
    addROI=imlook4d_ROINames{end};  % Store name for "add ROI" command
    for i=1:size(ROI_coordinates,1)
        imlook4d_ROINames{i}=['ROI ' num2str(i)];
        %Xc=ROI_coordinates(i,1);
        %Yc=ROI_coordinates(i,2);
        Xc=round( absoluteCoordinate(X1,X2,ROI_coordinates(i,1)) );
        Yc=round( absoluteCoordinate(Y1,Y2,ROI_coordinates(i,2)) );

        
        imlook4d_ROI(:,:,Z0)=circleROI(imlook4d_ROI(:,:,Z0), i, Xc, Yc, r);
        rel(i,1)=relativeCoordinate(X1,X2,Xc);
        rel(i,2)=relativeCoordinate(Y1,Y2,Yc);
    end
    imlook4d_ROINames{i+1}=addROI;  % Restore name for "add ROI" command


%
% Finalize
% 
    Import
    ClearVariables  % Clear remembered variables