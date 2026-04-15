%**********   "ANNOTATIONS"   *********
%
%NAME:
%WriteECAT
%
%PURPOSE:
% THIS FUNCTION CREATES ECAT .V FILE OUT OF A 4D MATRIX.
%
%INPUT:
% - OriginalInputFileName:       - NAME OF THE INPUT FILE IN ''.
% - InputMatrix:                 - INPUT 4D MATRIX.
% - Directory:                   - Output directory to save files in
% - PcType:                      - Type of applied PCA, 'MVW-PCA',
%                                  'MSW-PCA', 'SW-PCA' OR 'VW-PCA'
%OUTPUT:
%NONE
%
%FUNCTION CALL:
% - spm_vol
% - upc_ecat_util
%
%DATE OF CREATION:
%20040301
%
%LATEST DATE OF MODIFICATION:
%20060418
%
%AUTHORS:
%ANNA RINGHEIM & PASHA RAZIFAR, UPPSALA IMANET
%
%EXAPMPLE:
%WriteECAT('test.v',DataMatrix, PETMainHeader, PETSubHeader, PETDirStruct,'/min')
%
%**********   "ANNOTATIONS"   *********

%function CreateVpcFilesFinal(OriginalInputFileName,InputMatrix,Directory,PcaType)
function WriteECAT(FileName,InputMatrix, PETMainHeader, PETSubHeader, PETDirStruct, unit)

    numberOfFrames = size(InputMatrix,4);
    InputMatrix = reshape(InputMatrix,size(InputMatrix,1)*size(InputMatrix,2)*size(InputMatrix,3),numberOfFrames);

    PETDirStructNumber=1;  % Number of Directory Structures

    [outFile, mess] = fopen(FileName,'w','b');
    if outFile<0
        disp(mess);
        return
    end
    fwrite(outFile,PETMainHeader(1:144),'uint8');
    %status = fseek(outFile,144,'bof');
    fwrite(outFile,1,'float32');  %Write ECAT calibration factor=1. Byte 144 (counting from 0)=145 in matrix.

    %fwrite(outFile,1,'uint16');  %Write calibration units, 1="calibrated". Byte 148=149 in matrix.
    fwrite(outFile,2,'uint16');  %Write calibration units, 2="processed". Byte 148=149 in matrix.


    fwrite(outFile,PETMainHeader(151:354),'uint8');
    %status = fseek(outFile,354,'bof');
    fwrite(outFile,numberOfFrames,'uint16');  %Write number of frames. Byte 354=355 in matrix.
    fwrite(outFile,PETMainHeader(357:466),'uint8');
    %status = fseek(outFile,466,'bof');
    fwrite(outFile,[unit char(zeros(1,32-length(unit)))],'uchar');  %Write unit. Byte 466=467 in matrix.
    fwrite(outFile,PETMainHeader(499:end),'uint8');


% %090306  Modify directory structure to reflect number of frames
% %
% % Start with zeros.
% % Base it on old directory structure, by copying directory structure frame by frame.
%     newPETDirStruct=zeros( size(PETDirStruct(:,:) ));    % Make all directory structures zero
%     newPETDirStruct(1:4,1)=PETDirStruct(1:4,1);          % First directory structure
%     
%     
%     % Make zero for frames that are not existing
%     
%     positionCounter=1;
%     for i=1:numberOfFrames
%         positionCounter=positionCounter+4;  % Move to next position in structure
%         
%         if (i==31*1+1)|(i==31*2+1)|(i==31*3+1)
%             % If end of directory structure,
%             % Move to next directory structure
%             PETDirStructNumber=PETDirStructNumber+1;
%             positionCounter=1;
%             positionCounter=positionCounter+4; 
%         end  
% 
%         % Update directory structure for current frame
%         newPETDirStruct(positionCounter:positionCounter+3,PETDirStructNumber)=...
%             PETDirStruct(positionCounter:positionCounter+3,PETDirStructNumber);
%     end
%     
%     
%     % Fix last record to point to first record
%     newPETDirStruct(2,PETDirStructNumber)=2;  % Point to first record of first directory structure
%     newPETDirStruct(4,PETDirStructNumber)=numberOfFrames-(PETDirStructNumber-1)*31;  % Number of frames in last directory structure
%     
%     PETDirStruct=newPETDirStruct;  % Copy new directory structure to old directory structure
% %090306 END





%Write first directory structure to file.
fwrite(outFile,PETDirStruct(:,1),'uint32');

%
% Write ECAT file 
%

    for i=1:numberOfFrames
    %     if (i==32)
    %         fwrite(outFile,PETDirStruct(:,2),'uint32');
    %     end

        %090216
        if (i==31*1+1)|(i==31*2+1)|(i==31*3+1)
            PETDirStructNumber=PETDirStructNumber+1;
            fwrite(outFile,PETDirStruct(:,PETDirStructNumber),'uint32');
        end



        %Calculate scale factor
        maxval = max(abs(InputMatrix(:,i)));  %Maximum absolute value in frame.
        scale_factor = maxval/32767;
        coeff = 32767/maxval;
        
        %Normalisation
        InputMatrix(:,i) = InputMatrix(:,i).*coeff;  %Divide by scale factor.
        maxv = max(InputMatrix(:,i));
        minv = min(InputMatrix(:,i));
        fwrite(outFile,PETSubHeader(1:26,i),'uint8');  %Write sub header.
        
        %Write scale factor.
        %status = fseek(outFile,26,'bof'); 
        fwrite(outFile,scale_factor,'float32');  %Scale factor. Byte 26=27 in matrix.
        
        %Write min value.
        %status = fseek(outFile,30,'bof');
        fwrite(outFile,minv,'int16'); %Image min. Byte 30=31 in matrix.
        
        %Write max value.
        fwrite(outFile,maxv,'int16'); %Image max. Byte 32=33 in matrix.
        fwrite(outFile,PETSubHeader(35:end,i),'uint8');  %Write rest of sub header.
        
        %Write data matrix.
        fwrite(outFile,InputMatrix(:,i),'int16');  
    end
    fclose(outFile);
