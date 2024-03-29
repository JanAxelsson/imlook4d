% % Copy_ROI.m
%
% This script copies a ROI (from current slice) to specified slices

% SCRIPT for imlook4d
% Jan Axelsson

% INITIALIZE
    StoreVariables

    %  imlook4d_current_handles is updated whenever SCRIPTS menu in imlook4d is
    %  selected
    disp('SCRIPTS/Profile_Slices.m entered');
    imlook4d('exportToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);
    numberOfSlices=size(imlook4d_Cdata,3);
    
    ROINumber=get(imlook4d_current_handles.ROINumberMenu,'Value');

    % Loop until first slice with a ROI
        ROISlice=imlook4d_current_handles.image.ROI(:,:,1);  % First ROI slice
        i=0;
        while (i<=numberOfSlices)&&(  size(ROISlice(ROISlice==ROINumber),1)  ==0  )
            i=i+1;
            ROISlice=imlook4d_current_handles.image.ROI(:,:,i);  % New ROI slice
        end    
        sliceNumberWithROI=i;
    
    % Use current slice if the ROI is present
        if (size(ROISlice(ROISlice==ROINumber),1) >0)
            ROISlice=imlook4d_current_handles.image.ROI(:,:,imlook4d_slice);  % New ROI slice
        end
        
    % Display info
        ROINames=get(imlook4d_current_handles.ROINumberMenu,'String')
        disp(['ROI name=' ROINames{ROINumber} '  (ROI number=' num2str(ROINumber) ')']);
        disp(['ROI is in slice number=' num2str(i)]);
    
    % Dialog
        prompt={ 'First destination slice  [Use: 1) slice number,or 2) relative slice, e.g. -10 ].',...
                'Last destination slice', ...
                'Destination ROI (which ROI number the copied ROI will land in)'};
        title='Copy ROI';
        numlines=1;
        defaultanswer={'1','end',num2str(ROINumber)};
        answer=inputdlg(prompt,title,numlines,defaultanswer);

        if isempty(answer) 
            % User clicked cancel. Bail out. 
            ClearVariables
            return; 
        end 
        
        answer=makeAbsoluteSliceNumber(answer, imlook4d_slice, size(imlook4d_Cdata,3)); % Handle Relative or Absolute positions
        
        firstSlice=str2num(answer{1});
        lastSlice=str2num(answer{2});
        
        if strcmp('end', strtrim(answer{2}) )
            lastSlice=size(imlook4d_Cdata,3);
        end
        
        destinationROINumber=str2num(answer{3});
    

% Copy ROI
    %indecesToROI=find(imlook4d_ROI==ROINumber);
    indecesToROICopiedSlice=find(ROISlice==ROINumber);
    offset=size(imlook4d_ROI,1)*size(imlook4d_ROI,2);
    newROI=zeros(size(imlook4d_ROI),'uint8');
    for i=firstSlice:lastSlice
        newROI(indecesToROICopiedSlice+ offset*(i-1) )=destinationROINumber; %OR with existing ROI
    end
    
        
    % Make matrix of locked pixels
    lockedMatrix = zeros( size(imlook4d_ROI) ,'logical'); % Assume all locked
    numberOfROIs = length( imlook4d_current_handles.image.LockedROIs );
    for i=1:numberOfROIs
        lockedMatrix(imlook4d_ROI == i ) = imlook4d_current_handles.image.LockedROIs(i); % Pixels = 0 if locked, 1 if not locked
    end
    
    newROI( lockedMatrix) = 0; % Remove pixels that are locked from newROI
    
    
%     % Add pixels to new ROI
    imlook4d_ROI=imlook4d_ROI - uint8(newROI>0).*imlook4d_ROI ;   % Remove existing ROI pixels that overlap new ROI
    imlook4d_ROI=imlook4d_ROI + uint8(newROI>0).*newROI;          % Add new ROI pixels


% Finish
Import
ClearVariables

