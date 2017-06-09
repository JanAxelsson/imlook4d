%WriteECAT_not_processed
%
%PURPOSE:
% THIS FUNCTION CREATES ECAT .V FILE OUT OF A 4D MATRIX.
% Differences to WriteECAT:
% -  The calibration units are kept to 1 (1=calibrated, not 2=processed)
% -  Retains the original ECAT_CalibrationFactor (instead of setting it to 1).
%    (this is necessary for Hermes not to screw up DICOM exported images
%     as created using ecat2if command on hermes console)
%
%INPUT:
%  FileName:                    Output file name
%  InputMatrix:                 4D matrix to save
%  PETMainHeader                matrix of bytes
%  PETSubHeader                 matrix of bytes                  
%  PETDirStruct                 matrix of bytes
%  unit                         String unit
%  
%OUTPUT:
%   none
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
%Jan Axelsson
% (Built on code by JAN AXELSSON, ANNA RINGHEIM & PASHA RAZIFAR, UPPSALA
% IMANET)
%Modified by Jan Axelsson so that Hermes ecat2if can handle ecat properly.
%
%EXAMPLE:
%WriteECAT_not_processed(FileName,InputMatrix, PETMainHeader, PETSubHeader,PETDirStruct, 'Bq/cc')


%function CreateVpcFilesFinal(OriginalInputFileName,InputMatrix,Directory,PcaType)
function WriteECAT_not_processed(FileName,InputMatrix, PETMainHeader, PETSubHeader, PETDirStruct, unit)

    %
    % Initialize
    %
        numberOfFrames = size(InputMatrix,4);
        InputMatrix = reshape(InputMatrix,size(InputMatrix,1)*size(InputMatrix,2)*size(InputMatrix,3),numberOfFrames);

        [outFile, mess] = fopen(FileName,'w','b');
        if outFile<0
            disp(mess);
            return
        end
        fwrite(outFile,PETMainHeader(1:144),'uint8');
        %status = fseek(outFile,144,'bof');


    %
    % ECAT_CalibrationFactor
    %
        ECAT_CalibrationFactor=ECAT_readHeaderReal(PETMainHeader, 144);
        disp(['ECAT_CalibrationFactor=' num2str(ECAT_CalibrationFactor)]);
        %fwrite(outFile,ECAT_CalibrationFactor,'float32');  %Write ECAT calibration factor=original value. Byte 144 (counting from 0)=145 in matrix.
        fwrite(outFile,PETMainHeader(145:148),'uint8');     % Copy ECAT calibration factor from main header
        %fwrite(outFile,1,'float32');  %Write ECAT calibration factor=1. Byte 144 (counting from 0) 

    %
    % calibration units
    %
        fwrite(outFile,1,'uint16');   %Write calibration units, 1="normal". Byte 148=149 in matrix.
        %fwrite(outFile,PETMainHeader(149:150),'uint8');   %Copy calibration units from original main header
        %fwrite(outFile,2,'uint16');  %Write calibration units, 2="processed". Byte 148=149 in matrix

    %
    % number of frames
    %
        fwrite(outFile,PETMainHeader(151:354),'uint8');
        %status = fseek(outFile,354,'bof');
        fwrite(outFile,numberOfFrames,'uint16');  %Write number of frames. Byte 354=355 in matrix.
        fwrite(outFile,PETMainHeader(357:466),'uint8');
        %status = fseek(outFile,466,'bof');

    %
    % unit
    %
        fwrite(outFile,[unit char(zeros(1,32-length(unit)))],'uchar');  %Write unit. Byte 466=467 in matrix.
        fwrite(outFile,PETMainHeader(499:end),'uint8');


    %
    %Write directory structure.
    %
       fwrite(outFile,PETDirStruct(:,1),'uint32');

    %
    %Write to file, setting scale factors.
    %
        for i=1:numberOfFrames
            if (i==32)
                fwrite(outFile,PETDirStruct(:,2),'uint32');
            end
            
            %Calculate scale factor (to allow us to keep ECAT_CalibrationFactor in main header)
            maxval = max(abs(InputMatrix(:,i)));  %Maximum absolute value in frame.
            total_scale_factor = maxval/32767;
            disp(['Total Scale factor=' num2str(total_scale_factor)]);

            %Normalisation
            InputMatrix(:,i) = InputMatrix(:,i)./total_scale_factor;  %Divide by total scale factor (gives int from real)
            maxv = max(InputMatrix(:,i));
            minv = min(InputMatrix(:,i));
            
            %Copy
            fwrite(outFile,PETSubHeader(1:26,i),'uint8');  %Write sub header.
            
            %Write Frame scale factor
            %status = fseek(outFile,26,'bof'); 
            scale_factor=total_scale_factor/ECAT_CalibrationFactor;   %Frame scale factor (subheader)
            disp(['Frame Scale factor=' num2str(scale_factor)]);
            fwrite(outFile,scale_factor,'float32');  %Scale factor. Byte 26=27 in matrix.
            
            %Write min value.
            %status = fseek(outFile,30,'bof');
            fwrite(outFile,minv,'int16'); %Image min. Byte 30=31 in matrix.
            
            %Write max value.
            fwrite(outFile,maxv,'int16'); %Image max. Byte 32=33 in matrix.
            
            %Copy
            fwrite(outFile,PETSubHeader(35:end,i),'uint8');  %Write rest of sub header.
            
            %Write data matrix.
            fwrite(outFile,InputMatrix(:,i),'int16');  
        end
        
    %
    % CLEAN UP
    %
        fclose(outFile);
