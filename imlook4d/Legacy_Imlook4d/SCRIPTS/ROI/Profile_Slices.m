% Profile_Slices.m
%
% This script makes an activity-profile plot using:
%    - the current ROI 
%    - selected frame.
% The plot shows:
%    X-axis: activity
%    Y-axis: slice number
%
% SCRIPT for imlook4d
% Jan Axelsson

% INITIALIZE

    %  imlook4d_current_handles is updated whenever SCRIPTS menu in imlook4d is
    %  selected
    disp('SCRIPTS/Profile_Slices.m entered');
    imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);
    numberOfSlices=size(imlook4d_Cdata,3);
    
    ROINumber=get(imlook4d_current_handles.ROINumberMenu,'Value');
    
    % Preprocess
        binary = zeros(size(imlook4d_ROI));
        binary( imlook4d_ROI== ROINumber)=1;  
        nSlices = sum(max(max(binary)));

        % Loop until first slice with a ROI
        ROISlice=imlook4d_current_handles.image.ROI(:,:,1);  % First ROI slice
        i=0;
        while (i<=numberOfSlices)&&(  size(ROISlice(ROISlice==ROINumber),1)  ==0  )
            i=i+1;
            ROISlice=imlook4d_current_handles.image.ROI(:,:,i);  % New ROI slice
        end    
        
    % CASE 1)  ROI in one slice 
    % CASE 2)  ROI in multiple slices
        if (nSlices == 1)
            % Use same ROI over all slices
            for i=1:numberOfSlices
                temp=imlook4d_Cdata(:,:,i,imlook4d_frame); %Pixels in slice i
                X(i)=i;

                %Y(i)=sum(temp(:));
                tempROI=ROISlice;
                Y(i)=mean(temp(tempROI==ROINumber));
                pixels(i)=sum(tempROI(:)==ROINumber);
                disp([X(i) Y(i) pixels(i)]);

            end
            
        else
            % Use ROI for each slice where it exists

            for i=1:numberOfSlices
                temp=imlook4d_Cdata(:,:,i,imlook4d_frame); %Pixels in slice i
                X(i)=i;

                %Y(i)=sum(temp(:));
                tempROI=imlook4d_current_handles.image.ROI(:,:,i);
                Y(i)=mean(temp(tempROI==ROINumber));
                pixels(i)=sum(tempROI(:)==ROINumber);
                disp([X(i) Y(i) pixels(i)]);

            end
        end
        
        % Remove division by zero in mean, when no pixels in ROI
        Y(isnan(Y))=0
        
    % Display info
        ROINames=get(imlook4d_current_handles.ROINumberMenu,'String')
        disp(['ROI name=' ROINames{ROINumber} '  (ROI number=' num2str(ROINumber) ')']);
        disp(['ROI is in slice number=' num2str(i)]);
    
    

% PLOT Profile 
    figure('Name',['PROFILE: ' get(imlook4d_current_handle,'Name')], 'NumberTitle' ,'off' );

subplot(2,1,1);
    plot(Y)
    xlabel('Slice number')
    ylabel('Activity') 
  %  hold on
    
subplot(2,1,2);
    plot(pixels)
    %hold on
    xlabel('Slice number')
    ylabel('Number of ROI pixels')

    hold off

%
% SAVE 
%
    [file,path] = uiputfile('Profile.xls','Profile-curve: Save file name');
    fullPath=[path file];
    
    tempHeader={'Slice' , 'Activity', 'Pixels'};
    tempHeader=sprintf(['%s' '\t'], tempHeader{:} );  % Tab delimited

    try
        save_cellarray( num2cell([X' double(Y') pixels']), fullPath, tempHeader );
    catch
        disp('You selected not to save Profile curve');  
    end    

% Finish

a=[X' Y' pixels']
clear X Y tempHeader fullPath file path numberOfSlices temp;

% 
% GUIDANCE ON HOW TO CONTROL AN IMLOOK4D INSTANCE FROM SCRIPTS
% ------------------------------------------------------------
%  
% WORK WITH IMLOOK4D INSTANCE IN MATLAB - THE SIMPLE WAY
%
%   1a) imlook4d/SCRIPT menu to make active window handles in workspace:
%       imlook4d_current_handle     handle to imlook4d equivalent to hObject in imlook4d callback functions
%       imlook4d_current_handles    equivalent to handles in this code (This is what you work with)
%
%   1b) imlook4d/Workspace/Export or Import menu to push active window data to workspace or pull from workspace:
%
%         This method applies to common data.  Otherwise methods 2) and 3)
%         below must be used.
%
%         imlook4d_time        vector of frame times (exists only when time data exists)
%         imlook4d_duration    vector of frame duration (exists only when duration data exists)
%         imlook4d_Cdata       4D matrix of image data [x, y, slice,frame]
%         imlook4d_ROI         3D matrix of ROI data [x, y, slice] where the pixel value equals the ROI number (thus, only one ROI possible in each pixel)
%         imlook4d_ROINames    ROI names
%
%         NOT IMPORTED:  imlook4d_frame       current frame
%         NOT IMPORTED:  imlook4d_slice       current slice
%         NOT IMPORTED:  imlook4d_current_handle     handle to imlook4d equivalent to hObject in imlook4d callback functions
%         NOT IMPORTED:  imlook4d_current_handles    equivalent to handles in this code (This is what you work with)
%
%   2) Example:  Modify handles.image.CachedImage from matlab workspace
%       imlook4d_current_handles.image.CachedImage=1000;
%
%   3) Save changed handles to current Imlook4d instance.  This call
%      attaches the modified imlook4d_current_handles to the current imlook4d
%      instance: 
%       guidata(imlook4d_current_handle, imlook4d_current_handles)
%
%
% CALL FUNCTIONS FROM SCRIPT
%
% This applies to calling a function in the current imlook4d instance.
% Relevant examples are calling the Export and Imports from workspace via
% their respective menu callback functions.
%
% EXPORT from current imlook4d
%    imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles); % Exports to workspace from current imlook4d instance
%
% IMPORT to new imlook4d  
%     tempHandle=imlook4d;  % New imlook4d instance
%     tempHandles=guidata(tempHandle);
%     imlook4d('importFromWorkspace_Callback', tempHandle,{},tempHandles);   % Import from workspace
%
