 function [DICOMStruct]=dirtyDICOMTimeFromAcqTime( DICOMStruct)
        %
        % input:    
        %           a struct containing a minimum of the following fields
        %           DICOMStruct.dirtyDICOMHeader
        %           DICOMStruct.dirtyDICOMFileNames 
        %           DICOMStruct.dirtyDICOMMode                      explicit=2 implicit=0
        %           DICOMStruct.dirtyDICOMIndecesToScaleFactor
        %
        %           
        %
        % output:   a struct which is added by time, duration, and halflife
        
        

        %
        % Initialize
        %
        
        disp('Entered TimeFromAcqTime');
                % Default sorted data to original order
                %sortedData=matrix;                       
                sortedHeaders=DICOMStruct.dirtyDICOMHeader;
                %sortedFileNames=DICOMStruct.dirtyDICOMFileNames; 
                %sortedIndecesToScaleFactor=DICOMStruct.dirtyDICOMIndecesToScaleFactor; 
                mode=DICOMStruct.dirtyDICOMMode;
                
                %last=size(sortedHeaders,2);  % Used when iterating files
                %numberOfImages=last;
                
                numberOfSlices=str2num(DICOMStruct.dirtyDICOMSlicesString);
                numberOfFrames=size(DICOMStruct.dirtyDICOMFileNames,2)/numberOfSlices;

    
%                  
% Time from acq time
%             

%     out=dirtyDICOMHeaderData(sortedHeaders, 1, '0008', '0032',mode);  % Acq time
%     acqTime(1)=str2num(out.string); 
    
      try
%         for i=1:numberOfFrames
%             slice=1;  % Read from first slice and frame i (assuming data is in correct order)
%             out=dirtyDICOMHeaderData(sortedHeaders, (i-1)*numberOfFrames+slice, '0008', '0032',mode);  % Acq time
%             acqTime(i)=str2num(out.string); 
%         end
%         DICOMStruct.time=acqTime;

        %out=dirtyDICOMHeaderData(sortedHeaders, 1, '0008', '0030',mode);  % Study time
        out=dirtyDICOMHeaderData(sortedHeaders, 1, '0008', '0032',mode);  % Acq time
        startTime=out.string;
        startTimeInSeconds=str2num(startTime(1:2))*3600 + str2num(startTime(3:4))*60 + str2num(startTime(5:6));


        for i=1:numberOfFrames
            for slice=1:numberOfSlices
                %disp( (i-1)*numberOfSlices+slice );
                out=dirtyDICOMHeaderData(sortedHeaders, (i-1)*numberOfSlices+slice, '0008', '0032',mode);  % Acq time
                
                b=out.string;
                time(slice,i)=((str2num(b(1:2))*3600 + str2num(b(3:4))*60 + str2num(b(5:6))))-startTimeInSeconds;
            end
        end        
        
        DICOMStruct.time2D=time;
        DICOMStruct.time=time(1,1:numberOfFrames);
    catch
        message='imlook4d/LocalOpenDirtyDICOM error:  Error reading time from acqTime';
        %warning(message);
        disp(message);
    end        

%
% Create output variables
%                         


