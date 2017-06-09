%
%     timeFromECATInput
%
%     Purpose:  get frame times and durations
%
%     Author: Jan Axelsson
%
%     Input:      subHeader
%
%     Output:     time, duration
%
%     Example:
%                   [time, duration]=timeFromECATInput(subHeader)
%
%      Instructions:
%
%       ECAT files are stored in variables:
%           data,  mainHeader, subHeader
%




function [time, duration]=timeFromECATInput(subHeader)
    %
    % INITIALIZE
    %
        TAB=sprintf('\t');

        %waitBarHandle = waitbar(0,'Getting times and durations');

        disp('START timeFromECATInput');

    % DATA field names representing each DICOM file (i.e. PETAC001_PT001, etc) structure:  cell
    % assume same fieldnames
        %data_field_names=fieldnames(data);
        %header_field_names=fieldnames(header);
        disp([ TAB 'Determine times']);

    % Generate empty matrix
        NFrames= size(subHeader,2);
        
        time=zeros(NFrames,1);
        duration=zeros(NFrames,1);

        disp([ TAB 'Number of Frames=' num2str(NFrames) ])


    %
    %  LOOP Frames
    %

        % Package scaled and decay-corrected data into matrix correctly_scaled_data
        last=NFrames;
        for i=1:last    
            %waitbar(i/last);
            try
                    
                % Diagnostic output (comment out if not needed) 
                time(i)=ECAT_readHeaderInt4( subHeader(:,i), 50)/1000;
                duration(i)=ECAT_readHeaderInt4( subHeader(:,i), 46)/1000;
            catch
                disp([ 'Error in timeFromECATInput' ]);
            end

        end %LOOP

    %
    % FINALIZE
    %
    %close(waitBarHandle);
    time=time';
    
    disp('END timeFromECATInput');