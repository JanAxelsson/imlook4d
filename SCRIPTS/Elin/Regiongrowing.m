% A script that draws a ROI as a continuing volume around a given start
% point. The threshold is given by the user. 

StartScript
historyDescriptor='Ny ROI'; 

 prompt={'Tröskelvärde för ROI'};
        title='Threshold levels';
        numlines=1;
    	defaultanswer={'0'};
   
        

    answer=inputdlg(prompt,title,numlines,defaultanswer);
    
%     if strcmp( answer(end), '%')
%                 threshold=0.01*max(temp(:)) * str2double(maxThresholdLevel(1:end-1)) ;
%     else
%                 threshold= str2double(answer);  % If not percent, then whole string is a number
%     end
        
    threshold=str2double(answer);

    c = ontopMsgbox(imlook4d_current_handle,'Rita en ROI för varje tumör. Varje ROI ska innefatta ett ungefärligt maxvärde på tumören. När du är klar, tryck ok.', 'Hjälptext');
    
    Export
    
    roi=single(zeros(size(imlook4d_ROI)));    
    for i=1:max(imlook4d_ROI(:));
        roi_content=(imlook4d_ROI==i).*imlook4d_Cdata;
        [roi_max, z1]=max(max(max(roi_content)));
        [~, y1]=max(max(roi_content(:, :, z1)));
        [~, x1]=max(max(roi_content(:, :, z1).'));
        roi=roi+regiongrow(imlook4d_Cdata,threshold,x1,y1,z1)*double(i);
    end
    imlook4d_ROI=roi;
    
   

EndScript 