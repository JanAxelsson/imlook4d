 function [DICOMStruct]=dirtyDICOMTimeAndDuration( DICOMStruct)
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
% Time and Duration
%             
    try
%         for i=1:numberOfFrames
%             slice=1;  % Read from first slice and frame i (assuming data is in correct order)
%             out=dirtyDICOMHeaderData(sortedHeaders, (i-1)*numberOfFrames+slice, '0018', '1242',mode);
%             %indecesToDuration{i}.low=out.indexLow;
%             %indecesToDuration{i}.high=out.indexHigh;
%             duration(i)=str2num(out.string)/1000;
% 
%             out=dirtyDICOMHeaderData(sortedHeaders, (i-1)*numberOfSlices+slice, '0054', '1300',mode);
%             %indecesToTime{i}.low=out.indexLow;
%             %indecesToTime{i}.high=out.indexHigh;
%             time(i)=str2num(out.string)/1000;               
%         end
%         DICOMStruct.time=time;
%         DICOMStruct.duration=duration;

        
        for i=1:numberOfFrames
            for slice=1:numberOfSlices
                %disp( (i-1)*numberOfSlices+slice );
                out=dirtyDICOMHeaderData(sortedHeaders, (i-1)*numberOfSlices+slice, '0018', '1242',mode);
                %indecesToDuration{i}.low=out.indexLow;
                %indecesToDuration{i}.high=out.indexHigh;
                duration(slice,i)=str2num(out.string)/1000;

                out=dirtyDICOMHeaderData(sortedHeaders, (i-1)*numberOfSlices+slice, '0054', '1300',mode);
                %indecesToTime{i}.low=out.indexLow;
                %indecesToTime{i}.high=out.indexHigh;
                time(slice,i)=str2num(out.string)/1000; 
            end
        end
        
        % Calculate times relative first frame, first slice
        time = time - time(1,1);
        
        
        DICOMStruct.time2D=time;
        DICOMStruct.time=time(1,1:numberOfFrames);
        DICOMStruct.duration2D=duration;
        DICOMStruct.duration=duration(1,1:numberOfFrames);
    catch
        message='dirtyDICOMTimeAndDuration error:  Error reading time or duration';
        %warning(message);
        disp(message);
    end   
    
%
% half life
%

    try
        out3=dirtyDICOMHeaderData(sortedHeaders, 1, '0018', '1075',mode);
        disp(['halflife=' out3.string]);                        
        halflife=str2num(out3.string);
        DICOMStruct.halflife=halflife;
    catch
        message='dirtyDICOMTimeAndDuration error:  Error reading radioactive halflife';
        disp(message);
    end



