    % Start script
   % Store variables (so we can clear all but these)
    StoreVariables;

    % Make a duplicate to work on
    Export              % Export variables

    historyDescriptor='Summed frames'; % Make a descriptor to prefix new window title with
    
        prompt={'Number of frames to sum'};
        title='Sum frames';
        numlines=1;
        defaultanswer={'2'};
        %defaultanswer={har( mainHeader(296+1:296+32))',...
        %        char( mainHeader(434+1:434+10))'};
        answer=inputdlg(prompt,title,numlines,defaultanswer);


% 
% PROCESS
%
    % Reformat data (sum frames) 
        no_frames=size(imlook4d_Cdata, 4)/str2num(answer{1});
        sumed_frames=str2num(answer{1});
        summedData=zeros(size(imlook4d_Cdata,1),size(imlook4d_Cdata,2),size(imlook4d_Cdata,3), no_frames);
        
        startTime=imlook4d_time(1);
        disp(['SCRIPTS/SumFrames startTime=' num2str(startTime)]);

%         try                     
%            %  Integrate decay-corrected data 
% 
%            summedDuration=0;
%            for j=range
%                 summedData=summedData+imlook4d_Cdata(:,:,:,j)*imlook4d_duration(j);
%                 summedDuration=summedDuration+imlook4d_duration(j);
%                 %disp(j);
%             end
%             summedData=summedData/summedDuration;
%             disp(['SCRIPTS/SumFrames duration=' num2str(summedDuration)]);
% 
%         catch
%             disp(['SUM ERROR']);
%         end

        
        % SUM FRAMES
        
        time=imlook4d_time;
        duration=imlook4d_duration;
        
        %summedData=zeros(size(Data,1), size(Data,2),size(Data,3));

        % Sum frames over range
        Data=imlook4d_Cdata;
        
        halflife=imlook4d_current_handles.image.halflife;
        
                                        
           disp('Summing Method 4');
           summedDuration=zeros(1, no_frames);
           DecayCorrectionFactor=zeros(1, no_frames);
           for k=1:size(Data, 4)
               for l = 1:sumed_frames
                   for j=1:sumed_frames
                        Data(:,:,:,k)=Data(:,:,:,k)*(2^(-( time(k) +0.5*duration(k)) /halflife));  % Undo decay-correction to start of scan OBS! SE ÖVER TIDEN!
                        %Data(:,:,:,j)=Data(:,:,:,j)*(2^(-( time(j) +0.0*duration(j)) /halflife));  % Undo decay-correction
                        summedData(:, :, :, l)=summedData(:, :, :, l)+Data(:,:,:,j)*duration(j); 
                        summedDuration(l)=summedDuration(l)+duration(j);
                        summedData(:, :, :, l)=summedData(:, :, :, l)/summedDuration(l);  % summedData is now mean value in mid frame
                        DecayCorrectionFactor(l)=2^(( time(k)+ 0.5*summedDuration(l))/halflife); %OBS! SE ÖVER TIDEN
                        summedData(:, :, :, l)=summedData(:, :, :, l)*DecayCorrectionFactor(l);   %Decay corrected summedData
                   end
               end
            

            
           end
             
    % Update frame times
        %imlook4d_time=imlook4d_time(1);
        imlook4d_duration=summedDuration;

    
    % Finish script
    EndScript
