function outputImage=logan( handles, matrix,outputFrameRange)
%
% function Logan
%
% (based on Patlak m-files)
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

  
    %disp('logan called');

    % Perform calculations

    % This model takes a time series [:,:,slice,:] and generates a single image.

% tic
%       outputImage(:,:,1,1)=imlook4d_logan(...
%             matrix, ...
%             handles.image.time, ...
%             handles.image.duration, ...
%             handles.model.Logan.startFrame, ...
%             handles.model.Logan.endFrame, ...
%             handles.model.Logan.referenceData, ...
%             handles.model.Logan.type );
%         toc
tic

        a = jjlogan( matrix, handles.image.time/60, ...
            handles.image.duration/60, ...
            handles.model.Logan.referenceData',...
            [ handles.model.Logan.startFrame handles.model.Logan.endFrame] ...
            );
        outputImage(:,:,1,1) = a.pars{2}; % DVR
        
toc

