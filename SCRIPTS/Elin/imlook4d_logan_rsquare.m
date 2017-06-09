function [outputData X Y]=imlook4d_logan_rsquare(dataMatrix, time, duration, startFrame, endFrame, referenceData, type)
%function outputData=imlook4d_logan(dataMatrix, time, duration, startFrame, endFrame, referenceData, type)
%
% Logan parametric image for imlook4d
%
% Input:
%           dataMatrix      4D dynamic scan
%           time            1D time for each frame (unit seconds)
%           duration        1D duration for each frame (unit seconds)
%           startFrame      first frame for line fit
%           endFrame        last frame for line fit
%           referenceData   1D time-activity data for reference data (plasma)
%           type            'slope' or 'intercept'
%
% Output:
%           outputData  parametric image (2D matrix)        
%           X           optional - new X axes for each pixel (2D matrix)
%           Y           optional - new Y axes for each pixel (2D matrix)
%
% Jan Axelsson

%
% Initialize
%    
    integrationRange=startFrame:endFrame;
    
% %   
% % Make new X and Y axis
% %
%     for i=1:endFrame 
%         % Patlak: integral{C(a)}/C(a)
%         % Logan:
%         % integral{REF}/pixel
%         counts(i)=referenceData(i)*duration(i);   % Counts= C(a)*duration
%         newX(i)=sum(counts(1:i));                 % Integrate
%         newX(i)=newX(i)/dataMatrix(:,:,1,i));         % Divide by C(a)
% 
%         % Patlak: C(t)/C(a)
%         % Logan:
%         % integral{pixel}/pixel
%         newY(:,:,1,i)=dataMatrix(:,:,1,i)/referenceData(i);
%     end

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
   %numPixels=0;
   X=zeros(size(dataMatrix,1),size(dataMatrix,2), size(dataMatrix,4));
   Y=zeros(size(dataMatrix,1),size(dataMatrix,2), size(dataMatrix,4));
   slope=zeros(size(dataMatrix,1),size(dataMatrix,2));
   intercept=zeros(size(dataMatrix,1),size(dataMatrix,2));
   r_square=zeros(size(dataMatrix,1),size(dataMatrix,2));
   yresid=zeros(size(dataMatrix,2), size(dataMatrix,4));
   sumMatrix=sum(dataMatrix(:,:,1,:)==0,4);  % Number of frames equal to zero (counted for each pixel i,j)

   deltaT=duration/60;                  % In minutes   
   counts=referenceData.*deltaT';       % integral over duration of one frame

   for i=1:size(dataMatrix,1)     % rows
       for j=1:size(dataMatrix,2) % columns

           % Calculate normalized time and uptake for pixel (i,j)
           % (when not zeros in all frames)

              if   sumMatrix(i,j)  % Number of zeros in all frames for this pixel
                   newX=ones(size(dataMatrix,4),1);
                   newY=newX;
                    
                   % Store new coordinates for each pixel
                    X(i,j,:)=newX;
                    Y(i,j,:)=newY;
              else
                  tempMatrix=dataMatrix(i,j,1,:);      % activity as a function of time for this pixel and slice
                  tempMatrix=tempMatrix(:);
                   %counts=referenceData.*deltaT';       % integral over duration of one frame
                   newX=cumsum(counts)./tempMatrix;     % integeral{REF}/ROI(t)

                   countsY=tempMatrix(:).*deltaT';      % integral over duration of one frame
                   newY=cumsum(countsY)./tempMatrix;    % integeral{ROI}/ROI(t) 
                   
                   % Store new coordinates for each pixel
                    X(i,j,:)=newX;
                    Y(i,j,:)=newY;
               end

%                % Store new coordinates for each pixel
%                X(i,j,:)=newX;
%                Y(i,j,:)=newY;

               % Limit range
               oldX=newX;
               oldY=newY;
               newX=newX(integrationRange);
               tempY=newY(integrationRange);


           % Calculate slope and intercept (only non-infinity or non-zero values)     
               %if max(newX(:))==Inf || sum(tempMatrix==0)
               if max(newX(:))==Inf ||   sumMatrix(i,j)   
                   slope(i,j)=0;
                   intercept(i,j)=0;
                   r_square(i,j)=0;
               else 
                    %coefficients = polyfit(newX(:),tempY(:),1); % SLOW      
                    %coefficients=pinv([newX ones(length(newX),1) ])* tempY;  % pinv      
                    coefficients=[newX ones(length(newX),1) ] \ tempY;  % Backslash operator
                    slope(i,j)=coefficients(1);
                    intercept(i,j)=coefficients(2); 
                    %[r_square(i,j), temp]=rsquare(newX, tempY, coefficients, integrationRange);
                    [r_square(i,j), temp]=rsquare(oldX, oldY, coefficients, integrationRange);
                    yresid(j, :)=temp';
               end

                %numPixels=numPixels+1;

       end % Loop columns j
   end % Loop rows i

%    
% %
% % TEST - try to improve speed  ---  THIS DOES NOT WORK YET!!!
% %
% 
%     % Setup
%        deltaT=duration/60;                  % In minutes
%     
%     % New X-axis for all pixels and frames
%        countsX=referenceData.*deltaT';      % integral over duration of one frame (1:NFrames)
%        csumX=cumsum(countsX,4);
%        for k=1:length(csumX)                % Loop over frames
%             newX2(:,:,:,k)=csumX(k)./dataMatrix(:,:,:,k);    % integeral{REF}/ROI(t)
%        end
%                
%    % New Y-axis for all pixels and frames             
%        csumY=zeros(size(dataMatrix,1),size(dataMatrix,2),size(dataMatrix,3));  % Zero cummulative sum
%        for k=1:length(csumX)                % Loop over frames, integrate frame by frame
%             csumY=csumY+dataMatrix(:,:,:,k).*deltaT(k);    % integral over duration of one frame
%             newY2(:,:,:,k)=csumY./dataMatrix(:,:,:,k);     % integeral{ROI}/ROI(t)   
%        end
%                
%     % Fix inf
%        newX2=(1-isinf(newX2)).*newX2;       % Set to zero if new X axis is infinite
%        newY2=(1-isinf(newY2)).*newY2;       % Set to zero if new X axis is infinite
%        
%        newX2=(1-isnan(newX2)).*newX2;       % Set to zero if new X axis is Nan
%        newY2=(1-isnan(newY2)).*newY2;       % Set to zero if new X axis is Nan
%         
%      % Calculate slope for each pixel
%        for i=1:size(dataMatrix,1)     % rows
%             for j=1:size(dataMatrix,2) % columns
%                 % Limit range
%                 tempX2(1:6)=newX2(i,j,1,integrationRange);
%                 if max(tempX2(:))==Inf || sum(dataMatrix(i,j,1,:)==0)
%                    slope(i,j)=0;
%                    intercept(i,j)=0;
%                 else               
%                     tempY2(1:6)=newY2(i,j,1,integrationRange)';  % Limit range
%                     coefficients=[ tempX2' ones(length(tempX2),1) ] \ tempY2;  % Backslash operator
%                     slope(i,j)=coefficients(1);
%                     intercept(i,j)=coefficients(2);
%                 end
%             end
%        end
       

%
% Decide which image to show (Slope makes more sense)
%

    if (strcmp(type, 'slope'))
        outputData=slope;  
    end
    
    if (strcmp(type, 'intercept'))
        outputData=intercept;  
    end
    
    if (strcmp(type, 'r_square'))
        outputData=r_square;  
    end  
    if (strcmp(type, 'residual'))
        outputData=yresid;  
    end



