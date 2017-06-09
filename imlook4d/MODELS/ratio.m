function outputImage=ratio( handles, matrix,outputFrameRange)
%
% function ratio
%
% input:
%
%   handles             - handles to imlook4d variables.  handles.model is describing model.  
%   matrix              - matrix with data [x,y,z,frames]=[:,:,1,:]
%   outputFrameRange    - frames that function will output.
%
% output:
%   outputImage         -  3D image time series [:,:,1,:] if outputFrameRange is a range
%                           or
%                          2D image [:,:,1,1] if outputFrameRange is a number 
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
% This function is an example of a function with two possible behaviours.
% The behaviour is controlled by the variable outputFrameRange.
%
% Behaviour I (for GUI update):  
%      input:   time-series at given slice [:,:,1,:]
%      output:  time-series (each frame is calculated)  [:,:,1,1] when outputFrameRange is a number
%
% Behaviour II (for save operations):  
%      input:   time-series at given slice [:,:,1,:]
%      output:  time-series (each frame is calculated)  [:,:,1,:] when outputFrameRange is a range
%
% A imlook4d plug-in model function follows the above described behavior,
% and the m-file is put into the FUNCTIONS folder.  A control function and
% GUI is also necessary.
%
% Using the plug-in function "ratio" as an example, the files of an imlook4d model-plugin is 
% /MODELS/ratio.m                    function manipulating image.
% /MODELS/ratio/ratio_control.m       Utility function used for setup of parameters
% /MODELS/ratio/ratio_control.fig     GUI for ratio_control
%
% Author: Jan Axelsson
% 2008-SEP-23


    
    % Perform calculations
    for i=outputFrameRange  % Generate one image per frame in outputFrameRange
        %disp(i);
        modelImage(:,:,1,i)=matrix(:,:,1,i)/handles.model.ratio.TACT(i);
        max(max(max(abs(matrix(:,:,1,i)))));
    end

    % Fix matrix dimensions depending if output is single image or
    % time-series.
    %
    % This may not be necessary if output can only be a single image 
    % (for instance PATLAK and other models)
    
    if (size(outputFrameRange(:))==1)
        % (If outputFrameRange is not a range, a single image should be returned)
        % Create 2D image
        outputImage=modelImage(:,:,1,outputFrameRange);
    else
        % (If outputFrameRange is a range)
        % Keep 4D image
        outputImage=modelImage;
    end

