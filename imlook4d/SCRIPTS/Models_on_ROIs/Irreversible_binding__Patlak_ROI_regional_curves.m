% Patlak_ROI_regional_curves.m   
%
% SCRIPT for imlook4d to display TACT with PATLAK axes from a dynamic image.
% Works in dynamic image mode (not static, or when in Patlak model mode).
%
% Jan Axelsson

    ExportUntouched
    waitfor( patlak_control(imlook4d_current_handle,[], imlook4d_current_handles));
    ExportUntouched
    imlook4d_current_handles.model.functionHandle=[];
    guidata(imlook4d_current_handle, imlook4d_current_handles);

%
% Initialize
%
    startFrame = imlook4d_current_handles.model.Patlak.startFrame;
    endFrame = imlook4d_current_handles.model.Patlak.endFrame;
    referenceData=imlook4d_current_handles.model.Patlak.referenceData;
    
    contents = get(imlook4d_current_handles.ROINumberMenu,'String'); % Cell array 
    roiNames = contents;

    numberOfROIs=size(contents,1)-1;

%
% TACT  [ROI nr, frames]
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
% (that is, you are not allowed to be in Patlak
% model either because the Patlak image is a static image)
%
    %size(TACT,2);
    if ( size(TACT,2)==1)
         msgbox({'A dynamic sequence is needed (Patlak gives a static image)!'  ' '...
             'Useage:' ...
             '1) Enter PATLAK model and input a reference curve from current ROI' ...
             '2) Leave PATLAK' ...
             '3) Select "no model"' ...
             '4) Run this script again'},...
             'ERROR in SCRIPT',...
             'error'); 
    end
   
    
%
% Calculate Patlak axes
%

    % new Y axes
    for i=1:endFrame
        newY(:,i)=TACT(:,i)./imlook4d_current_handles.model.Patlak.referenceData(i);
        %newY(:,i)=TACT(:,i);
    end

    % new X axes
    for i=1:endFrame
            % integral{C(a)}
            counts(i)=imlook4d_current_handles.model.Patlak.referenceData(i)*imlook4d_current_handles.image.duration(i);   % Counts= C(a)*duration
            %newX(i)=sum(counts(1:i));                 % Integrate
            newX(i)=sum(counts(1:i)) + imlook4d_current_handles.model.Patlak.integralOffset;% Add integral that was before this scan
            disp(['i=' num2str(i) '   counts=' num2str(counts(i)) '   newX=' num2str(newX(i))  '   newY=' num2str(newY(1,i)) ]);
            % integral{C(a)}/C(a)
            newX(i)=newX(i)/imlook4d_current_handles.model.Patlak.referenceData(i);         % Divide by C(a)
            disp(['i=' num2str(i) '   counts=' num2str(counts(i)) '   newX=' num2str(newX(i))  '   newY=' num2str(newY(1,i)) ]);
    end

%
% Plot
%
    figure('NumberTitle','off',...
        'Name', ['Regional Patlak: ' get(imlook4d_current_handles.figure1,'Name')] );
    
    for i=1:numberOfROIs
        disp(i)
        % Plot current ROI
           try
                plot( newX, newY(i,:) , 'o', 'MarkerSize',3);
                hold all
                %xlabel('Normalized time $$\int_{0}^{t} C_a dt /C_a$$ [min]');
                %xlabel('Normalized time $$\int_{0}^{t} C_a dt /C_a$$','interpreter','latex');
                %xlabel('Normalized time \int_{0}^{t} C_a dt /C_a');
                xlabel('Normalized time \int_{0}^{t} C_a dt /C_a [min]');
                ylabel('Normalized intensity (ROI/Ca)');
                
                title(['Patlak for ROIs in ' get(imlook4d_current_handles.figure1,'Name')]); 
                

           catch
               warning('Error in plot of Patlak plot');
           end

    end
    
    
    
