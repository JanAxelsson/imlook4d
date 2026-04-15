%
%     scaleDICOMmatrixKarin
%
%     Purpose:  Scale DICOM data
%
%     Author: Jan Axelsson
%
%     Input:        header
%                     data
%
%     Output:     scaled
%
%     Example:
%       scaled=zeros(512,512,267,1,'single');           
%       scaleDICOMmatrixKarin(header, data);
%
%      Instructions:
%
%       DICOM files are stored in variables:
%           data,  header
%
%       Two methods to populate data and header variables:
%
%      1)  Use Anna Ringheim's
%           http://mlabserver/General/dicom/Files/General_dicom_file.html 
%           with Internet Explorer (Anna uses Windows-specific file selection on this web page)
%      or
%      2)  MATLAB  Image Tool Box calls:
%           data = DICOMREAD(FILENAME); 
%           header = DICOMINFO(FILENAME);
%
%
%      Background Information:
%
%       DICOM images are stored in a struct of type:    data.PETAC001_PT001 which is a [128*128 matrix]
%       DICOM headers are stored in a struct of type:  header.PETAC001_PT0001 which is a struct
%
%       DICOM slope is stored in a struct of type::        header.PETAC001_PT001.RescaleSlope which is a double
%       DICOM units:                                                      header.PETAC001_PT001.Units   which is a string          
%             -  dynamic PET-data: 4-dimensional matrix [X x Y x M * T] with image 
%			                    size X x Y with M slices and T frames.


function scaled=scaleDICOMmatrixKarin(header,data)
%function scaleDICOMmatrixKarin(header,data)

TAB=sprintf('\t');

waitBarHandle = waitbar(0,'Scaling DICOM data');


    

disp('START scaleDICOMmatrixKarin');

% DATA field names representing each DICOM file (i.e. PETAC001_PT001, etc) structure:  cell
% assume same fieldnames
data_field_names=fieldnames(data);
header_field_names=fieldnames(header);

 
% Generate empty matrix
last=size(data_field_names,1);
pixels=size(data.(data_field_names{1}),1);

% Do PET and CT specific stuff

 if (strcmp(header.(header_field_names{1}).Modality,'PT'))
    disp([ TAB 'Determine scale factor to get matrix in units of ' header.(header_field_names{1}).Units]);
    NSlices= header.(header_field_names{1}).NumberOfSlices;
    NFrames= last/NSlices;
 end;

 if (strcmp(header.(header_field_names{1}).Modality,'CT'))
    NSlices= last;
    NFrames= 1;
 end;

disp([ TAB 'Pixels  =' num2str(pixels ) ])
disp([ TAB 'Number of Slices  =' num2str(NSlices ) ])
disp([ TAB 'Number of Frames=' num2str(NFrames) ])
disp([ TAB 'Number of images=' num2str(last) ])

%
%  LOOP file names and make a sorted list to find file number from
%
for i=1:last    
    indexlist(i,1)=str2num( header.(header_field_names{i}).AcquisitionTime);% time
    indexlist(i,2)=i;   % index in header_field_names
end;    
sortedIndexList=sortrows(indexlist,1);  % Sort according to acquisition time


%
%  LOOP images and perform scaling
%

% Place scaled and decay-corrected data into matrix scaled

for index=1:last    
    i=sortedIndexList(index,2);    % Translate file number to correct file number according to acquisition time
    waitbar(i/last);
    % Special för Karin Fransson, där flera helkroppsundersökningar är körda efter varandra, men ska räknas som dynamiska
    %
    %One file per slice are exported from Xeleris to DICOM.  The files are
    %named xxx0001_PET001 to xxx0001_PET0267, xxx0002_PET001to
    %xxx0002_PET0267 etc, but the first number dose not necessarily reflect
    %the acquisition time.
    %
    % Therefore, the current slice can be read from the index in the
    % wholebody scan.
    % The current frame, however, has to be created.  This is done using
    % the fact that the files grouped under the same first number
    % (xxx0001_PET001 to xxx0001_PET267, etc) are from the same whole body
    % scan.  
    
    if (strcmp(header.(header_field_names{1}).Modality,'PT'))
        currentSlice=header.(header_field_names{i}).ImageIndex;
    end; 
    if (strcmp(header.(header_field_names{1}).Modality,'CT'))
        currentSlice=header.(header_field_names{i}).InstanceNumber;
    end;
    
    currentFrame=floor((index-1)/last)+1;      
    %currentFrame=floor((index-1)/267)+1;    
    
%     units_conversion = 1.0;
%      units_conversion=1.0;
% 
%         
%         scale_factor=header.(header_field_names{i}).RescaleSlope ;        

        if (i<10)    % Display first 10 rows
            temp=data.(data_field_names{i});
            disp(['  i=' num2str(i)  ':'  ...
            TAB  ' Acq. time=' header.(header_field_names{i}).AcquisitionTime ...
            TAB  ' Frame=' num2str( currentFrame )...
            TAB ' Slice='  num2str( currentSlice ) ...
            TAB  ' RescaleSlope=' num2str(header.(header_field_names{i}).RescaleSlope)   ...
            TAB  'RescaleIntercept=' num2str(header.(header_field_names{i}).RescaleIntercept)   ...
            ]);
        end;
        
        %scaled(:,:,currentSlice,currentFrame)=single(data.(data_field_names{i}))*scale_factor;
       scaled(:,:,currentSlice,currentFrame)=...
              single(data.(data_field_names{i}))...
           * header.(header_field_names{i}).RescaleSlope...
           +header.(header_field_names{i}).RescaleIntercept;

end %LOOP


close(waitBarHandle); 
disp([' max(scaled(:))=' num2str( max(scaled(:))) ]);
disp('END scaleDICOMmatrix');