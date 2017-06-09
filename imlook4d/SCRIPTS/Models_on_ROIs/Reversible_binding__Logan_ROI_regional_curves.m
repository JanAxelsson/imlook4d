% Logan_ROI_regional_curves.m   
%
% SCRIPT for imlook4d to display TACT with Logan axes from a dynamic image.
% Works in dynamic image mode (not static, or Logan image mode).
%
% The concept is to use the same function used in the parametric image
% but here an image is formed with one pixel per ROI.
%
% Jan Axelsson

    ExportUntouched
    waitfor( logan_control(imlook4d_current_handle,[], imlook4d_current_handles));
    ExportUntouched
    imlook4d_current_handles.model.functionHandle=[];
    guidata(imlook4d_current_handle, imlook4d_current_handles);



    TAB=sprintf('\t');
    EOL=sprintf('\n');
    

%
% Initialize
%
    startFrame = imlook4d_current_handles.model.Logan.startFrame;
    endFrame = imlook4d_current_handles.model.Logan.endFrame;
    referenceData=imlook4d_current_handles.model.Logan.referenceData;
    
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
    

    %(LoganSlope will be nonsense, since I use this routine to get the x and y for all frames)
    [LoganSlope, newX, newY]=imlook4d_logan(dataMatrix, time, duration, startFrame, endFrame, referenceData, 'slope'); 

    
        
%
% Dialog - Enter range for straight line fit
%
    % Dialog option
%     prompt={'Enter low frame number:','Enter high frame number:' };
%     name='Enter low and high frame';
%     numlines=1;
%     defaultanswer={'1' num2str(endFrame)  };
%     answer=inputdlg(prompt,name,numlines,defaultanswer);
% 
%     startFrame=str2num(answer{1});
%     endFrame=str2num(answer{2});    
    
    
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
    title(['Logan for ROIs in ' get(imlook4d_current_handles.figure1,'Name')],'interpreter','none'); 

    for i=1:numberOfROIs 
        contents{i}=[roiNames{i} ' (' num2str(NPixels(i)) ' pixels)' ]; % Add pixel count to legend
    end
    legend(contents);

 
%
% Plot lines
%

   % Curve fits to straight line y=kx+m
   [slope,     newX, newY]=imlook4d_logan(dataMatrix, time, duration, startFrame, endFrame, referenceData, 'slope');  
   [intercept, newX, newY]=imlook4d_logan(dataMatrix, time, duration, startFrame, endFrame, referenceData, 'intercept');
   
   [slope2,     newX2, newY2]=imlook4d_logan(dataMatrix, time, duration, startFrame, endFrame, referenceData, 'slope2');    
   [intercept2,     newX2, newY2]=imlook4d_logan(dataMatrix, time, duration, startFrame, endFrame, referenceData, 'intercept2');
      
   
   % Find line styles 
   h=gca;
   children = get(h, 'Children');
   
   % Plot lines
   for i=1:numberOfROIs
       disp(i)
        newX2=newX(1,i,startFrame:endFrame);
        
        k=slope(i);
        m=intercept(i);
        %k2=slope2(i);
       % m2=intercept2(i);
        
        %xValues=[0 newX2(end)];
        %yValues=[m m+k*newX2(end)];
        xValues=[ newX2(1) newX2(end)];
        yValues=[ (m+k*newX2(1)) (m+k*newX2(end))];  
        %xValues2=[ 0 newX2(end)];
        %yValues2=[ m2 m2+k2*newX2(end)];      

        color = get( children( 1 + numberOfROIs - i),'Color');  % Reverse order on lines contra markers
        set( children( 1 + numberOfROIs - i), 'MarkerFaceColor', color);  % Make solid 
        plot( xValues, yValues, 'Color', color );  % Plot straight line
   end
   
%
% Annotate plot
%
%  myAnnotation={...
%                 '\bfLogan fit:\rm', ...
%             	['slope (DVR)  ='],...
%             	[ num2str( slope )],...
%                 ['intercept =' ],...
%                 [num2str(intercept)] ...
%             	['orthogonal slope (DVR)  ='],...
%             	[ num2str( slope2 )]
%                 };
  
            Format='%10.6f';
            positions=12;
            myAnnotation{1}=[ string_pad('',7)  '    ' string_pad('slope(DVR)',positions) string_pad('intercept',positions)];
            for i=1:numberOfROIs 
                myAnnotation{i+1}= [sprintf( roiNames{i}, '%S7') ':   ' ...
                num2str_pad( slope(i),Format,positions ) '   ' ...
                num2str_pad(intercept(i),Format,positions) ...
                ];
            end
 
            
            %text('Position',[0.95,0.4,0],'String',myAnnotation,'Units','normalized','HorizontalAlignment','Left','FontName','FixedWidth')
             % Convert  position from lower corner to upper corner
            pos = get(gca,'Position'); % Position of axes
            x_slack=0.02;
            y_slack=0.02;
            x = pos(1) + x_slack;
            y = pos(2) + pos(4) - 0.10  - y_slack; % Convert from lower corner to upper corner
            annotation('textbox', [pos(1)+0.02,pos(2)+pos(4)-0.12,0.1,0.1],'FontSize', 9, 'String', myAnnotation);

%
% Output to Matlab window
%
            disp('Slope (DVR)=');
            
            s='';
            for i=1:numberOfROIs
                 s=[ s num2str(slope(i),'%7.6f') TAB];
            end
            s=[ s(1:end-1) EOL];
            disp(s);
            
            disp('R2 (DVR)=');
            s='';
            range=startFrame:endFrame;
            for i=1:numberOfROIs
                 s=[ s num2str( R2_linefit( newX(1,i,range), newY(1,i,range), intercept(i), slope(i) ),'%7.6f' ) TAB];
            end
            s=[ s(1:end-1) EOL];
            disp(s);
            
            disp('Slope orthogonal regression 2 (DVR)=');
            s='';
            for i=1:numberOfROIs
                 s=[ s num2str(slope2(i),'%7.6f') TAB];
            end
            s=[ s(1:end-1) EOL];
            disp(s);

            
           
%
% Clean up
%
    clear a answer dataMatrix defaultanswer deltaT duration ...
        intercept k m name newX2 newY2 numlines prompt referenceData roiNames slope  ...
        startFrame tempY time LoganSlope contents endFrame i newX newY  numberOfROIs ...
        TACT i NPixels

