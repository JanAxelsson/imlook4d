function [matrix, header, outputFileName]=Dirty_Read_DICOM(directoryPath, pixelsize, machineFormat, fileFilter, fileNames)
% JAN Added input fileNames which is a cell array of paths relative
% directoryPath
%
%     Purpose:  Read a DICOM file, storing header in binary format  
%

%
%     Input:        directoryPath   path to directory
%                   pixelsize       number of pixels in image
%                   machineFormat   b (big-endian, default) or l (little-endian)
%
%     Output:       matrix      3D matrix
%                   header      cell array with binary DICOM headers
%                   fileNames   cell array with original file names
%
%     Example:
%       [matrix, header, fileNames]=Dirty_Read_DICOM('C:\Documents and Settings\jana\Desktop\CACHE\anon3916', 512, 'b')    
%
%     Author: Jan Axelsson

%
% INITIALIZE
%
    
    %disp('START Dirty_Read_DICOM');
    
    
    if nargin <3
         machineFormat='b';
    end
    
    if nargin >3
         fileFilter; 
    else
        fileFilter='';
    end
    
    %disp(['Dirty_Read_DICOM:  Machine-format=' machineFormat]);
    
    % Standard initialization
    TAB=sprintf('\t');
    
%     % Setup structs
%     dcmfile = [];
%     header=[];
%     data=[];
%     TempHeader = [];
%     TempVol = [];
    
    % Fix directory path so that it always ends with \
    %%directoryPath=strrep( [directoryPath '\'] , '\\', '\'); %Add \ at end of path. Change to \ if \\ 
        directoryPath=strrep( [directoryPath filesep] , [filesep filesep], filesep); %Add \ at end of path. Change to \ if \\ 
    % Correct beginning to \\ if directoryPath starts with \
    if strcmp(directoryPath(1),'\')
        directoryPath=['\' directoryPath];
    end
    
    % Waitbar
    waitBarHandle = waitbar(0,'Reading DICOM files');	% Initiate waitbar with text

%
% INPUT DICOM FILES
%
    tic;
    %Find all files in directory
        %sTempFilenameStruct=dir([InpPath '\*.dcm']);
        %sTempFilenameStruct=dir(directoryPath);
        
        sTempFilenameStruct=dir([directoryPath fileFilter]);
        %sTempFilenameStruct=ls([directoryPath fileFilter])
        %size(sTempFilenameStruct)
        %sTempFilenameStruct(:).name
        
        
       if nargin ==5
            sTempFilenameStruct=fileNames; 
       else
            sTempFilenameStruct=dir([directoryPath fileFilter]);
        end

    
    %Get number of selected files.
        iNumberOfSelectedFiles = length(sTempFilenameStruct);

     count=0;  % Number of accepted files
     matrix=zeros(pixelsize,pixelsize,iNumberOfSelectedFiles, 'single');
     %header=cell(1,iNumberOfSelectedFiles);  %JAN
     %fileName=cell(1,iNumberOfSelectedFiles);  %JAN

     tic;
        for nr=1:iNumberOfSelectedFiles  %Ignore directories '.' and '..'
            if (mod(nr, 100)==0) waitbar(nr/iNumberOfSelectedFiles); end
            
            try    
                tempFilename= [directoryPath sTempFilenameStruct(nr).name];
                fileSize=sTempFilenameStruct(nr).bytes;

                headerSize=fileSize-2*pixelsize*pixelsize;
                
                if (headerSize>0)

                    fid = fopen(tempFilename, 'r',machineFormat);
                    tempHeader= fread(fid, headerSize);                     % Binary header in memory  
                    tempData= fread(fid, pixelsize*pixelsize, 'int16');     % Data in memory  

                    fclose(fid);

                    count=count+1;    % Succesful read
                    matrix(:,:,count)=single(reshape(tempData(:),pixelsize,pixelsize,1));
                    header{count}=tempHeader;
                    %fileName{count}=tempFilename;
                    outputFileName{count}=tempFilename;

                    %disp([TAB 'Accepting file=' sTempFilenameStruct(nr).name ]);
                end
                
            catch % Error handling (too small files are not accepted)
                disp([TAB 'ERROR Ignoring file=' tempFilename]);
            end
%             try    
%                 tempFilename= [directoryPath sTempFilenameStruct(nr).name];
%                 fileSize=sTempFilenameStruct(nr).bytes;
%                 
%                 xSize=384;%TEST
%                 ySize=512;%TEST
%                 headerSize=fileSize-2*xSize*ySize;%TEST
%                 
%                 fid = fopen(tempFilename, 'r',machineFormat);
%                 tempHeader= fread(fid, headerSize);                     % Binary header in memory  
%                 tempData= fread(fid, xSize*ySize, 'int16');     % TEST
% 
%                 fclose(fid);
%                 
%                 count=count+1;    % Succesful read
%                 matrix(:,:,count)=single(reshape(tempData(:),xSize,ySize,1));
%                 header{count}=tempHeader;
%                 %fileName{count}=tempFilename;
%                 outputFileName{count}=tempFilename;
% 
%                 %disp([TAB 'Accepting file=' sTempFilenameStruct(nr).name ]);
%                 
%                 
%             catch % Error handling (too small files are not accepted)
%                 disp([TAB 'ERROR Ignoring file=' tempFilename]);
%             end
            
        end
        
        
        matrix=matrix(:,:,1:count);
        
       %disp([' Time for Dirty_Read_DICOM =' num2str(toc) ' s.    Accepted ' num2str(count) ' files']);
       if (count>1)  % Display if more than one file
            disp([' Accepted ' num2str(count) ' files']);
       end
       if (iNumberOfSelectedFiles>count)   %
            disp([' Warning ' num2str(count) ' files accepted, out of ' num2str(iNumberOfSelectedFiles) 'selected']);
       end
       
        close(waitBarHandle);
        
        
        
        