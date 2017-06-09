classdef BasicTact < handle
   properties
       %
       % General design rules:
       %
       % store data in objects in SI units
       % calculate in whatever units required
       
       % ROI data
       
       TACT  % tact-struct (from imlook4d)
       MODEL % tact-struct (from imlook4d) 
       
       % Additions created in tact-struct
       %   TACT.X         derived X-values ( = TACT.midtime, if not graphical model)
       %   TACT.Y         derived Y-values ( = TACT.mean   , if not graphical model)
       %   TACT.MODEL     modelled Y-values( = modelfunction(coefficients, TACT.X) )
       
       % Plot labels
       
       XLabel = 'time';
       YLabel = 'activity';
       MainLabel = 'Time-activity curve';
       
       % Frame markers
       frameMarker;  % cell of frame numbers that should be marked in plot
       
       % Models
       
       inputParameters = {};        % List of model input parameters
       inputParameterNames = {};    % List of model input parameters names
       
       coefficients= {};            % Calculated coefficients
       coefficientNames= {};        % Calculated coefficients names
       coefficientUnits= {};        % Calculated coefficients names
   end
   methods
       %
       % Constructor
       %
       function obj = BasicTact( TACTin)
           obj.TACT = TACTin;
           
           cols = size( obj.TACT.mean, 2);
           obj.TACT.midtime = repmat( obj.TACT.midtime,[1 cols] );  % Make same number of cols as in Y-data           
           obj.TACT.frameMarker = cell(1, cols); % Empty
           
           obj.TACT.X = obj.TACT.midtime;
           obj.TACT.Y = obj.TACT.mean;
       end
       %
       % Setters
       %
       
       function setFrameMarker(obj, rois, frameNumber)
           
           if strcmp(':', rois)
               cols = size( obj.TACT.mean, 2);
               rois=1:cols;
           end
           
           for i=rois
              obj.frameMarker{i} = frameNumber;
           end
       end

       %
       % Getters
       %
       function X = getX(obj)
           X = obj.TACT.midtime; % in seconds
       end
       function Y = getY(obj)
           Y = obj.TACT.mean;
       end
       function X = getModelX(obj)
           X = obj.MODEL.X; % Override if model
       end
       function Y = getModelY(obj)
           Y = obj.MODEL.Y; % Override if model
       end
       function Y = getDuration(obj)
           Y = obj.duration;
       end

       function names = getRoiNames(obj, rois)
           names = obj.TACT.names(rois);
       end
       
              
       
       function frameNumbers = getFrameMarker(obj, rois)
           frameNumbers = obj.frameMarker{rois};
       end

   end
end