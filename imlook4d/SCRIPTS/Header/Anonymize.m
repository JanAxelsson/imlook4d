% Anonymize.m
%
% Anonymizes the current imlook4d instance (into same window)
%

%
% INITIALIZE
%
    % Test if DICOM, otherwise bail out
        if strcmp(imlook4d_current_handles.image.fileType,'DICOM')
            % OK!
        else
           warning('Not a DICOM file');
           return
        end

    % Store variables (so we can clear all but these)
       StoreVariables
       Export
       historyDescriptor='Anon';


    xxxx='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

    % Read stored information
        headers=imlook4d_current_handles.image.dirtyDICOMHeader;
        mode=imlook4d_current_handles.image.dirtyDICOMMode;

    % USER INPUT:  Modify Patient ID, Patient Name, Series Description

         try
             patientName1=dirtyDICOMHeaderData(headers, 1,'0010', '0010',mode);
             patientID1=dirtyDICOMHeaderData(headers, 1,'0010', '0020',mode);
             patientBirthDate1=dirtyDICOMHeaderData(headers, 1,'0010', '0030',mode);
        catch
            disp('Finding data to anonymize failed');
        end

%
% CENSOR all(Name and PatientID is anonymized in Save at end of script)
%
        % Modify headers
        try
            iNumberOfSelectedFiles = size(headers,2);

             for i=1:iNumberOfSelectedFiles

                    
                % Censor occasions where name, ID, or birth date happens to occur (overwrite with xxx...xx)
                    temp=char(headers{i});  % One column
                    temp=temp';             % One row
                    
                    % Overwrite with xxx...xx when one of the fields are found somewhere in header
                    temp=strrep(temp, patientName1.string,      xxxx( 1:length(patientName1.string)     ) );
                    temp=strrep(temp, patientID1.string,        xxxx( 1:length(patientID1.string)       ) );
                    temp=strrep(temp, patientBirthDate1.string, xxxx( 1:length(patientBirthDate1.string)) );
                    headers{i}=temp';  % Put data back, as one column (which is what we started with)           

                    
                % Rewrite original data into tags (overwritten above)
                     headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0010', '0010',mode, patientName1.string);  
                     headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0010', '0020',mode, patientID1.string);  
             end

             % Put anonymized headers back in struct
             imlook4d_current_handles.image.dirtyDICOMHeader=headers;
        catch
            disp('Anonymization failed');
        end
 %   
 % FINALIZE
 %
    try
        % Import data (variables, and imlook4d_current_handles)
        Title
        Import
        
        % Save
        Save
        

        % Clean up  variables created in this script
        ClearVariables
    catch
        disp('Anonymization error');
    end   
