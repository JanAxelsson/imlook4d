function write_sif( handles, filePath)

    % Bail out if default times (0,1,2...)
    defaultTimes = 0:size(handles.image.Cdata,4) -1; % If no sif-file was present when opened nifti
    if isequal( handles.image.time, defaultTimes)
        disp([ 'Skip writing .sif file, because default time information (times= 0,1,2, ...) indicates time-information no known' ]);
        return
    else
        disp([ 'Writing .sif file = ' filePath ]);
    end

    % Initiate
    roiNames=get(handles.ROINumberMenu,'String');
    roiNames=roiNames(1:end-1);

    frameNumbers=1:size(handles.image.Cdata,4);
    timeScale = handles.image.time';
    duration = handles.image.duration';
    


    % Turku sif file

    % Simplified sif file, from one ROI

    % Header info
    scan_start_time = 'xx/xx/xxxx xx:xx:xx'
    number_of_frames = size( handles.image.Cdata,4);
    number_of_columns = 2 + length(roiNames) ;
    SIF_version = '1';
    study_ID = 'xxxx';
    isotope = 'X-XX';


    % If activity exists, use it, otherwise create empty
    try
        activity = handles.TACT.tact;
    catch
        activity = zeros(number_of_frames, length(roiNames) );
    end
    
    if (  size(activity,2) == 1 )
        activity = [ activity activity ];  % Sif seems to require 4 columns (minimum)
        number_of_columns = 2 + size(activity,2) ;
    end

    tactHeader=[sprintf(['%s' '\t'], scan_start_time, num2str(number_of_frames), num2str(number_of_columns), SIF_version, study_ID, isotope) ];
    tactHeader=tactHeader(1:end-1); % Remove last TAB

    unitFactor = 1; % Do nothing

    save_cellarray( num2cell([ timeScale (timeScale+duration) unitFactor*double(activity) ]), filePath, tactHeader );

