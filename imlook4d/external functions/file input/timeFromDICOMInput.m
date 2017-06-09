%
%     timeFromDICOMInput
%
%     Purpose:  get frame times and durations
%
%     Author: Jan Axelsson
%
%     Input:        header
%
%     Output:     time, duration
%
%     Example:
%                   [time, duration]=timeFromDICOMInput(header)
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
%       DICOM frame time is stored in a struct of type::        header.PETAC001_PT001.FrameReferenceTime which is a double
%       DICOM frame duration:                                   header.PETAC001_PT001.ActualFrameDuration   which is a double          



function [time, duration]=timeFromDICOMInput(header)
    %
    % INITIALIZE
    %
        TAB=sprintf('\t');

        waitBarHandle = waitbar(0,'Getting times and durations');

        disp2('START timeFromDICOMInput');

    % DATA field names representing each DICOM file (i.e. PETAC001_PT001, etc) structure:  cell
    % assume same fieldnames
        %data_field_names=fieldnames(data);
        header_field_names=fieldnames(header);
        disp2([ TAB 'Determine times']);

    % Generate empty matrix
        NSlices= header.(header_field_names{1}).NumberOfSlices;
        NFrames= header.(header_field_names{1}).NumberOfTimeSlices ;
        
        time=zeros(NFrames,1);
        duration=zeros(NFrames,1);

        disp2([ TAB 'Number of Slices  =' num2str(NSlices ) ])
        disp2([ TAB 'Number of Frames=' num2str(NFrames) ])


    %
    %  LOOP images and perform scaling
    %

        % Package scaled and decay-corrected data into matrix correctly_scaled_data
        last=size(header_field_names,1);
        for i=1:last    
            waitbar(i/last);
            try
                try
                currentSlice=header.(header_field_names{i}).Private_0009_10a6;
                currentFrame=header.(header_field_names{i}).Private_0009_10d8;
                catch
                    disp2([ 'Ignoring GE private tags: '  header.(header_field_names{i}).Filename ]);
                end
                currentTime=header.(header_field_names{i}).FrameReferenceTime/1000;
                currentDuration=header.(header_field_names{i}).ActualFrameDuration/1000;
                
                % Get first byte of integer data (sometimes formated as
                % four separate integers)
                currentSlice=currentSlice(1);
                currentFrame=currentFrame(1);
                
                %disp2([ num2str(currentSlice) '    ' num2str(currentFrame)]);

                    
                % Diagnostic output (comment out if not needed) 
                time(currentFrame)=currentTime;
                duration(currentFrame)=currentDuration;
            catch
                
            end

        end %LOOP

    %
    % FINALIZE
    %
    close(waitBarHandle);
    disp2('END timeFromDICOMInput');