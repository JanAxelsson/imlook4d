function [matrix, outputStruct]=JanOpenScaledDICOM(directoryPath, fileNames, selectedFile)
% JAN Added input fileNames which is a cell array of paths relative
% directoryPath
%
%     Purpose:  Read multiple DICOM files, storing header in binary format
%               Allow for reading a single multi-slice DICOM file, if
%               encountered.
%
%     Comments: For a multi-slice DICOM file, some tricks have been employed, to keep the structure.
%               The header and file name is duplicated in all slices (same filename for all slices).
%
%     Input:        directoryPath   path to base directory
%                   fileNames       struct where fileNames.name is the file name
%                                   struct where fileNames.bytes is the file size
%                   selectedFile    file name of selected file
%                                 
%                                 
%     Output:       struct  
%
%     Author: Jan Axelsson

%
% INITIALIZE
% 
    %disp('START JanOpenScaledDICOM');
    TAB=sprintf('\t');
    waitBarHandle = waitbar(0,'Reading DICOM files');	% Initiate waitbar with text
    % Fix directory path so that it always ends with \
    %%directoryPath=strrep( [directoryPath '\'] , '\\', '\'); %Add \ at end of path. Change to \ if \\
            directoryPath=strrep( [directoryPath filesep] , [filesep filesep], filesep); %Add \ at end of path. Change to \ if \\ 
%
% PROBE first selected file
%
            %file=fileNames(3).name;
            file=selectedFile;
            disp(selectedFile);
            dummy1=0;dummy3='l'; [Data, headers, dummy]=Dirty_Read_DICOM(directoryPath, dummy1,dummy3, selectedFile); % selected file
            
    
            %    
            % Transfer Syntax (Explicit/Implicit, Byte order)
            % 
           
                % Read Transfer syntax UID  (Group 0002 elements should always be EXPLICIT VR LITTLE ENDIAN)
                try
                    out3=dirtyDICOMHeaderData(headers, 1, '0002', '0010',2);
                catch
                    disp('Could not find tag "Transfer syntax UID" (0002,0010)!' );
                end
                 
                % Initial guess (Works for Hermes files)
                guessByteOrder='l';  %Little endian
                guessedMode=0;       %Implicit
                foundTransferSyntaxUID='unknown';
                explanation='( Could not find transfer syntax UID)';  

             
                
                % Decode transfer syntax UID

                    % Look for transfer syntax UIDs
                    supportedTransferSyntaxFlag=0;
                    try
                        supportedTransferSyntaxFlag=0;
                        if ( strcmp( strtrim(out3.string(1:17)), '1.2.840.10008.1.2'))
                            guessByteOrder='l'; %Little endian
                            guessedMode=0;      %Implicit
                            foundTransferSyntaxUID=out3.string;
                            explanation='(Little endian, implicit)';
                            supportedTransferSyntaxFlag=1;
                           % supportedTransferSyntaxFlag=0;
                        end
                        if ( strcmp( strtrim(out3.string(1:18)), '1.2.840.10008.1.2.'))
                            foundTransferSyntaxUID=out3.string;
                            explanation='';
                            supportedTransferSyntaxFlag=0;
                           % supportedTransferSyntaxFlag=0;
                        end
                        if ( strcmp( strtrim(out3.string(1:19)), '1.2.840.10008.1.2.1'))
                            guessByteOrder='l'; %Little endian
                            guessedMode=2;      %Explicit
                            foundTransferSyntaxUID=out3.string;
                            explanation='(Little endian, explicit)';
                            supportedTransferSyntaxFlag=1;
                        end
                        if ( strcmp( strtrim(out3.string(1:19)), '1.2.840.10008.1.2.2'))
                            guessByteOrder='b'; %Big endian
                            guessedMode=2;      %Explicit
                            foundTransferSyntaxUID=out3.string;
                            explanation='(Big endian, explicit)';
                            supportedTransferSyntaxFlag=0;  
                        end  
       
                        % Decode transfer syntax UID assuming implicit VR (should always be explicit for group 0002)                 
                        try
                            out4=dirtyDICOMHeaderData(headers, 1, '0002', '0010',0);   
                            % Special for GE CT, which is wrong
                            if ( strcmp( out4.string(1:18), '1.2.840.113619.5.2'))
                                guessByteOrder='b'; %Big endian
                                guessedMode=0;      %Explicit
                                foundTransferSyntaxUID=out4.string;
                                explanation='(Big endian, explicit)';
                                supportedTransferSyntaxFlag=0;
                            end                  
                        catch end 
                        
                       % Not supported!
                       if ~supportedTransferSyntaxFlag
                            % Compressed transfer syntax UIDs use explanation='(Little endian, explicit)';
                            % Guess that this is the case for all not supported, which makes sense
                            guessByteOrder='l'; %Little endian
                            guessedMode=2;      %Explicit
                            foundTransferSyntaxUID=out3.string;
                            explanation='(Little endian, explicit)';                           
                        end
                        

                    catch end
                    
                    disp(['Transfer syntax UID=' foundTransferSyntaxUID ' ' explanation]); 
                
                   
            %
            % Check if supported
            %
                if ~supportedTransferSyntaxFlag
                    warndlg({['NOT SUPPORTED DICOM format'],'',['Transfer syntax UID=' foundTransferSyntaxUID]});
                    close(waitBarHandle);
                    throw(exception)                     
                end

            %
            % User Input (pixels and slices)
            %
                prompt={'Pixels', 'Slices', 'Byte order - b or l (little L)','Explicit or not (Explicit VR=2, otherwise =0)'};
                title='Input data dimensions'; numlines=1; 
                defaultanswer={'128','1',guessByteOrder, num2str(guessedMode)};
                defaultanswer{2}='*';  % Error
%                 try 
%                     % Try reading number of slices
%                     out3=dirtyDICOMHeaderData(headers, 1, '0054', '0081',guessedMode);
%                     defaultanswer{2}=num2str(out3.bytes(1)+256*out3.bytes(2));
%                 catch
%                     try
%                         % Try again with "images in acquisition"
%                         out3=dirtyDICOMHeaderData(headers, 1, '0020', '1002',guessedMode);
%                         defaultanswer{2}=out3.string;    
%                     catch
%                     end
%                 end

% TRY OPPOSITE ORDER 
                try                        
                    % Try again with "images in acquisition"
                        out3=dirtyDICOMHeaderData(headers, 1, '0020', '1002',guessedMode);
                        defaultanswer{2}=out3.string;    
                catch
                    try
                    % Try reading number of slices
                    out3=dirtyDICOMHeaderData(headers, 1, '0054', '0081',guessedMode);
                    defaultanswer{2}=num2str(out3.bytes(1)+256*out3.bytes(2));

                    catch
                    end
                end
% END TRY OPPOSITE ORDER 


                try
                    % Try reading number of pixels
                    temp=dirtyDICOMHeaderData(headers, 1, '0028', '0010',guessedMode);
                    defaultanswer{1}=num2str(temp.bytes(1)+256*temp.bytes(2));
                catch   
                end
                
                answer=defaultanswer;
                %answer=inputdlg(prompt,title,numlines,defaultanswer);
                
                if ~strcmp(answer{2},'*');
                    numberOfSlices=str2num( answer{2} );
                end

                
                mode=str2num(answer{4});  
                pixelsize=str2num(answer{1}); 
                machineFormat=answer{3};
                rows=pixelsize;
                columns=pixelsize;
                
                % Unequal pixel sizes
                try
                    % Try reading number of pixels
                    temp=dirtyDICOMHeaderData(headers, 1, '0028', '0010',guessedMode);
                    rows=(temp.bytes(1)+256*temp.bytes(2));
                catch   
                end
                try
                    % Try reading number of pixels
                    temp=dirtyDICOMHeaderData(headers, 1, '0028', '0011',guessedMode);
                    columns=(temp.bytes(1)+256*temp.bytes(2));
                catch   
                end


            %     
            % Read scan info
            %
                imlook4dWindowTitle=file; % Initial guess

                try
                    dispLine;
                    out3=dirtyDICOMHeaderData(headers, 1, '0008', '0060',mode);
                        disp(['Modality=' out3.string]);
                        modality=out3.string;                   
                    
                    out3=dirtyDICOMHeaderData(headers, 1, '0010', '0010',mode);
                        disp(['Patient name=' out3.string]);
                        imlook4dWindowTitle=out3.string;
                    out3=dirtyDICOMHeaderData(headers, 1, '0010', '0020',mode);
                        disp(['Patient id=' out3.string]);
                        %imlook4dWindowTitle=[imlook4dWindowTitle '(' out3.string ')'];

                    out3=dirtyDICOMHeaderData(headers, 1, '0008', '0020',mode);
                        disp(['Study date=' out3.string]);
                        imlook4dWindowTitle=[imlook4dWindowTitle '(' out3.string ];

                    %
                    try
                        out3=dirtyDICOMHeaderData(headers, 1, '0008', '0031',mode);  % Series time
                        disp(['Series time=' out3.string]);
                    catch
                        out3=dirtyDICOMHeaderData(headers, 1, '0008', '0030',0);     % Study time
                        disp(['Study time=' out3.string]);
                    end
                        
                        imlook4dWindowTitle=[imlook4dWindowTitle '@' out3.string(1:2) ':' out3.string(3:4)  ')'];

                
                    out3=dirtyDICOMHeaderData(headers, 1, '0020', '0010',mode);
                        disp(['Study id=' out3.string]);
                        
                   try
                        out3=dirtyDICOMHeaderData(headers, 1, '0018', '1075',mode);
                            disp(['halflife=' out3.string]);                        
                         halflife=str2num(out3.string);
                   catch
                   end

                    dispLine;       
                catch
                    % Fallback - use directory name as title
                    [pathstr, name, ext] = fileparts(directoryPath( 1:end-1 ));  % Remove mandatory last character filesep ( \ or / )
                    imlook4dWindowTitle=name;
                    
                    % Remove if starts with modality - [PT] (Compatibility
                    % with Dicom2USB)
                    if strcmp( [ '[' modality ']' ], imlook4dWindowTitle(1:4) )
                        imlook4dWindowTitle=imlook4dWindowTitle(5:end);
                    end
                end
%                 
%                    
%             %
%             % Check if supported
%             %
%                 if ~supportedTransferSyntaxFlag
%                     warndlg({['NOT SUPPORTED DICOM format'],'',['Transfer syntax UID=' foundTransferSyntaxUID]});
%                     close(waitBarHandle);
%                     throw(exception)                     
%                 end
   
                
            %     
            % Multiple slices in selected file - set up
            %
            
                % Get filesize
                if strcmp( directoryPath(1), '\')  % Windows network paths have \\
                    directoryPath=['\' directoryPath];
                end
                
                temp=dir([directoryPath selectedFile]);
                selectedFileSize=temp.bytes;
                
                % Get start of data
                out3=dirtyDICOMHeaderData(headers, 1, '7FE0', '0010',mode);  % Find start of data
%                 startOfPixelData=out3.indexHigh;
%                 
                % Calculate number of data bytes
%                 numberOfBytesInData=(selectedFileSize-startOfPixelData-4);
                
                numberOfBytesInData=out3.valueLength;
                
%                 if (guessedMode==2)
%                     startOfPixelData=out3.indexHigh;
%                     numberOfBytesInData=(selectedFileSize-startOfPixelData-4);
%                 end
                
                % Multiple images in same file 
                    SingleFileWithMultipleSlices=( numberOfBytesInData > 2*rows*columns );

                    % Setup 
                    if SingleFileWithMultipleSlices
                        % Multiple slices in file
                        disp('Multiple slices in selected file');

                        % Change so that only one selected file is used
                        fileNames=dir([directoryPath selectedFile]);
                    end
            %     
            % Pixel representation - set up
            %                
                % Number of bytes per pixel
                    out3=dirtyDICOMHeaderData(headers, 1, '0028', '0100',mode);  % Bits allocated
                    numberOfBitsStored=out3.bytes(1)+256*out3.bytes(2);
                    numberOfBytesPerPixel=numberOfBitsStored/8;
                    
                % Number format
                    out3=dirtyDICOMHeaderData(headers, 1, '0028', '0103',mode);  % Pixel Representation 
                    if (out3.bytes(1)+256*out3.bytes(2))==0  % 0 means unsigned
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
                    signed=( (out3.bytes(1)+256*out3.bytes(2))==0 );
                    

                
                
%
% INPUT DICOM FILES
%
    
     %Get number of selected files.
     iNumberOfSelectedFiles = length(fileNames);

     count=0;  % Number of accepted files
     %matrix=zeros(rows,columns,iNumberOfSelectedFiles, 'single');
     matrix=zeros(columns,rows,iNumberOfSelectedFiles, 'single'); 

        for nr=1:iNumberOfSelectedFiles  %Ignore directories '.' and '..'
            if (mod(nr, 100)==0) waitbar(nr/iNumberOfSelectedFiles); end

            
            try    
                tempFilename= [directoryPath fileNames(nr).name];              
                fileSize=fileNames(nr).bytes;
% %                 headerSize1=fileSize-numberOfBytesInData;  % Assume data at end of file
                
                % NEW Read Data, Assume nothing about data position
                fid = fopen(tempFilename,'r');
                A = fread(fid,'uint8');
                out4=dirtyDICOMHeaderData({A}, 1, '7FE0', '0010',mode);
                startOfPixelData = out4.indexLow;
                headerSize2 = startOfPixelData - 1;
                numberOfBytesInData=out4.valueLength; 
                fclose(fid);
                
                % Use OLD or NEW fileSize
                %headerSize = headerSize1;  % From file size
                headerSize = headerSize2;  % From (7FE0,0010)

                
                if  (headerSize>0)  % Ignore really small files
% %                  % Read header and data
% %                     fid = fopen(tempFilename, 'r',machineFormat);
% %                     tempHeader= fread(fid, headerSize);                     % Binary header in memory  
% %                     
% %                     % Determine number of bytes per pixel
% %                     
% %                    % tempData= fread(fid, numberOfBytesInData, 'int16');     % Data in memory 
% %                     tempData = fread(fid, numberOfBytesInData / numberOfBytesPerPixel, numberFormat);     % Data in memory 
% % 
% %                     fclose(fid);
                     
                    % NEW - Read header and data
                    tempHeader = A(1:headerSize-1);
                    tempData = typecast( uint8(A(startOfPixelData:startOfPixelData+numberOfBytesInData-1)), numberFormat);
                   
                    % Test if DICOM file or Hermes export
                    if strcmp(char(tempHeader(129:132))', 'DICM') || strcmp(char(tempHeader(129:132))', '1000') 
                        
                        % Two cases:
                        % a) multiple images in one file (nuclear medicin) 
                        % b) single image in many files (most often)
                        if SingleFileWithMultipleSlices  % a)
                            count=numberOfBytesInData/(numberOfBytesPerPixel*rows*columns);
                            matrix=single(reshape(tempData(:),columns,rows,count)); % Allow to grow to number of slices
                            for i=1:count
                                header{i}=tempHeader;% Same header in every image
                                outputFileName{i}=tempFilename;% Same filename for every image
                            end  
                        else  % b)
                            count=count+1;    % Succesful read
                            try
                                matrix(:,:,count)=single(reshape(tempData(:),columns,rows,1));
                                %disp(['      - tempData=[' num2str(size(tempData)) '] rows=' num2str(rows) ' columns=' num2str(columns) ' rows*columns=' num2str(rows*columns) ' file=' tempFilename]);
                            catch
                                %disp(['ERROR - tempData=[' num2str(size(tempData)) '] rows=' num2str(rows) ' columns=' num2str(columns) ' rows*columns=' num2str(rows*columns) ' file=' tempFilename]);
                            end
                            header{count}=tempHeader;
                            %fileName{count}=tempFilename;
                            outputFileName{count}=tempFilename;

                            %disp([TAB 'Accepting file='
                            %sTempFilenameStruct(nr).name ]);                        
                        end
                        
                    else
                        %disp([TAB 'ERROR Ignoring file=' tempFilename '   (Not a DICOM file)']);
                        disp([TAB 'Ignoring file=' tempFilename '   (Not a DICOM file)']);
                    end
                    %---------------------------------
                    
                end
                
            catch % Error handling (too small files are not accepted)
                disp([TAB 'ERROR Ignoring file=' tempFilename '  (Error caught)']);
            end

        end
        
        matrix=matrix(:,:,1:count);    
        
