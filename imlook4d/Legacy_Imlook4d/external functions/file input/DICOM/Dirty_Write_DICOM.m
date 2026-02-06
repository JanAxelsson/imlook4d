function Dirty_Write_DICOM(matrix, header, fileNames, machineFormat, mode)
%
%     Purpose:  Write a modified DICOM file.    
%
%     Instructions:
% 
%     The files are put in current directory (cd to directory you want)
%     The absolute path in fileNames is ignored, only file name is honored
%
%     Input:        matrix      3D matrix
%                   header      cell array with binary DICOM headers
%                   fileNames   cell array with file names
%                   machineFormat   b (big-endian, default) or l (little-endian)
%                   mode            0 or 2 (2 being explicit)
%
%     Output:     none
%
%     Example:
%       Dirty_Write_DICOM(matrix, header, fileNames, 'b', 2);           
%
%     Author: Jan Axelsson

%
% INITIALIZE
%
    
    disp('START Dirty_Write_DICOM');
    
    if nargin <4
         machineFormat='b';
    end
    
    disp(['machineFormat=' machineFormat ]);
    
    % Standard initialization
    TAB=sprintf('\t');
    
    % Waitbar
    waitBarHandle = waitbar(0,'Saving DICOM files');	% Initiate waitbar with text

%
% WRITE DICOM FILES
%
    tic;
    
    %Get number of selected files.
     iNumberOfSelectedFiles = size(fileNames,2);
     
     % Make a directory to put files into
       [directoryPath,filename,ext] = fileparts(fileNames{1});
%       cd( [directoryPath '\'] );
%       cd('..');
%       mkdir('out');
%       cd('out');



    % Number of bytes per pixel
        out3=dirtyDICOMHeaderData(header, 1, '0028', '0100',mode);  % Bits allocated
        numberOfBitsStored=out3.bytes(1)+256*out3.bytes(2);
        numberOfBytesPerPixel=numberOfBitsStored/8;

    % Number format
        out3=dirtyDICOMHeaderData(header, 1, '0028', '0103',mode);  % Pixel Representation
        signed=( (out3.bytes(1)+256*out3.bytes(2))==0 ); 
        if (signed)  % 0 means unsigned
            if (numberOfBytesPerPixel==1)
                numberFormat='uint8';
            end
            if (numberOfBytesPerPixel==2)
                numberFormat='uint16';
            end
        else  % 1 means signed
            if (numberOfBytesPerPixel==1)
                numberFormat='int8';
            end
            if (numberOfBytesPerPixel==2)
                numberFormat='int16';
            end                        
        end

     

     count=0;  % Number of written files
        
     %Loop for individual files
     tic;
        for nr=1:iNumberOfSelectedFiles  
            if (mod(nr, 100)==0) waitbar(nr/iNumberOfSelectedFiles); end
            try    
                [directoryPath,filename,ext] = fileparts(fileNames{nr});
                
                %filename = [directoryPath '\test\out_' filename ext];
                filename = [filename ext];

                
                %fid = fopen(filename, 'w', 'b');
                
                fid = fopen(filename, 'w', machineFormat);
                
                slice = matrix(:,:,nr);
                L = length( slice(:));
                header{nr}=dirtyDICOMModifyHeaderString(header{nr}, '7FE0', '0010',mode, num2str( numberOfBytesPerPixel * L ) ); % New valuelength for image
                                
                fwrite(fid, header{nr});

                fwrite(fid, round( matrix(:,:,nr)), numberFormat);
                
                fclose(fid);
                
                count=count+1;    % Succesful write

                %disp([TAB 'Wrote file=' filename]);
                
                
            catch % Error handling (too small files are not accepted)
                disp([TAB 'Ignoring file=' filename]);
            end

        end
        disp([' Time for Dirty_Write_DICOM =' num2str(toc) ' s.']);
        disp([' Succesfully wrote ' num2str(count) ' files']);
        
        close(waitBarHandle);
        
        
