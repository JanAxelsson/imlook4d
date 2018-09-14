%function outputData=imlook4d_patlak(dataMatrix, time, duration, startFrame, endFrame, referenceData, type)
function outputData=imlook4d_patlak(dataMatrix, time, duration, PatlakStruct)
% Patlak image for imlook4d
%
% Jan Axelsson 
% 2010-11-30

%
% Initialize
%    
    startFrame=PatlakStruct.startFrame;
    endFrame=PatlakStruct.endFrame;
    referenceData=PatlakStruct.referenceData;
    type=PatlakStruct.type;
    try
        integralOffset=PatlakStruct.integralOffset; % Area under curve until start of scan, decaycorrected to start of current scan.
    catch
        integralOffset=0;  % If no integral offset is defined (i.e. starting patlak from scan start, and not before scan start).
    end

    integrationRange=startFrame:endFrame;
    
%   
% Make new X and Y axis
%
    for i=1:endFrame 
        % integral{C(a)}/C(a)
        counts(i)=referenceData(i)*duration(i);   % Counts= C(a)*duration
        %newX(i)=sum(counts(1:i));                % Integrate (without offset)
        newX(i)=sum(counts(1:i)) + integralOffset;% Add integral that was before this scan
        newX(i)=newX(i)/referenceData(i);         % Divide by C(a)

        % C(t)/C(a)
        newY(:,:,1,i)=dataMatrix(:,:,1,i)/referenceData(i);
    end
    
    
    

%
% Calculate slope and offset by fitting from startFrame to endFrame
%  

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
   numPixels=0;
   newX=newX(integrationRange);
   newX=newX(:);

   for i=1:size(dataMatrix,1)     % rows
       for j=1:size(dataMatrix,2) % columns
            tempY=newY(i,j,1,integrationRange);
            tempY=tempY(:);
            
            %coefficients = polyfit(newX(:),tempY(:),1); % SLOW            
            coefficients=[newX ones(length(newX),1) ] \ tempY;  % Backslash operator
            slope(i,j)=coefficients(1);
            intercept(i,j)=coefficients(2); 
            
            numPixels=numPixels+1;
       end
   end


%
% Decide which image to show
%

    if (strcmp(type, 'slope'))
        outputData=slope*60;  % Convert from unit 1/s to unit 1/min
    end
    
    if (strcmp(type, 'intercept'))
        outputData=intercept;  
    end  




