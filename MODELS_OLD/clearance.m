function outputImage=clearance( handles, matrix,outputFrameRange)
%
% function clearance
%
% This function calculates the clearance k, from the equation
% A=A0*exp(-kt).
% Low uptake values are ignored, because the low S/N ratio is too low 
% to give accurate values.
%
% input:
%
%   handles             - handles to imlook4d variables.  handles.model is describing model.  
%   matrix              - matrix with data [x,y,z,frames]=[:,:,1,:]
%   outputFrameRange    - frames that function will output.  
%                         For models generating static images from a time-series, frame is ignored.
%
% output:
%   outputImage         -  2D image [:,:,1,1] 
%
%
% General information about model plug-in functions for imlook4d:
%   A model function should have ONE of the following capabilities:
%   - convert a time-series to another time-series [:,:,slice,:]=> [:,:,slice,:]
%   - convert a time-series to an image [:,:,slice,:]=> [:,:]
%   It is up to the definition of the model to return either of the above.  
%   (Imlook4d handles the display of both types of returned matrices)
%
%
% This function is an example of a function defined as:
%      input:   time-series at given slice [:,:,1,:]
%      output:  time-series (each frame is calculated)  [:,:,1,1]
% 
%
% A imlook4d plug-in model function follows the above described behavior,
% and the m-file is put into the FUNCTIONS folder.  A control function and
% GUI is also necessary.
%
% Using the plug-in function "test" as an example, the files of an imlook4d model-plugin is 
% /MODELS/test.m                    function manipulating image.
% /MODELS/test/test_control.m       Utility function used for setup of parameters
% /MODELS/test/test_control.fig     GUI for test_control
%
% Author: Jan Axelsson
% 2008-SEP-23

  
    %disp('clearance called');

    % Perform calculations

    % This model takes a time series [:,:,slice,:] and generates a single image.



% INITIALIZE
    Data=matrix;

    
%     disp('Output model parameters');
%             
     firstFrame=handles.model.Clearance.startFrame
     lastFrame=handles.model.Clearance.endFrame
     level=handles.model.Clearance.thresholdLevel  % fraction instead of percent
%     disp('-------------------------');

% EXTRACT SLICE AND FRAMES TO WORK ON

    disp('Filtering data');
    %Data=PCAFilter( Data, 1, 5);          % Do PCA-filter using whole data set
    Y=Data( :,:,1,firstFrame:lastFrame);   % Put data to use in Y
    
    iPixels=size(Y,1);
    jPixels=size(Y,2);

    X=handles.image.time(firstFrame:lastFrame);

% CALCULATE CLEARANCE

    % Loop pixels, for selected slices
    
    disp('Calculating clearance images');

 
        tempImage=Data(:,:,1,lastFrame);% Last frame, current slice
        threshold=level*max(tempImage(:));
        %disp(['    Threshold level=' num2str(threshold) ]);
tic
        for i=1:iPixels
            for j=1:jPixels

                Ytemp=Y(i,j,1,:);   % Only plot if lowest value is above threshold (as set from level, and max pixel value from last frame)

                if (min(Ytemp)> threshold)  % Only do this when high activity (low activity can create any slope due to scattered data)

                    % Method 1)
                    %b = polyfit(X(:),log(Ytemp(:)-threshold+1),1); % Version where background is subtracted
                    
                    % Method 2)
                    %b = polyfit(X(:),log(Ytemp(:)),1);             % Version where log is taken straight
                    
                    % Method 3)
                    % Matrix operator method (equivalent to method 2 )
                    logY=log(Ytemp(:));
                    coefficients=[X(:) ones(length(X),1) ] \ logY;  % Backslash operator
                    b=coefficients(1);

                    pars(i,j,1,:)=b;
                else
                    pars(i,j,1,:)=[0,0];
                end

            end
        end
toc
      outputImage(:,:,1,1)=-pars(:,:,1)*60;  % Output k in minutes
      
      
      
      % MATHEMATICAL THEORY:
   %
   % The slope and offset are calculated from a set of linear equations
   % k*x1+m=y1
   % k*x2+m=y2
   % ...
   % k*xn+m=yn
   %
   % These equations can be written in matrix form AX=B
   % where
   %    | x1  1 |     | k |      | y1 |
   % A= |  ...  |   X=| m |   B= | ...|
   %    | xn  1 |                | yn |
   % which is solved for X (X is the variable "coefficients")
   % by using the left matrix divide (\)
   % which is roughly the same as multiplying by inverse matrix from left.
   %
   % Thus inv(A)*A*X=inv(A)*B 
   % =>            X=inv(A)*B
   % which in matlab language is X=A\B.
   %
   % The clearance equation
   % Y=A*exp(-kt)
   %    ln(Y)= ln(A) -kt
   % which is the straight line equation
   % 
