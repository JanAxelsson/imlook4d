classdef ReferenceModel < BasicTact
   properties 
       Ref_ROI;  % ROI number
   end
   
   methods
       %
       % Constructor
       %
       function obj = ReferenceModel( TACT)
           if nargin == 0
           end
           % Call superclass constructor
           obj@BasicTact(TACT);

       end
       %
       % Setters
       %
       function setReferenceRegion(obj, number)
           obj.Ref_ROI = number;
           calculateNewCoordinates(obj);
           fitModel(obj);
       end
       
       %
       % Getters
       %
       function r = getReferenceRegion(obj)
           r = obj.Ref_ROI;
       end
       function r = getReferenceTact(obj)
           r = obj.TACT.Y(:,obj.getReferenceRegion() );
       end
       function X = getX(obj) % (override)
           X = obj.TACT.X; % in minutes
       end
       function Y = getY(obj) % (override)
           Y = obj.TACT.Y;
       end      
       function c = getFittedParameters(obj) % (override)
           c = obj.coefficients;
       end      
       %
       % Private functions -- Dummy functions
       %
       function calculateNewCoordinates(obj)
           % dummy function, override if graphical method
           
           % New coordinates
           obj.X.midtime = obj.TACT.midtime;     
           obj.Y.mean = obj.TACT.mean; 
       end  
       function fitModel(obj)
           % dummy function, override
           
            % Examples -- override fitModels
           coefficients = { 1, 2, 3 }; 
           coefficentNames = { 'Ka', 'Kb', 'Kc'};  
       end
       function Y = getModelY(obj)
           % dummy function, override
           Y = getY(obj);
       end
       function R = residual(obj)
           R = getModelY(obj) - getY(obj);
       end
  
   end
end