%         
% %
% % Enter range for straight line fit
% %
%     % Dialog option
%             prompt={'Enter low frame number:','Enter high frame number:' };
%             name='Enter low and high frame';
%             numlines=1;
%             defaultanswer={'1' num2str(size(newY,2 ))  };
%             answer=inputdlg(prompt,name,numlines,defaultanswer);
%             
%             startFrame=str2num(answer{1});
%             endFrame=str2num(answer{2});
    
%
% Fit straight lines (and plot)
%

   

   newX=newX(startFrame:endFrame);
   newX=newX(:);

   for i=1:numberOfROIs
            tempY=newY(i,startFrame:endFrame);  % All frames
            tempY=tempY(:);
            
            %coefficients = polyfit(newX(:),tempY(:),1); % SLOW            
            coefficients=[newX ones(length(newX),1) ] \ tempY;  % Backslash operator
            k=coefficients(1)
            m=coefficients(2)
            
            slope(i)=k;
            
            plot( [newX(1) newX(end)], [m+k*newX(1) m+k*newX(end)]);  % Plot straight line
   end
   
   
   % Prepare for annotation
    Format='%10.6f';
    positions=12;
    myAnnotation{1}=[ string_pad('',7)  '    ' string_pad('slope(K)',positions) string_pad('intercept',positions)];
   
      
   % Find line styles 
   h=gca;
   children = get(h, 'Children');
   
   % Plot lines
   for i=1:numberOfROIs
%        disp(i)
%         newX2=newX(1,i,startFrame:endFrame);
%         
%         k=slope(i);
%         m=intercept(i);

        
            tempY=newY(i,startFrame:endFrame);  % All frames
            tempY=tempY(:);
            
            %coefficients = polyfit(newX(:),tempY(:),1); % SLOW            
            coefficients=[newX ones(length(newX),1) ] \ tempY;  % Backslash operator
            k=coefficients(1)
            m=coefficients(2)
        
        %xValues=[0 newX2(end)];
        %yValues=[m m+k*newX2(end)];
        xValues=[ newX(1) newX(end)];
        yValues=[ (m+k*newX(1)) (m+k*newX(end))];  
        %xValues2=[ 0 newX2(end)];
        %yValues2=[ m2 m2+k2*newX2(end)];      

        color = get( children( 1 + numberOfROIs - i),'Color');  % Reverse order on lines contra markers
        set( children( 1 + numberOfROIs - i), 'MarkerFaceColor', color);  % Make solid 
        plot( xValues, yValues, 'Color', color );  % Plot straight line
        
        % Build annotation 
        myAnnotation{i+1}= [sprintf( contents{i}, '%S7') ':   ' ...
                num2str_pad( k,Format,positions ) '   ' ...
                num2str_pad(m,Format,positions) ...
                ];
   end
   
%
% Annotate 
%
            pos = get(gca,'Position'); % Position of axes
            x_slack=0.02;
            y_slack=0.02;
            x = pos(1) + x_slack;
            y = pos(2) + pos(4) - 0.10  - y_slack; % Convert from lower corner to upper corner
            annotation('textbox', [pos(1)+0.02,pos(2)+pos(4)-0.12,0.1,0.1],'FontSize', 9, 'String', myAnnotation);
            

%
% Add legend to TACT curve
%

    % Number of pixels
    for i=1:numberOfROIs 
        contents{i}=[contents{i} ' (' num2str(NPixels(i)) ' pixels)' ]; % Add pixel count to legend
    end
    legend(contents(1:end-1));
    
    
%
% Output to Matlab window
%
            disp('Patlak Slope (K)=');
            
            % ROI names
            s='';
            for i=1:numberOfROIs
                 s=[ s roiNames{i} TAB];
            end
            s=[ s(1:end-1) ];
            disp(s);
            
            % Slope values
            s='';
            for i=1:numberOfROIs
                 s=[ s num2str(slope(i),'%7.6f') TAB];
            end
            s=[ s(1:end-1) EOL];
            disp(s);

    
    

%
% Clean up
%
    clear NPixels TACT contents counts endFrame i newX newY numberOfROIs
    clear answer  coefficients  defaultanswer  k  m  name  numlines  prompt  startFrame  tempY
