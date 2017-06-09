% Logan_ROI_regional_curves.m   
%
% SCRIPT for imlook4d to display TACT with Logan axes from a dynamic image.
% Works in dynamic image mode (not static, or Logan image mode).
%
% The concept is to use the same function used in the parametric image
% but here an image is formed with one pixel per ROI.
%
% Jan Axelsson

    TAB=sprintf('\t');
    EOL=sprintf('\n');
    

%
% Initialize
%
    startFrame=1;                                           % Default for plotting all data points
    endFrame=size(imlook4d_current_handles.image.Cdata,4);  % Number of frames
    roiNames = get(imlook4d_current_handles.ROINumberMenu,'String'); % Cell array  
    numberOfROIs=size(roiNames,1)-1;
    
    time=imlook4d_current_handles.image.time;
    duration=imlook4d_current_handles.image.duration;

%
% Make image with ROIs in pixels
%
%     [TACT, NPixels]=generateTACT(...
%         imlook4d_current_handles,...
%         imlook4d_current_handles.image.Cdata,...
%         imlook4d_current_handles.image.ROI);
        [TACT, NPixels]=generateTACT(...
        imlook4d_current_handles,...
        imlook4d_current_handles.image.ROI);
    
%
% Test that dynamic sequence 
% (that is, you are not allowed to be in Logan
% model either because the Logan image is a static image)
%
    %size(TACT,2);
    if ( size(TACT,2)==1)
         msgbox({'A dynamic sequence is needed (Logan gives a static image)!'  ' '...
             'Useage:' ...
             '1) Enter Logan model and input a reference curve from current ROI' ...
             '2) Leave Logan' ...
             '3) Select "no model"' ...
             '4) Run this script again'},...
             'ERROR in SCRIPT',...
             'error'); 
    end
   
    
    
    
    for i=1:numberOfROIs
        dataMatrix(1,i,1,:)=TACT(i,:);  % Make image with one pixel per ROI
    end  

%
% Calculate Logan x and y axes for ROIs 
%
    referenceData=imlook4d_current_handles.model.Logan.referenceData;

    %(LoganSlope will be nonsense, since I use this routine to get the x and y for all frames)
    [LoganSlope newX newY]=imlook4d_logan_rsquare(dataMatrix, time, duration, startFrame, endFrame, referenceData, 'slope'); 

%
% Plot data points
%
    figure('NumberTitle','off',...
        'Name', ['Regional Logan: ' get(imlook4d_current_handles.figure1,'Name')] );
    
    for i=1:numberOfROIs
        disp(i)
        % Plot current ROI
           try
                newX2=newX(1,i,:);newX2=newX2(:);
                newY2=newY(1,i,:);newY2=newY2(:);
                plot( newX2, newY2 , 'o', 'MarkerSize',3);
                hold all
           catch
               warning('Error in plot of Logan plot');
           end

    end
    
%
% Write titles and legend
%
    xlabel('\int_{0}^{t} C_a dt /ROI');
    ylabel('\int_{0}^{t} ROI dt /ROI');
    %title(['Logan for ROIs in ' get(imlook4d_current_handles.figure1,'Name')],'interpreter','none'); 

    for i=1:numberOfROIs 
        contents{i}=[roiNames{i} ' (' num2str(NPixels(i)) ' pixels)' ]; % Add pixel count to legend
    end
    legend(contents);
        
%
% Dialog - Enter range for straight line fit
%
    % Dialog option
    prompt={'Enter low frame number:','Enter high frame number:' };
    name='Enter low and high frame';
    numlines=1;
    defaultanswer={'1' num2str(size(newY2,1 ))  };
    answer=inputdlg(prompt,name,numlines,defaultanswer);

    startFrame=str2num(answer{1});
    endFrame=str2num(answer{2});
 
%
% Plot lines
%

   % Curve fits to straight line y=kx+m
   [slope     newX newY]=imlook4d_logan_rsquare(dataMatrix, time, duration, startFrame, endFrame, referenceData, 'slope');    
   [intercept newX newY]=imlook4d_logan_rsquare(dataMatrix, time, duration, startFrame, endFrame, referenceData, 'intercept');
   [r_square  newX newY]=imlook4d_logan_rsquare(dataMatrix, time, duration, startFrame, endFrame, referenceData, 'r_square');
   [yresid    newX newY]=imlook4d_logan_rsquare(dataMatrix, time, duration, startFrame, endFrame, referenceData, 'residual');
   
   
   % Plot lines
   for i=1:numberOfROIs
        newX2=newX(1,i,startFrame:endFrame);
        
        k=slope(i);
        m=intercept(i);
        
        %xValues=[0 newX2(end)];
        %yValues=[m m+k*newX2(end)];
        xValues=[ -m/k newX2(end)];
        yzero=[ 0 m+k*newX2(end)];   
                
        plot( xValues, yzero);  % Plot straight line
   end
   
   
   
   
%
% Annotate plot
%
 myAnnotation={...
                '\bfLogan fit:\rm', ...
            	['slope (DVR)  ='],...
            	[ num2str( slope, '%f10' )],...
                ['intercept =' ],...
                [num2str(intercept, '%f10')],...
                ['R^{2} =' ],...
                [num2str(r_square , '%f10')],...
                };
            
            text('Position',[0.95,0.4,0],'String',myAnnotation,'Units','normalized','HorizontalAlignment','Right')

   
 
   for i=1:numberOfROIs
       %figure;
       xtemp=reshape(newX(1, i, :), 1, size(newX, 3));
       ytemp=reshape(yresid(i, :), 1, size(newX, 3));
          %plot(xtemp, ytemp, '.'); 
          figure;
          hold on
          plot(time, ytemp, '.'); 
          xzero=[ min(time) max(time)];
        yzero=[ 0 0];   
                
        plot( xzero, yzero);  % Plot straight line
   end
            
%
% Output to Matlab window
%
            disp('Slope (DVR)=');
            
            s='';
            for i=1:numberOfROIs
                 s=[ s num2str(slope(i)) TAB];
            end
            s=[ s(1:end-1) EOL];
            
            disp(s);

%
% Clean up
%
%     clear a answer dataMatrix defaultanswer deltaT duration ...
%         intercept k m name newX2 newY2 numlines prompt referenceData roiNames slope  ...
%         startFrame tempY time LoganSlope contents endFrame i newX newY  numberOfROIs ...
%         TACT i NPixels

