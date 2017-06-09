classdef NoModel < BasicTact
    
   properties 
   end
   
   methods
       %
       % Constructor
       %
       function obj = NoModel( ROI_data_struct)
           if nargin == 0
           end
           % Call superclass constructor
           obj@BasicTact(ROI_data_struct);
       end
       
   end
     
end
