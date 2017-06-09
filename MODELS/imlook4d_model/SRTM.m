classdef SRTM < ReferenceModel
    
   properties 
   end
   
   methods
       %
       % Constructor
       %
       function obj = SRTM( TACT)
           % Call superclass constructor
           obj@ReferenceModel(TACT);
           
           % Set input parameter default values  
           obj.inputParameterNames = {  'k2''','N', 'First point', 'Last point', 'First point', 'Last point', 'First point', 'Last point' }; % Note k2' is in units min-1.  Default value for Raclopride (where k2 term also may be excluded)
           obj.inputParameters = {  0.163 , 1, 1, size(TACT.mean,1), 1, size(TACT.mean,1), 1, size(TACT.mean,1)};  % Default values.  k2 from: Logan, Journal of Cerebral Blood Flow & Metabolism (1996) 16, 834–840; doi:10.1097/00004647-199609000-00008
           obj.coefficientUnits = {  'min-1', '', '', '', '', '', '', ''};
           
           % Output parameters
           obj.coefficientNames={'BPnd','intercept','BPnd','intercept','BPnd','intercept'};
           
           % Visualization labels
           obj.XLabel = '\int_{0}^{t} C_{ref} dt /ROI + (C_{ref} / k_2'') / ROI ';
           obj.YLabel = '\int_{0}^{t} ROI dt /ROI';
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
               obj.duration = zeros( size(obj.duration));
               referenceData = obj.getReferenceTact(:);          
               tact = obj.TACT.mean;
               cols = size(tact,2);
               
           %
           % 2) Calculate new coordinates (more data points)
           %
               % Use default ROI data
               t = obj.TACT.midtime;   % In seconds
               
               global dt; 
               dt= obj.TACT.duration; % In seconds
               
               
               N = 30; % Number of seconds per sample
               start =(60*t(1));
               stop = (60*t(end));
               xdata = (start:start+N:stop)' / 60 ;
               tact = obj.TACT.mean
               ydata = interp1(t,tact,xdata,'linear');

               % New coordinates
               obj.newX = repmat( xdata, [1 cols]);
               obj.newY = ydata;  
               
               
               global Cref;
               Cref = interp1(t,referenceData,xdata,'linear');

       end  
       function fitModel(obj)
           % Make your own model:
           % obj.coefficientNames   contain names
           % obj.coefficients       contains the coefficients for each ROI
           
               % Define coefficients
               obj.coefficients=cell(0);  % Make empty -- will only fill what is needed (and empty fields are not displayed)
               
               % Loop reading multiple input parameters
               N = obj.inputParameters{2};
               
               cols = size(obj.newY,2);
               pguess = [0.8 , 0.23, 0.23/(1+3.27) ];
               global model;
               for i=1:cols % Loop ROIs, put coefficient values in new column
                   xdata = obj.newX(:,i);
                   ydata = obj.newY(:,i);
                   [obj.coefficients{i},R,J,CovB,MSE,ErrorModelInfo] = nlinfit(xdata', ydata', @SRTM_function, pguess)
               end

    % TODO get data into SRTM_funtion:
    % http://stackoverflow.com/questions/22436070/transfer-my-own-fun-to-nlinfit
               
               obj.coefficients(i,(1:2)+j*2) = coeffs;

               % Book keeping, set frameMarkers
               obj.setFrameMarker( :, cell2mat(obj.inputParameters(3:end)))
       end
       function Y = getModelY(obj)
           % Make your own model:
           % Y  contains fitted Y-data points corresponding to obj.newX 

           cols = size(obj.newY,2);
           Y = zeros( size(obj.newX ));
           for i = 1:cols
               Y(:,i) = SRTM_function(obj.coefficients{i},obj.newX(:,i));
           end
       end
       
   end
end
