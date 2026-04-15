%
%     scaleDICOMmatrix
%
%     Purpose:  Scale DICOM data
%
%     Author: Jan Axelsson
%
%     Input:        header
%                     data
%
%     Output:     correctly_scaled_data
%
%     Example:
%                   correctly_scaled_data=scaleDICOMmatrix(header, data);
%
%      Instructions:
%
%       DICOM files are stored in variables:
%           data,  header
%
%      Method to populate data and header variables:
%           Use Anna Ringheim's
%           http://mlabserver/General/dicom/Files/General_dicom_file.html 
%           with Internet Explorer (Anna uses Windows-specific file
%           selection on this web page)
%
%
%      Background Information:
%
%       DICOM images are stored in a struct of type:    data.PETAC001_PT001 which is a [128*128 matrix]
%       DICOM headers are stored in a struct of type:   header.PETAC001_PT0001 which is a struct
%
%       DICOM slope is stored in a struct of type::        header.PETAC001_PT001.RescaleSlope which is a double
%       DICOM units:                                       header.PETAC001_PT001.Units   which is a string          
%             -  dynamic PET-data: 4-dimensional matrix [X x Y x M * T] with image 
%			                    size X x Y with M slices and T frames.


function correctly_scaled_data=scaleDICOMmatrix(header,data)
    %
    % INITIALIZE
    %
        TAB=sprintf('\t');

        waitBarHandle = waitbar(0,'Scaling DICOM data');

        disp2('START scaleDICOMmatrix');

    % DATA field names representing each DICOM file (i.e. PETAC001_PT001, etc) structure:  cell
    % assume same fieldnames
        data_field_names=fieldnames(data);
        header_field_names=fieldnames(data);
        disp2([ TAB 'Determine scale factor to get matrix in units of ' header.(header_field_names{1}).Units]);

    % Generate empty matrix
        NSlices= header.(header_field_names{1}).NumberOfSlices;
        NFrames= header.(header_field_names{1}).NumberOfTimeSlices ;

        disp([ TAB 'Number of Slices  =' num2str(NSlices ) ])
        disp([ TAB 'Number of Frames=' num2str(NFrames) ])

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
            try

                currentSlice=header.(header_field_names{i}).Private_0009_10a6;
                currentFrame=header.(header_field_names{i}).Private_0009_10d8;

                
                % Get first byte of integer data (sometimes formated as
                % four separate integers)
                currentSlice=currentSlice(1);
                currentFrame=currentFrame(1);
                
                %disp2([ num2str(currentSlice) '    ' num2str(currentFrame)]);

                correctly_scaled_data(:,:,currentSlice,currentFrame)= ...
                        double( data.(data_field_names{i})  ) ...               % NOTE this is to avoid getting an int16 from the multiplication
                        * header.(header_field_names{i}).RescaleSlope ...
                        + header.(header_field_names{i}).RescaleIntercept;
                    
                % Diagnostic output (comment out if not needed)    
                temp=correctly_scaled_data(:,:,currentSlice,currentFrame);    
                disp22([ num2str(currentSlice) '    ' num2str(currentFrame)  ...
                    '     Max=' num2str(max(data.(data_field_names{i})(:))) '    Min=' num2str(min(data.(data_field_names{i})(:))) ...
                    '     Max=' num2str(max(temp(:))) '    Min=' num2str(min(temp(:))) ...
                    '     Slope='   num2str(header.(header_field_names{i}).RescaleSlope) '    Intercept=' num2str(header.(header_field_names{i}).RescaleIntercept)]) ; 
                
            catch
                disp2([ 'Ignoring non-GE non-PET data: '  header.(header_field_names{i}).Filename ]);
            end

        end %LOOP

    %
    % FINALIZE
    %
    close(waitBarHandle);
    disp2('END scaleDICOMmatrix');