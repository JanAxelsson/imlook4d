% Remove_Images.m
%
% This script removes frames of slices
% so that the summed frame is equivalent to the frame a long acquisition would get.
% Frame times and durations are correct
%
%
% SCRIPT for imlook4d
% Jan Axelsson

% INITIALIZE

    StartScript

    % Get user input
    prompt={'Slides to keep',...
                'Frames to keep'};
        title='Remove images from matrix';
        numlines=1;
        defaultanswer={['1:' num2str(size(imlook4d_Cdata,3))], ['1:' num2str(size(imlook4d_Cdata,4))]};
        answer=inputdlg(prompt,title,numlines,defaultanswer);
        
        sliceRange=str2num(answer{1});
        frameRange=str2num(answer{2});


% 
% PROCESS
%
    % Reformat matrix
        temp=imlook4d_Cdata(:,:,sliceRange,frameRange);
        imlook4d_Cdata=temp;
        
        imlook4d_ROI=imlook4d_ROI(:,:,sliceRange);
        
        % Fix data in handles.image struct
        % Set new slice position
        try
            imlook4d_current_handles.image.imagePosition = imlook4d_current_handles.image.imagePosition{sliceRange};
        catch
        end
        
        try
            imlook4d_current_handles.image.sliceLocations=imlook4d_current_handles.image.sliceLocations(sliceRange);  % This one is probably wrong - but scale factor is corrected when saving image.  Scale factor is not used anywhere because Cdata stores float data.
        catch
        end
        
        try
            % Modify outputImageStruct - Matlab Cells
            imlook4d_current_handles.image.dirtyDICOMHeader={ imlook4d_current_handles.image.dirtyDICOMHeader{sliceRange} };
        catch
        end
        
        try
            imlook4d_current_handles.image.dirtyDICOMFileNames={ imlook4d_current_handles.image.dirtyDICOMFileNames{sliceRange} };
        catch
        end
        
        try
            imlook4d_current_handles.image.dirtyDICOMIndecesToScaleFactor={ imlook4d_current_handles.image.dirtyDICOMIndecesToScaleFactor{sliceRange} };  % This one is probably wrong - but scale factor is corrected when saving image.  Scale factor is not used anywhere because Cdata stores float data.
        catch
        end
        
        try
            imlook4d_current_handles.image.DICOMsortedIndexList=imlook4d_current_handles.image.DICOMsortedIndexList(sliceRange,:);
        catch
        end

        
    % Fix times 
    try
        imlook4d_time=imlook4d_time(1, frameRange);
        imlook4d_duration=imlook4d_duration(1, frameRange);
    catch
    end
        try
            imlook4d_current_handles.image.time2D=imlook4d_current_handles.image.time2D( sliceRange, frameRange);
            imlook4d_current_handles.image.duration2D=imlook4d_current_handles.image.duration2D(sliceRange, frameRange);
        catch
        end
        
    %   
    % FINALIZE
    %
    
            
        % Set window name    
            oldName=get(imlook4d_current_handle,'Name');            
            WindowTitle([ 'Truncated - ' oldName ]);

        % Import and clear up
            EndScript
