% Plot_DICOM_tag.m
%
% Plots a DICOM tag value over slices for current frame

%
% INITIALIZE
%

    StoreVariables;
    clear val

    disp('SCRIPTS/Plot_DICOM_tag.m entered');
     
         
    % Export to workspace
   % imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace
    Export 
    
    % Set variables
     currentFrame=imlook4d_frame;
     numberOfSlices=size(imlook4d_current_handles.image.Cdata,3);
     
     sortedHeaders=imlook4d_current_handles.image.dirtyDICOMHeader;
     
     mode=imlook4d_current_handles.image.dirtyDICOMMode;
     
     
     
     

%
% RUN
%
    prompt={'Group','Tag'};
            title='DICOM tag';
            numlines=1;
            defaultanswer={'0054', '1300' };
            answer=inputdlg(prompt,title,numlines,defaultanswer);

    for i=1:numberOfSlices
         out=dirtyDICOMHeaderData(sortedHeaders, i+numberOfSlices*(currentFrame-1), answer{1}, answer{2},mode);  
         val(i)=str2num(out.string)
         
         %out.bytes(1)+256*out.bytes(2)
    end

    figure;
    plot(1:numberOfSlices,val);

     
     
 %   
 % FINALIZE
 %

    %clear tempHandle tempHandles
    clear val
    ClearVariables
