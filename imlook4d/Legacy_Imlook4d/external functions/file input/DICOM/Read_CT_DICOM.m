%
%     Read_CT_DICOM
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


function [Data, header]=Read_CT_DICOM(directoryPath);


%
% INITIALIZE
%
    
    disp2('START Read_CT_DICOM');
    
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
    tic;
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

                %Save in struct following Annas Ringheims method in First Matlab web server
                outstructfield = filename_noext;
                if ~isempty(str2num(outstructfield(1)))
                    outstructfield = ['x' outstructfield];  %If the field starts with a number add an x before the name.(AR 17/1-06)
                end
                

                % Accept only CT modality
                if ( strcmp(TempHeader.Modality,'CT')...
                        &&( strcmp(TempHeader.ScanOptions, 'HELICAL MODE')|strcmp(TempHeader.ScanOptions, 'CINE MODE')   ) ...
                )
                    header=setfield(header,outstructfield,TempHeader);
                    data=setfield(data,outstructfield,TempVol);
                    disp2([TAB 'Accepting ' TempHeader.Modality '(' TempHeader.ScanOptions ')  file=' sTempFilenameStruct(nr).name]);
                else
                    disp2([TAB 'Ignoring ' TempHeader.Modality '(' TempHeader.ScanOptions ')  file=' sTempFilenameStruct(nr).name]);
                end
                %disp2(TempHeader.Modality);

                % Update waitbar step, (and replace \ with \\ in disp2layed % path)
                waitbar(nr/iNumberOfSelectedFiles,waitBarHandle,['Reading DICOM file=' strrep(filename, '\', '\\')]); 
                
            catch % Error handling
                disp2([TAB 'ERROR Ignoring file=' sTempFilenameStruct(nr).name]);
            end
        end
        disp2([' Time for ReadCT using Matlab DICOM reader =' num2str(toc) ' s.']);
        % Scale data and put into 4D matrix
        Data=scaleDICOMmatrixCT(header,data);
        
     %Loop Jans test functions for individual files
     tic;
        for nr=1:iNumberOfSelectedFiles  %Ignore directories '.' and '..'
            try    
                filename = [directoryPath sTempFilenameStruct(nr).name];
                fid = fopen(filename, 'r');
                A{nr} = fread(fid);     % Binary file in memory  
                fclose(fid);
                disp2([TAB 'Accepting file=' sTempFilenameStruct(nr).name]);
                        
            catch % Error handling
                disp2([TAB 'ERROR Ignoring file=' filename]);
            end

        end
        disp2([' Time for ReadCT using Jans test  =' num2str(toc) ' s.']);
        
        
%
% FINALIZE
%
    close(waitBarHandle);			% Close waitbar
    
%     % Write summary
%     header_field_names=fieldnames(header);
%     
%     disp2('SUMMARY of Read_PET_DICOM, based on first file');
%     disp2([TAB 'Patient='  header.(header_field_names{1}).PatientName.FamilyName ]);   
%     disp2([TAB 'PatientID='  header.(header_field_names{1}).PatientID ]);   
%     disp2([TAB 'File format='  header.(header_field_names{1}).Format ]);
%     disp2([TAB 'Modality='  header.(header_field_names{1}).Modality ]);
%     disp2([TAB 'Study='  header.(header_field_names{1}).StudyDescription ]);   
%     disp2([TAB 'Series='  header.(header_field_names{1}).SeriesDescription ]);  
%     
%     % Save Data and header as .mat file
%     name=[header.(header_field_names{1}).StudyDescription '(' header.(header_field_names{1}).SeriesDescription ').mat'];
%     name=strrep(name, ':','');  % Remove ':'
%     
%     try
%         [file,path] = uiputfile( name ,'Save as .mat file (much faster load into matlab)');
%         fullPath=[path file];
%         fullPath=[ header.(header_field_names{1}).StudyDescription '(' header.(header_field_names{1}).SeriesDescription ').mat']
%         
%         disp2([TAB 'Writing matlab-file='  fullPath ]);  
%         %disp2([TAB TAB  path file ]);
%         save(fullPath, 'Data', 'header');
%     catch
%         disp([TAB 'Save Data was not completed']);
%     end

    Save_DICOM_to_mat(Data, header);

    
    disp2('END Read_CT_DICOM');
    %imlook4d(Data);
 