% 
% Scale data
% 
    lastIndex=size(header,2);
    try
        for i=1:lastIndex;  
            % Rescale slope
            out=dirtyDICOMHeaderData(header, i, '0028', '1053',mode);
            indecesToScaleFactor{i}.low=out.indexLow;
            indecesToScaleFactor{i}.high=out.indexHigh;
            scaleFactor=str2num(out.string);
            
            % Rescale intercept
            out2=dirtyDICOMHeaderData(header, i, '0028', '1052',mode);
            intercept=str2num(out2.string);

            matrix(:,:,i)=scaleFactor*matrix(:,:,i)+intercept;
        end
    catch
       warning('Did not find DICOM tag (0028,1053) or (0028,1052)  - intercept and slope');
%        msgbox({'Did not find DICOM tag (0028,1053) or (0028,1052)  ',...
%                'Creating fake scale factor (=1)'...
%                },...
%                'Error reading DICOM', 'warn') 
       %disp(['File nr, i=' num2str(i)];
       disp('Creating scale factor (=1)');

       % Create fake scale factors:
       for i=1:lastIndex;  
            indecesToScaleFactor{i}.low=1;
            indecesToScaleFactor{i}.high=1;
%             scaleFactor=1;
%             matrix(:,:,i)=scaleFactor*matrix(:,:,i);
        end                 

    end
    

%
% Set number of frames and slices
%
       %if (numberOfSlices<=0)
       if strcmp(answer{2},'*');
           numberOfFrames=1;
           numberOfSlices=count;
       else
            numberOfFrames=count/numberOfSlices;
       end 

       
%
% Get extra image information
%       
       
    % Pixel size
          try
            out2=dirtyDICOMHeaderData(header, i, '0028', '0030',mode);
            str=out2.string
            temp=strfind(str,'\'); 
            pixelSizeX=str2num( str(1:temp(1)-1 ));  % X-size (mm)
            pixelSizeY=str2num(  str(temp(1)+1:end)  );% Y-size (mm)
          catch   
             pixelSizeX=1;
             pixelSizeY=1;
          end
          
     % Slice spacing
           try
            out2=dirtyDICOMHeaderData(header, i, '0018', '0050',mode);
            sliceSpacing=str2num(out2.string);  %
          catch   
             %sliceSpacing=-1
             sliceSpacing=1
           end    
          
           
           % ImagePosition
           for i=1:lastIndex;
               try
                   out2=dirtyDICOMHeaderData(headers, 1, '0020', '0032',guessedMode);
                   str=out2.string;
                   temp=strfind(str,'\');
                   x=str2num( str(1:temp(1)-1 ));      % X-pos (mm)
                   y=str2num(  str(temp(1)+1 : temp(2)-1)  );  % Y-pos (mm)
                   z=str2num(  str(temp(2)+1 : end ) );  % Z-pos (mm)
                   imagePosition{i}=[x; y; z];
               catch
                   imagePosition{i}=[0; 0; 0];
               end
           end
           
%            % PatientOrientation
%             %(0020,0037) DS #14 [-1\0\0\0\-1\0] Image Orientation (Patient)
%            for i=1:lastIndex;
%                try
%                    out2=dirtyDICOMHeaderData(headers, 1, '0020', '0037',guessedMode);
%                    str=out2.string;
%                    temp=strfind(str,'\');
%                    orientation(1)=str2num( str(1:temp(1)-1 ));               % Vector orientation for rows X
%                    orientation(2)=(  str(temp(2)+1 : temp(1)-1)  );   % Vector orientation for rows Y
%                    orientation(3)=(  str(temp(3)+1 : temp(2)-1)  );   % Vector orientation for rows Z
%                    orientation(4)=str2num(  str(temp(4)+1 : temp(3)-1)  );   % Vector orientation for columns in image X
%                    orientation(5)=str2num(  str(temp(5)+1 : temp(4)-1)  );   % Vector orientation for columns in image Y
%                    orientation(6)=str2num(  str(temp(6)+1 : end ) );         % Vector orientation for columns in image Z
%                catch
%                    disp(['Failed reading PatientOrientation=' orientation' ]);
%                end
%            end

%
% Finalize
%
       if (count>1)  % Display if more than one file
            disp([' Accepted ' num2str(count) ' files']);
       end
       if (iNumberOfSelectedFiles>count)   %
            %disp([' Warning ' num2str(count) ' files accepted, out of ' num2str(iNumberOfSelectedFiles) 'selected']);
       end

        close(waitBarHandle);
        
        
        % Save header and subheader
            outputStruct.dirtyDICOMHeader=header;
            outputStruct.dirtyDICOMFileNames=outputFileName;
            outputStruct.dirtyDICOMPixelSizeString=answer{1};
            %outputStruct.dirtyDICOMSlicesString=answer{2};
            outputStruct.dirtyDICOMSlicesString=num2str(numberOfSlices);
            outputStruct.dirtyDICOMMachineFormat=answer{3};
            outputStruct.dirtyDICOMMode=mode;   % Explicit or implicit 2 or 0
            outputStruct.dirtyDICOMIndecesToScaleFactor=indecesToScaleFactor;
            outputStruct.title=imlook4dWindowTitle;
            outputStruct.modality=modality;
            outputStruct.pixelSizeX=pixelSizeX;
            outputStruct.pixelSizeY=pixelSizeY;
            outputStruct.sliceSpacing=sliceSpacing;
            outputStruct.imagePosition=imagePosition;
            outputStruct.orientation=outputStruct;
            try
                outputStruct.halflife=halflife;
            catch
            end;
        
        
        
        
