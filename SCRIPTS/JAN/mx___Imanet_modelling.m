%mx___Imanet_modelling.m
%
% Used to set up for modelling using mx2 (modified mx)
% Called from imlook4d/SCRIPT menu
%
% imlook4d_current_handle, imlook4d_current_handles are thus defined.
% 
% Jan Axelsson, 091203
%
% The function of this script is to populate fields needed for Gunnar
% Blomqvists modelling.  The fields are put into struct mxInput.
%
% The following functions hierarchy is called, by the mx2 call:
% mx2                                   (modified version of mx)
%     - a number of modelling routines  (not modified)
%     - mx_SaveMaps2                    (modified version of mx_SaveMaps)

% Hide everything needed in the struct mxInput (in base workspace)


% Export filtered to workspace
   imlook4d('exportAsViewedToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  


% Matrix sizes etc
    numberOfFrames=size(imlook4d_current_handles.image.time,2);

% PET times [s] 
    % mx comment: Get camera time information in suitable format.
    mxInput.PETTimes.start=imlook4d_current_handles.image.time;
    mxInput.PETTimes.end=imlook4d_current_handles.image.time+imlook4d_current_handles.image.duration;
    
    
% Setup model
    % mx comment: Prepare camera data for the model.
    mxInput.ModelCpet = [];
    %ModelCpet = [];
    %ModelCpet = setfield(ModelCpet, 'exprm1_filename', image.header(1).fname);
    %ModelCpet = setfield(ModelCpet, 'exprm1_data', image.data);
    %ModelCpet = setfield(ModelCpet, 'exprm1_time', PETTimes);
    mxInput.ModelCpet = setfield(mxInput.ModelCpet, 'exprm1_filename', 'dcm');   % Use this for writing DICOM
    mxInput.ModelCpet = setfield(mxInput.ModelCpet, 'exprm1_data', imlook4d_current_handles.image.Cdata);  
    mxInput.ModelCpet = setfield(mxInput.ModelCpet, 'exprm1_time', mxInput.PETTimes);

% Get PET matrix
      imlook4d('exportAsViewedToWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Export as viewed
      mxInput.image.data=imlook4d_Cdata;
    
    
% Put some data into "ECAT-like" header
    
    % Time info
        mxInput.image.header(1).mh.ISOTOPE_HALFLIFE=imlook4d_current_handles.image.halflife; % Halflife in s
        mxInput.image.header(numberOfFrames).sh.FRAME_START_TIME=imlook4d_current_handles.image.time(1,numberOfFrames)*1000;    % Time in ms
        mxInput.image.header(numberOfFrames).sh.FRAME_DURATION=imlook4d_current_handles.image.duration(1,numberOfFrames)*1000;  % Duration in ms
    
    % Geometrical info
        mxInput.image.header(1).sh.X_PIXEL_SIZE=imlook4d_current_handles.image.pixelSizeX/10;   % Pixel size in cm
    
    % File info
    
    PC_high=get(imlook4d_current_handles.PC_high_edit,'String');
    PC_low=get(imlook4d_current_handles.PC_low_edit,'String')
    PC_text=[' (PC ' PC_low '-' PC_high ')'];
    
    switch imlook4d_current_handles.image.fileType
        case 'DICOM'
            %mxInput.image.header(1).fname=fileparts( fileparts(imlook4d_current_handles.image.dirtyDICOMFileNames{1}) ); % Directory above DICOM directory
            mxInput.image.header(1).fname=[fileparts( fileparts(imlook4d_current_handles.image.dirtyDICOMFileNames{1}) ) PC_text]; % Directory above DICOM directory
        case 'ECAT'
           %mxInput.image.header(1).fname=get(imlook4d_current_handles.figure1, 'Name');
           [pathstr, name, ext] = fileparts(get(imlook4d_current_handles.figure1, 'Name')); 
           mxInput.image.header(1).fname=[ name PC_text ext] ;
    end
    

% Store info about original imlook4d instance
    mxInput.original_imlook4d_handle=imlook4d_current_handle;
    

% Call mx
    mx2(mxInput);
    
% Finalize
    clear mxInput;
    
