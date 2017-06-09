%
%     DICOM_script
%
%     Purpose:  Scale DICOM data
%
%     Author: Jan Axelsson
%
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
TAB=sprintf('\t');

waitBarHandle = waitbar(0,'Please wait...');


    
    
disp('START!');

% DATA field names representing each DICOM file (i.e. PETAC001_PT001, etc) structure:  cell
% assume same fieldnames
data_field_names=fieldnames(data);
header_field_names=fieldnames(data);
disp(['Determine scale factor to get matrix in units of ' header.(header_field_names{1}).Units]);

% Generate empty matrix
NSlices= header.(header_field_names{1}).NumberOfSlices;
NFrames= header.(header_field_names{1}).NumberOfTimeSlices ;

disp([ 'Number of Slices  =' num2str(NSlices ) ])
disp([ 'Number of Frames=' num2str(NFrames) ])

pixels=size(data.(data_field_names{1}),1);
clear correctly_scaled_data;
correctly_scaled_data=zeros(pixels,pixels,NSlices,NFrames);

%
%  LOOP images and perform scaling
%

% Package scaled and decay-corrected data into matrix correctly_scaled_data
last=size(data_field_names,1);
for i=1:last    
    waitbar(i/last);
    currentSlice=header.(header_field_names{i}).Private_0009_10a6;
    currentFrame=header.(header_field_names{i}).Private_0009_10d8;
    
    
    units_conversion = 1.0;
        if (header.(header_field_names{i}).Units=='BQML')
            units_conversion = 1.0e-06;
        end;
    
        decay_conversion=1.0;
         if (strcmp(header.(header_field_names{1}).DecayCorrection,'ADMIN'))
             warndlg('Check results.  I am not sure how GE has implemented this.');
%        % if (header.(header_field_names{1}).DecayCorrection=='ADMIN')
%             disp('ERROR -  decay correction feature is not tested, PLEASE VALIDATE!');
% 
%             half_life=           header.(header_field_names{i}).Private_0009_103f  
%             admin_datetime=header.(header_field_names{i}).Private_0009_103b
%             scan_datetime= header.(header_field_names{i}).Private_0009_100d
% 
%             %Apply formula: decay_conversion = exp( log(2)*(admin_datetime-scan_datetime)/half_life  with admin_datetime and scan_datetime in seconds.
%             decay_conversion = exp( log(2) *(...
%                 24*3600*datenum([  str2num(admin_datetime(1:4)) str2num(admin_datetime(5:6)) str2num( admin_datetime(7:8)) str2num(admin_datetime(9:10)) str2num( admin_datetime(11:12)) str2num(admin_datetime(13:14)) ] )...
%                 -24*3600*datenum([  str2num(scan_datetime(1:4)) str2num(scan_datetime(5:6)) str2num( scan_datetime(7:8)) str2num(scan_datetime(9:10)) str2num( scan_datetime(11:12)) str2num(scan_datetime(13:14))])...
%                 )...
%                 /half_life) 
         end %IF
        
        scale_factor=header.(header_field_names{i}).RescaleSlope * units_conversion * decay_conversion;        
        disp(['  i=' num2str(i)  ':'  ...
            TAB  ' Frame=' num2str( currentFrame )...
            TAB ' Slice='  num2str( currentSlice ) ...
            TAB ' Time=' num2str( header.(header_field_names{i}). Private_0009_106c) ...
            TAB   ' Frame length=' num2str(header.(header_field_names{i}).ActualFrameDuration / 1000) ' [s]' ...    
            TAB  ' RescaleSlope=' num2str(header.(header_field_names{i}).RescaleSlope)   ...
            TAB  'units_conversion=' num2str(units_conversion)   ...
            %TAB  ' decay_conversion=' num2str(decay_conversion)     ...
            %TAB  ' scale_factor=' num2str(scale_factor)...
            ]);
       % correctly_scaled_data(:,:,i)=data.(data_field_names{i})*scale_factor;
        correctly_scaled_data(:,:,currentSlice,currentFrame)= ...
            data.(data_field_names{i}) ...
            * header.(header_field_names{i}).RescaleSlope ...
            + header.(header_field_names{i}).RescaleIntercept;


end %LOOP


close(waitBarHandle);
disp('DONE!');