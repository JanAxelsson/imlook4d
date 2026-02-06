%
%     Write_PET_DICOM
%
%     Purpose:  Read GE PET Dicom data into 4D matrix, and header structure
%
%     Author: Jan Axelsson
%
%     Input:        - directoryPath
%                   - 4D matrix  [X x Y x M * T] with image size X x Y with M slices and T frames.
%                   - header structure
%
%     Example:
%                   Write_PET_DICOM('D:\ISGARS\', matrix, header)
%


function Write_PET_DICOM(directoryPath, Data, header);


%
% INITIALIZE
%
    
    disp2('START Write_PET_DICOM');
    
    % Standard initialization
    TAB=sprintf('\t');
    
    % Fix directory path so that it always ends with \
    directoryPath=strrep( [directoryPath '\'] , '\\', '\'); %Add \ at end of path. Change to \ if \\ 
    
    % Waitbar
    waitBarHandle = waitbar(0,'Writing DICOM files');	% Initiate waitbar with text

    
%
% OUTPUT DICOM FILES
%

    
    %Get number of selected files.
        iNumberOfSelectedFiles = size(fieldnames(header),1);
        
    %Get all the file names (used to reference the dicom header in the "header" struct
        header_field_names=fieldnames(header);
    
 
    %Loop DICOM headers
        for i=1:iNumberOfSelectedFiles 
                 try

                        dcmInfo=header.(header_field_names{i});    % DICOM header for current file
                        fileName=dcmInfo.Filename;                  % FileName for current file

                        [dummy,filename_noext,ext] = fileparts(fileName);   % FileName for current file, excluding path and extensions

                        slice=dcmInfo.Private_0009_10a6;
                        frame=dcmInfo.Private_0009_10d8;


                        % CALCULATE RESCALE SLOPE

                              %Calculate scale factor
                            imageMatrix=Data(:,:,slice,frame);
                            absmaxval = max(abs(imageMatrix(:)));  %Maximum absolute value in frame.
                            scale_factor = absmaxval/32767;
                             

                            %Normalisation
                            imageMatrix = imageMatrix/scale_factor;  %Divide by scale factor
                            minv = min(imageMatrix(:));
                            maxv = max(imageMatrix(:));
                            
                            disp(['min=' num2str(minv) '   max=' num2str(maxv) '    scale_factor=' num2str(scale_factor) ]);

                            %Write DICOM tags
                            %dcmInfo.RescaleSlope=dcmInfo.RescaleSlope/scale_factor;    %New rescale slope
                            
                             dcmInfo.RescaleSlope=scale_factor;    %New rescale slope
                             dcmInfo.SmallestImagePixelValue=minv;   %Smallest value
                             dcmInfo.LargestImagePixelValue=maxv;    %Largest value



                        % Write with private tags   
                        dcmInfo=rmfield(dcmInfo, 'LossyImageCompression'); % BUG i MATLAB DICOM
                        %dicomwrite(Data(:,:,slice,frame), fileName, dcmInfo, 'CreateMode', 'copy');
                        %dicomwrite(imageMatrix, [directoryPath filename_noext ext], dcmInfo, 'CreateMode', 'copy');
                        %dicomwrite(imageMatrix, [directoryPath filename_noext ext], dcmInfo, 'CreateMode', 'copy', 'Endian', 'Little');
                        dicomwrite(imageMatrix, [directoryPath filename_noext ext], dcmInfo, 'CreateMode', 'copy');
                        
                        % Update waitbar step, (and replace \ with \\ in displayed % path)
                        waitbar(i/iNumberOfSelectedFiles,waitBarHandle,['Writing DICOM file=' filename_noext ext]); 

                    catch % Error handling
                        disp([TAB 'Catching error in fileName=' filename_noext ext ]);
                        disp([TAB TAB  ' ERROR=' lastwarn]);
                    end
            end

        
%
% FINALIZE
%
    close(waitBarHandle);			% Close waitbar
    
%     % Write summary
%     header_field_names=fieldnames(data);
%     
     disp('SUMMARY of Read_PET_DICOM, based on first file');
     disp([TAB 'Patient='  header.(header_field_names{1}).PatientName.FamilyName ]);   
     disp([TAB 'PatientID='  header.(header_field_names{1}).PatientID ]);   
     disp([TAB 'File format='  header.(header_field_names{1}).Format ]);
     disp([TAB 'Modality='  header.(header_field_names{1}).Modality ]);
     disp([TAB 'Study='  header.(header_field_names{1}).StudyDescription ]);   
     disp([TAB 'Series='  header.(header_field_names{1}).SeriesDescription ]);  
    
%     % Save Data and header as .mat file
%     try
%         [file,path] = uiputfile([header.(header_field_names{1}).StudyDescription '(' header.(header_field_names{1}).SeriesDescription ').mat'] ,'Save as .mat file (much faster load into matlab)');
%         fullPath=[path file];
%         disp([TAB 'Writing matlab-file='  path file ]);  
%         disp([TAB TAB  path file ]);
%         save(fullPath, 'Data', 'header');
%     catch
%         disp([TAB 'Save Data was not completed']);
%     end
%     

    
    disp('END Write_PET_DICOM');
 