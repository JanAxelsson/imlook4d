function DICOMHeader2Excel( header, fileName, tagNames)
%
% This routine creates an Excel file of the header struct.  Structs within
% the structs are ignored, such as PatientName.FamilyName.
% The header struct would originate from for instance Read_PET_DICOM.
%
% Example 1) 
%       [Data, header]=Read_PET_DICOM('D:\ISGARS\0\');
%       DICOMHeader2Excel( header, 'C:\DocumentsandSettings\jana\Desktop\tempdata.xls');
% 
% Example 2) 
%       [Data, header]=Read_PET_DICOM('D:\ISGARS\0\');
%       DICOMHeader2Excel( header,'C:\Documents and Settings\jana\Desktop\tempdata.xls', { 'AcquisitionTime', 'RescaleSlope', 'FrameReferenceTime' });
% 
% Jan Axelsson 070321

%
% INITIALIZE
%
    header_field_names=fieldnames(header);                      % cell array containing field-names of the struct header (same as DICOM file names)
    numberOfFields=size(fieldnames(header),1);

    if nargin == 2                                              % If tagNames are not specified, then all the non-struct tags are extracted
        tagNames=fieldnames(header.(header_field_names{1}));    % cell array containing tag names
    end
    numberOfTags=size(tagNames,2);                              % number of tags (number of field-names in header.field)
    size(tagNames)
    
    TAB=sprintf('\t');                                          % Standard initialization

%
% EXTRACT TAGS TO A CELL ARRAY FOR EACH DICOM FILE
%
    for j=1:numberOfTags
        disp(['Tag name=' tagNames{j}]);
        column{1,j+1}=tagNames{j}; % row 1, columns 2:end contains the tag names
    end



    for i=1:numberOfFields                    % Rows
        try
            column{i+1,1}=header_field_names{i};  % Column 1 contains the field-names of the struct header
            for j=1:numberOfTags
%                 if isstruct(header.(header_field_names{i}).(tagNames{j}))
%                     %disp(['Found struct in ' num2str(j)]);
%                 else
%                     column{i+1,j+1}=header.(header_field_names{i}).(tagNames{j}); % Columns 2... contains the data
%                 end
                

                    column{i+1,j+1}=eval(['header.' header_field_names{i} '.' tagNames{j}]); % Columns 2... contains the data

            end
        catch
            disp(['Tag missing?  ' header_field_names{i}]);
        end
    end


%
% WRITE HEADER TO EXCEL
%
    xlswrite(fileName, column);