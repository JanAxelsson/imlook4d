%
%     Save_DICOM_to_mat
%
%     Purpose:  Save GE DICOM Data and header to mat file (for faster
%     opening).  File name is generated from scan name, and file is stored
%     in current directory (you can cd to the directory prior to calling
%     this routine).
%
%     Author: Jan Axelsson
%
%     Input:        - 4D matrix  [X x Y x M * T] with image size X x Y with M slices and T frames.
%                   - header structure
%
%     Output:       none
%
%     Example:
%                   Save_DICOM_to_mat(Data, header)
%
function Save_DICOM_to_mat(Data, header)

    % Standard initialization
    TAB=sprintf('\t');
    
    % Write summary
    header_field_names=fieldnames(header);
    
    disp2('SUMMARY of Read_PET_DICOM, based on first file');
    disp2([TAB 'Patient='  header.(header_field_names{1}).PatientName.FamilyName ]);   
    disp2([TAB 'PatientID='  header.(header_field_names{1}).PatientID ]);   
    disp2([TAB 'File format='  header.(header_field_names{1}).Format ]);
    disp2([TAB 'Modality='  header.(header_field_names{1}).Modality ]);
    disp2([TAB 'Study='  header.(header_field_names{1}).StudyDescription ]);   
    disp2([TAB 'Series='  header.(header_field_names{1}).SeriesDescription ]);  
    
    % Save Data and header as .mat file
    name=[header.(header_field_names{1}).StudyDescription '(' header.(header_field_names{1}).SeriesDescription ').mat'];
    name=strrep(name, ':','');  % Remove ':'
    
    try
        %JAN[file,path] = uiputfile( name ,'Save as .mat file (much faster load into matlab)');
        %JANfullPath=[path file];
        fullPath=[ header.(header_field_names{1}).StudyDescription '(' header.(header_field_names{1}).SeriesDescription ').mat']
        
        disp2([TAB 'Writing matlab-file='  fullPath ]);  
        %disp2([TAB TAB  path file ]);
        %save(fullPath, 'Data', 'header');
        try
            [time, duration]=timeFromDICOMInput(header);
            save(fullPath, 'Data', 'header','time', 'duration');
        catch
            disp('Error: time and duration not extracted properly');
            save(fullPath, 'Data', 'header');
            disp('Error: saved only Data, header');
        end
        
        
    catch
        disp([TAB 'Save Data was not completed']);
    end
