%
%     Read_PET_DICOM
%
%     Purpose:  Read GE PET Dicom data into 4D matrix, and header structure
%
%     Author: Jan Axelsson, Anna Ringheim (based on her method for Matlab Webserver)
%
%     Input:        - directoryPath
%
%     Output:     	- 4D matrix  [X x Y x M * T] with image size X x Y with M slices and T frames.
%                   - header structure
%
%     Example:
%                   [matrix, header]=Read_PET_DICOM('D:\ISGARS\0')
%


function [Data, header]=Read_PET_DICOM(directoryPath);


%
% INITIALIZE
%
    
    disp2('START Read_PET_DICOM');
    
    % Standard initialization
    TAB=sprintf('\t');
    
    % Setup structs
    dcmfile = [];
    header=[];
    data=[];
    TempHeader = [];
    TempVol = [];
    
    % Fix directory path so that it always ends with \
    directoryPath=strrep( [directoryPath '\'] , '\\', '\'); %Add \ at end of path. Change to \ if \\ 
    
    % Waitbar
    waitBarHandle = waitbar(0,'Reading DICOM files');	% Initiate waitbar with text

%
% INPUT DICOM FILES
%
    
    %Find all files in directory
        %sTempFilenameStruct=dir([InpPath '\*.dcm']);
        sTempFilenameStruct=dir([directoryPath]);
    
    %Get number of selected files.
        iNumberOfSelectedFiles = length(sTempFilenameStruct);
    
 
    %Loop DICOM functions for individual files
        for nr=1:iNumberOfSelectedFiles  %Ignore directories '.' and '..'
            try
                filename = [directoryPath sTempFilenameStruct(nr).name];


                [dummy,filename_noext,ext] = fileparts(sTempFilenameStruct(nr).name);

                TempHeader = dicominfo(filename);
                TempVol = dicomread(TempHeader);
                
                disp2(['Max=' num2str(max(TempVol(:))) '    Min=' num2str(min(TempVol(:)))])
        
                %Save in struct following Annas Ringheims method in First Matlab web server
                outstructfield = filename_noext;
                if ~isempty(str2num(outstructfield(1)))
                    outstructfield = ['x' outstructfield];  %If the field starts with a number add an x before the name.(AR 17/1-06)
                end
                header=setfield(header,outstructfield,TempHeader);
                data=setfield(data,outstructfield,TempVol);

                % Update waitbar step, (and replace \ with \\ in disp2layed % path)
                waitbar(nr/iNumberOfSelectedFiles,waitBarHandle,['Reading DICOM file=' strrep(filename, '\', '\\')]); 
                 disp2([TAB ' file=' sTempFilenameStruct(nr).name]);
                 
            catch % Error handling
                disp2([TAB 'Ignoring file=' sTempFilenameStruct(nr).name]);
                disp2(lasterror)
            end
        end
        

        
        % Scale data and put into 4D matrix
        try
            Data=scaleDICOMmatrix(header,data);
        catch % Error handling
            Data=data;  % Keep unscaled data
            disp(['ERROR in header- Scaling not performed' sTempFilenameStruct(nr).name]);
        end
        %disp2(['Max=' num2str(max(Data(:))) '    Min=' num2str(min(Data(:)))])        
%
% FINALIZE
%

    
    % Write summary
    header_field_names=fieldnames(data);
    try
        disp2('SUMMARY of Read_PET_DICOM, based on first file');
        disp2([TAB 'Patient='  header.(header_field_names{1}).PatientName.FamilyName ]);   
        disp2([TAB 'PatientID='  header.(header_field_names{1}).PatientID ]);   
        disp2([TAB 'File format='  header.(header_field_names{1}).Format ]);
        disp2([TAB 'Modality='  header.(header_field_names{1}).Modality ]);
        disp2([TAB 'Study='  header.(header_field_names{1}).StudyDescription ]);   
        disp2([TAB 'Series='  header.(header_field_names{1}).SeriesDescription ]);  
    catch
        disp2(['ERROR in header - could not find one of the patient, modality, study or series tags']);
    end
    
    % Save Data and header as .mat file
%     try
%         %JAN[file,path] = uiputfile([header.(header_field_names{1}).StudyDescription '(' header.(header_field_names{1}).SeriesDescription ').mat'] ,'Save as .mat file (much faster load into matlab)');
%         %JANfullPath=[path file];
%         fullPath=[ header.(header_field_names{1}).StudyDescription '(' header.(header_field_names{1}).SeriesDescription ').mat']
%         
%         disp([TAB 'Writing matlab-file='  fullPath ]);  
%         %disp2([TAB TAB  path file ]);
% 
%         try
%             [time, duration]=timeFromDICOMInput(header);
%             save(fullPath, 'Data', 'header','time', 'duration');
%         catch
%             disp('Error: time and duration not extracted properly');
%             save(fullPath, 'Data', 'header');
%             disp('Error: saved only Data, header');
%         end
%         
%         
%     catch
%         disp([TAB 'Save Data was not completed']);
%     end

    Save_DICOM_to_mat(Data, header);

    close(waitBarHandle);			% Close waitbar
    disp2('END Read_PET_DICOM');
 