classdef ReferenceLogan < ReferenceModel
    
   properties 
   end
   
   methods
       %
       % Constructor
       %
       function obj = ReferenceLogan( TACT)
           % Call superclass constructor
           obj@ReferenceModel(TACT);
           
           % Set input parameter default values  
           obj.inputParameterNames = {  'k2''','N', 'First point', 'Last point', 'First point', 'Last point', 'First point', 'Last point' }; % Note k2' is in units min-1.  Default value for Raclopride (where k2 term also may be excluded)
           obj.inputParameters = {  0.163 , 1, 1, size(TACT.mean,1), 1, size(TACT.mean,1), 1, size(TACT.mean,1)};  % Default values.  k2 from: Logan, Journal of Cerebral Blood Flow & Metabolism (1996) 16, 834–840; doi:10.1097/00004647-199609000-00008
           obj.coefficientUnits = {  'min-1', '', '', '', '', '', '', ''};
           
           % Output parameters
           obj.coefficientNames={'BPnd','intercept','BPnd','intercept','BPnd','intercept'};
           
           % Visualization labels
           obj.TACT.XLabel = '\int_{0}^{t} C_{ref} dt /ROI + (C_{ref} / k_2'') / ROI ';
           obj.TACT.YLabel = '\int_{0}^{t} ROI dt /ROI';
           obj.MainLabel = 'Logan plot';
       end
       


       %
       % MODEL SPECIFIC FUNCTIONS
       %
       function calculateNewCoordinates(obj)  % (override) 
           % Steps in making your own model:
           % 1) Adjust values that are not applicable
           % 2) Calculate new values for each point x and y
           
           %
           % 1) Not applicable
           %
               %obj.TACT.duration = zeros( size(obj.TACT.duration));
           
               
           %
           % 2) Calculate new coordinates 
           %

               % TACT to minutes
               TACT = obj.TACT;
               TACT = resample1D( TACT, 's_to_min');

               % Ref region to vector
               Cref = obj.getReferenceTact();

               % Logan coordinate system
               k2 = num2str(obj.inputParameters{1});
               TACT_logan = resample1D( TACT, 'logan', Cref, k2 );

               obj.MODEL.midtime = TACT_logan.midtime;
               obj.MODEL.mean = TACT_logan.mean;
           
       end
       
       function fitModel(obj)
           % Make your own model:
           % obj.coefficientNames   contain names
           % obj.coefficients       contains the coefficients for each ROI
           
               % Define coefficients
               %obj.coefficients=cell(0);  % Make empty -- will only fill what is needed (and empty fields are not displayed)
               obj.coefficients = [];

               % Loop for multiple Logans
               N = obj.inputParameters{2};
               for j=0:(N-1)
                   % Limit range
                   firstFrame = obj.inputParameters{3+j*2};
                   lastFrame = obj.inputParameters{4+j*2};
                   
                   TACT_subrange = resample1D( obj.TACT, 'sub_range',firstFrame,lastFrame);
                   
                   % Perform fit
                   pguess = [ 0 3  ];
                   [TACT_fit, p] = regionalModel( TACT_subrange , obj.getReferenceTact(), @Logan, pguess);
                   %[TACT_fit, p] = regionalModel( TACT_subrange , [], @Logan, pguess); % Use new coordinates, no ref region needed in this coordinate system
                   
                   obj.coefficients = [obj.coefficients  p];
               end
               
               obj.coefficients = obj.coefficients';


               % Book keeping, set frameMarkers
               obj.setFrameMarker( :, cell2mat(obj.inputParameters(3:end)))
       end
       function Y = getModelY(obj)
           % Make your own model:
           % Y  contains fitted Y-data points corresponding to obj.newX 
           
           cols = size(obj.MODEL.mean,2);
           Y = zeros( size(obj.MODEL.midtime ));
           for i = 1:cols
               c = obj.coefficients(:,i);
               c(1) = c(1) + 1;  % DVR = BP + 1;  BP = DVR - 1
               Y(:,i) = c(1)*obj.MODEL.midtime(:,i) + c(2);
           end
       end
       
   end
end
