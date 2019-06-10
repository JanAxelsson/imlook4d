function [matrix, outputStruct]=JanOpenScaledDICOM(directoryPath, fileNames, selectedFile)
% JAN Added input fileNames which is a cell array of paths relative
% directoryPath
%
%     Purpose:  Read multiple DICOM files, storing header in binary format  
%

%
%     Input:        fileNames     struct where fileNames.name is the file name
%                                 struct where fileNames.bytes is the file size
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
            dummy1=1;dummy3='l'; [Data, headers, dummy]=Dirty_Read_DICOM(directoryPath, dummy1,dummy3, selectedFile); % selected file
            
    
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
                    try
                        if ( strcmp( out3.string(1:17), '1.2.840.10008.1.2'))
                            guessByteOrder='l'; %Little endian
                            guessedMode=0;      %Implicit
                            foundTransferSyntaxUID=out3.string;
                            explanation='(Little endian, implicit)';
                        end
                        if ( strcmp( out3.string(1:19), '1.2.840.10008.1.2.1'))
                            guessByteOrder='l'; %Little endian
                            guessedMode=2;      %Explicit
                            foundTransferSyntaxUID=out3.string;
                            explanation='(Little endian, explicit)';
                        end
                        if ( strcmp( out3.string(1:19), '1.2.840.10008.1.2.2'))
                            guessByteOrder='b'; %Big endian
                            guessedMode=2;      %Explicit
                            foundTransferSyntaxUID=out3.string;
                            explanation='(Big endian, explicit)';
                        end           

                    catch end
   
             %   
             % Decode transfer syntax UID assuming implicit VR (should always be explicit for group 0002)    
             %                
                try
                    out3=dirtyDICOMHeaderData(headers, 1, '0002', '0010',0);   
                    % Special for GE CT, which is wrong
                    if ( strcmp( out3.string(1:18), '1.2.840.113619.5.2'))
                        guessByteOrder='b'; %Big endian
                        guessedMode=0;      %Explicit
                        foundTransferSyntaxUID=out3.string;
                        explanation='(Big endian, explicit)';
                    end                  
                    
                catch end              
                
                disp(['Transfer syntax UID=' foundTransferSyntaxUID ' ' explanation]); 
            %
            % User Input (pixels and slices)
            %
                prompt={'Pixels', 'Slices', 'Byte order - b or l (little L)','Explicit or not (Explicit VR=2, otherwise =0)'};
                title='Input data dimensions'; numlines=1; defaultanswer={'128','1',guessByteOrder, num2str(guessedMode)};
                defaultanswer{2}='*';  % Error
                try 
                    % Try reading number of slices
                    out3=dirtyDICOMHeaderData(headers, 1, '0054', '0081',guessedMode);
                    defaultanswer{2}=num2str(out3.bytes(1)+256*out3.bytes(2));
                catch
                    try
                        % Try again with "images in acquisition"
                        out3=dirtyDICOMHeaderData(headers, 1, '0020', '1002',guessedMode);
                        defaultanswer{2}=out3.string;    
                    catch
                    end
                end
                
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

                    %out3=dirtyDICOMHeaderData(headers, 1, '0008', '0030',0);
                    out3=dirtyDICOMHeaderData(headers, 1, '0008', '0031',mode);
                        disp(['Study time=' out3.string]);
                        imlook4dWindowTitle=[imlook4dWindowTitle '@' out3.string(1:2) ':' out3.string(3:4)  ')'];

                    out3=dirtyDICOMHeaderData(headers, 1, '0020', '0010',mode);
                        disp(['Study id=' out3.string]);

                    out3=dirtyDICOMHeaderData(headers, 1, '0018', '1075',mode);
                        disp(['halflife=' out3.string]);                        
                        halflife=str2num(out3.string);

                    dispLine;       
                catch
                end
                
%
% INPUT DICOM FILES
%
    
     %Get number of selected files.
     iNumberOfSelectedFiles = length(fileNames);

     count=0;  % Number of accepted files
     matrix=zeros(pixelsize,pixelsize,iNumberOfSelectedFiles, 'single');

        for nr=1:iNumberOfSelectedFiles  %Ignore directories '.' and '..'
            if (mod(nr, 100)==0) waitbar(nr/iNumberOfSelectedFiles); end

            
            try    
                tempFilename= [directoryPath fileNames(nr).name];
                
                fileSize=fileNames(nr).bytes;

                headerSize=fileSize-2*pixelsize*pixelsize;
                
                if  (headerSize>0)  % Ignore really small files

                    fid = fopen(tempFilename, 'r',machineFormat);
                    tempHeader= fread(fid, headerSize);                     % Binary header in memory  
                    tempData= fread(fid, pixelsize*pixelsize, 'int16');     % Data in memory  

                    fclose(fid);
                    
                    % Test if DICOM file or Hermes export
                    if strcmp(char(tempHeader(129:132))', 'DICM') || strcmp(char(tempHeader(129:132))', '1000') 

                        count=count+1;    % Succesful read
                        matrix(:,:,count)=single(reshape(tempData(:),pixelsize,pixelsize,1));
                        header{count}=tempHeader;
                        %fileName{count}=tempFilename;
                        outputFileName{count}=tempFilename;

                        %disp([TAB 'Accepting file=' sTempFilenameStruct(nr).name ]);
                    else
                        %disp([TAB 'ERROR Ignoring file=' tempFilename '   (Not a DICOM file)']);
                        disp([TAB 'Ignoring file=' tempFilename '   (Not a DICOM file)']);
                    end
                    
                end
                
            catch % Error handling (too small files are not accepted)
                disp([TAB 'Ignoring file=' tempFilename '  (Error caught)']);
            end

        end
        
        
        matrix=matrix(:,:,1:count);
% 
% Scale data
% 

    try
        lastIndex=size(header,2);
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
       warning('Did not find DICOM tag (0028,1053) or (0028,1052)  ');
       msgbox({'Did not find DICOM tag (0028,1053) or (0028,1052)  ',...
               'Creating fake scale factor (=1)'...
               },...
               'Error reading DICOM', 'warn') 
       %disp(['File nr, i=' num2str(i)];
       disp('Creating fake scale factor (=1)');

       % Create fake scale factors:
       for i=1:lastIndex;  
            indecesToScaleFactor{i}.low=1;
            indecesToScaleFactor{i}.high=1;
            scaleFactor=1;
            matrix(:,:,i)=scaleFactor*matrix(:,:,i);
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
            pixelSizeY=str2num(  str(temp(1)+1:end)  );          % Y-size (mm)
          catch   
             
          end
          
     % Slice spacing
           try
            out2=dirtyDICOMHeaderData(header, i, '0018', '0050',mode);
            sliceSpacing=str2num(out2.string);  %
          catch   
             
          end    

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
            try
                outputStruct.halflife=halflife;
            catch
            end;
        
        
        
        