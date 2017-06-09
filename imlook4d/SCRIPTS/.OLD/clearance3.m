%
% Clearance3
%
% Works on variables exported from imlook4d
%


% INITIALIZE
    imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export to workspace

    Data=imlook4d_Cdata;
    
    slices=imlook4d_slice;  % Use current slice
   % slices=1:size(Data,3);  % Use all slices
    
    firstFrame=imlook4d_frame;
    lastFrame=size(Data,4);
    
    firstFrame=23;
    lastFrame=28;
    
    %firstFrame=28;
    %lastFrame=32;
    
    level=0.4;                          % Fraction of maximum, to keep.
    

% EXTRACT SLICE AND FRAMES TO WORK ON

    disp('Filtering data');
    %Data=PCAFilter( Data, 1, 5);               % Do PCA-filter using whole data set
    Y=Data( :,:,slices,firstFrame:lastFrame);   % Put data to use in Y
    
    iPixels=size(Y,1);
    jPixels=size(Y,2);

    X=imlook4d_time(firstFrame:lastFrame);

% CALCULATE CLEARANCE

    % Loop pixels, for selected slices
    
    disp('Calculating clearance images');
    

    for iz=slices %Loop slices
        
        tempImage=Data(:,:,iz,lastFrame);% Last frame, current slice
        threshold=level*max(tempImage(:));
        disp(['Slice=' num2str(iz) '    Threshold level=' num2str(threshold) ]);
        
        for i=1:iPixels
            for j=1:jPixels

                Ytemp=Y(i,j,iz,:);   % Only plot if lowest value is above threshold (as set from level, and max pixel value from last frame)

                if (min(Ytemp)> threshold)  % Only do this when high activity (low activity can create any slope due to scattered data)
                    %b = polyfit(X(:),log(Ytemp(:)-threshold+1),1); % Version where background is subtracted
                    b = polyfit(X(:),log(Ytemp(:)),1);             % Version where log is taken straight

                    pars(i,j,iz,:)=b;
                else
                    pars(i,j,iz,:)=[0,0];
                end

            end
        end
    end


    % Display 

    %pars(:,:,1)=pars(:,:,1)-(pars(:,:,1)>0).*pars(:,:,1);                               % Replace positive slopes with zeros
    %h=figure;imagesc(-real(pars(:,:,1))*60);colorbar;
    h=imlook4d(-real(pars(:,:,:,:))*60);    % Last index=1 gives slope, last index=2 gives offset


 % MODIFY DISPLAY TO OVERLAP IMLOOK4D DISPLAY
    %set( get(h, 'CurrentAxes'), 'Units', 'pixels');                         % Set units to "pixels"
    %set(get(h, 'CurrentAxes'), 'Position', [41.4300   35.5400  256  256]);  % Drawing dimensions
    %tempPosition=get(imlook4d_current_handle,'Position')                    % Position of imlook4d window
    
    set(h, 'Name',['level=' num2str(level) '   threshold=' num2str(threshold) '   frames=' num2str(firstFrame) '-' num2str(lastFrame) '   slice=' num2str(imlook4d_slice)]);    % Name window
    %set(h, 'Position',[tempPosition(1)-16 tempPosition(2)+63 400 320] );    % Position window
    
       
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
