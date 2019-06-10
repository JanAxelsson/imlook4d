 function imageStruct = OpenDicom(dicomFile)
 % Open Dicom files using functions derived from imlook4d 
 %
 % Input: path to dicom file
 % Output: imageStruct (where imageStruct.Cdata = matrix)
 %
 % Example: 
 %    imageStruct = OpenDicom('/Users/jan/Desktop/IMAGES/Volkers studie/OMGJORDA PET 118 119 120 126 127 132/PET126 (2017-MAY-29) - 329831/[PT] Reg(221342_2,221342_6) PET126 in CT space femur - serie651/1')
 
    [directoryPath,name,ext] = fileparts(dicomFile);
    file = [ name ext];
 
    imageStruct = LocalOpenDirtyDICOM3(gcf, [], guidata(gcf), file, [directoryPath filesep]);
 
% Copied and edited from imlook4d 500-rc36
function outputImageStruct = LocalOpenDirtyDICOM3(hObject, eventdata, handles, file,directoryPath)

 
                % This function is a new version which relies on new external
                % functions
                    selectedFile=file;


                %
                % Select files
                %
                    prompt={'Filter (for instance PT* )'};
                    title='Input File filter';
                    numlines=1;
                    [pathstr,name,ext] = fileparts(file);
        
                    % Give a pattern
                    defaultanswer={['*']};answer=defaultanswer;

                    %answer=inputdlg(prompt,title,numlines,defaultanswer); % Dialog for input of pattern
                  
                    fileFilter=answer{1};

                    % Create list of file names
                    fileNames=dir([directoryPath fileFilter]);

                %
                % Open scaled image
                %
                    try
                        [outputMatrix, outputStruct]=JanOpenScaledDICOM(directoryPath, fileNames, selectedFile);
                    catch
                        disp('imlook4d ERROR: Failed opening images (when calling JanOpenScaledDICOM) ');
                        disp(lasterr)
                        
                        return
                    end
                    %numberOfSlices=str2num(outputStruct.dirtyDICOMSlicesString);

                %
                % Display list of tags
                %
                    %headers=outputStruct.dirtyDICOMHeader;
                    mode=outputStruct.dirtyDICOMMode;

                    dummy1=1;dummy3='l'; [Data, headers, dummy]=Dirty_Read_DICOM(directoryPath, dummy1,dummy3, file); % selected file

                    % Initial tags
                    disp('INFORMATION FROM DICOM FILE=');
                    disp([ '   ' directoryPath name ext] );
                    
                    % Display tags
                    displayDicomListOfTags( headers, mode);

                %  
                % Sort
                %
                    try
                        [outputMatrix, outputStruct]=dirtyDICOMsort( outputMatrix, outputStruct);  
                    catch
                        disp('imlook4d ERROR: Failed sorting images');
                    end
                    
                    sliceLocations=outputStruct.dirtyDICOMsortedIndexList(:,3);

                    
                %
                % Find the different series, and select which one to open
                %
                    [b, m, n]=unique(outputStruct.dirtyDICOMsortedIndexList(:,6),'first');  % m is index to row
                    
                    % If more than one series - redo opening with selected scan 
                    % Exception, File/Open and Merge
                    
                    multipleSeries=(size(m,1)>1)
                    try
                        openAndMergeMode=strcmp(get(hObject,'Label'),'Open and merge');
                    catch
                        openAndMergeMode=0;
                    end
                        
                    
                    if (multipleSeries & ~openAndMergeMode)
                    %if size(m,1)>1
                        
                        % Populate listdlg selection box
                        for i=1:size(m,1)
                            TAB='   ';
                            
                            try
                                patientName=dirtyDICOMHeaderData(outputStruct.dirtyDICOMHeader, m(i),'0010', '0010',mode);
                            catch
                                patientName.string='';
                            end
                            
                            try
                                patientID=dirtyDICOMHeaderData(outputStruct.dirtyDICOMHeader, m(i),'0010', '0020',mode);
                            catch
                                patientID.string='';
                            end
                            try
                                studyDesc=dirtyDICOMHeaderData(outputStruct.dirtyDICOMHeader, m(i),'0008', '1030',mode);
                            catch
                                studyDesc.string='';
                            end
                            
                            try
                                seriesDesc=dirtyDICOMHeaderData(outputStruct.dirtyDICOMHeader, m(i),'0008', '103E',mode);
                            catch
                                seriesDesc.string='';
                            end
                            
                            
                           % Default colors
                           str{i}=[patientName.string TAB '(' patientID.string ')' TAB studyDesc.string TAB '---' TAB seriesDesc.string];
                            
                           % Colored text in listdlg
                           strColor{i}=[ '<HTML><FONT color="blue">' patientName.string TAB '</FONT>' ...
                                    '<HTML><FONT color="gray">' '(' patientID.string ')' TAB '</FONT>' ...
                                    '<HTML><FONT color="blue">' studyDesc.string TAB '</FONT>' ...
                                    '<HTML><FONT color="gray">' TAB seriesDesc.string '</FONT>' ...
                                    '</HTML>' ];
                           
                        end


                        % Select
                        try
                            % Colored text in listdlg 
                            [selected,v] = listdlg('PromptString','Select scan to open:',...
                                  'SelectionMode','single',...
                                  'ListSize', [800 400], ...
                                  'ListString',strColor);
                        catch
                            % Default black and white text
                             [selected,v] = listdlg('PromptString','Select scan to open:',...
                                  'SelectionMode','single',...
                                  'ListSize', [800 400], ...
                                  'ListString',str);                           
                        end
                          
                        % Make file list from selected series
                        counter=0;
                        for i=1:size(outputStruct.dirtyDICOMsortedIndexList,1)
                            if outputStruct.dirtyDICOMsortedIndexList(i,6)==b(selected)
                                counter=counter+1;
                                [pathstr, name, ext] = fileparts(outputStruct.dirtyDICOMFileNames{ i });
                                newFileNames(counter,1).name=[name ext];
                                
                                temp=dir(newFileNames(counter,1).name);
                                newFileNames(counter,1).bytes=temp.bytes;
                            end
                        end
                        
                        selectedFile=newFileNames(1,1).name;



                        % Open selected series
                        try
                            [outputMatrix, outputStruct]=JanOpenScaledDICOM(directoryPath, newFileNames, selectedFile);
                        catch
                            disp('imlook4d ERROR: Failed opening images');
                        end
                        
                        % Sort selected series
                        try
                            [outputMatrix, outputStruct]=dirtyDICOMsort( outputMatrix, outputStruct);  
                        catch
                            disp('imlook4d ERROR: Failed sorting images');
                        end
                        
                    end % End selection if more than one series


                %
                % Display information about the tags used in sorting
                %
                    sortedIndexList=outputStruct.dirtyDICOMsortedIndexList;
                    disp(' ');
                    disp('   Sorting parameters (sort order from left to right)');  

%                     disp( [sprintf( '   %-10s %-20s %-23s %-20s %-20s\n', '    ', '2)Frame ref time','Original image index','3)Slice location','1)Acquisition time' ) ...
%                         sprintf( '   %-10s %-20s %-23s %-20s %-20s\n', '    ', '(0054,1300)','(File input order)','(0020,1041)','(0008,0032)' ) ...
%                         sprintf('   %-10s %-20d %-23d %-20.3f %-20f\n' , 'min:', min(sortedIndexList) )  ...
%                         sprintf('   %-10s %-20d %-23d %-20.3f %-20f\n' , 'max:', max(sortedIndexList) )]...
%                     )


                    tempMin=min(sortedIndexList);
                    tempMax=max(sortedIndexList);
                    myFormat=       '   %-10s %-25f  %-10d %-17.3f %-15d %-10.0f %-20d\n';
                    try
                    disp( [sprintf( '   %-10s %-25s %-10s %-17s %-15s %-10s %-20s\n', ...
                                            '    ', 'Series Instance UID', 'Acq date','Slice location', 'Frame ref time',  'Acq time','Original image index' ) ...
                        sprintf( myFormat , 'min:' ,    tempMin(6),tempMin(5),tempMin(3),tempMin(1),tempMin(4),tempMin(2) )  ...
                        sprintf( myFormat , 'max:' ,    tempMax(6),tempMax(5),tempMax(3),tempMax(1),tempMax(4),tempMax(2) )  ...
                        sprintf('   %-10s\n','  ') ...
                        sprintf( myFormat , '1st row:' , sortedIndexList(1,6),  sortedIndexList(1,5), sortedIndexList(1,3), sortedIndexList(1,1),   sortedIndexList(1,4), sortedIndexList(1,2) )...
                        sprintf( myFormat , '2nd row:' , sortedIndexList(2,6),  sortedIndexList(2,5), sortedIndexList(2,3), sortedIndexList(2,1),   sortedIndexList(2,4), sortedIndexList(2,2) )...
                        sprintf('   %-10s\n',' ... ') ...
                        sprintf( myFormat , 'end row:' , sortedIndexList(end,6),  sortedIndexList(end,5), sortedIndexList(end,3), sortedIndexList(end,1),   sortedIndexList(end,4), sortedIndexList(end,2) ) ]...
                    )
                    catch
                    end
                    
                    
                    myFormat=       '   %-10s %-25.0f  %-10d %-10d %-17.3f %-15d %-12.0u %10.0f %-20d\n';
                    try
                        disp(' ');
                        disp( sprintf( '   %-10s %-25s %-10s %-10s %-17s %-15s %-12s %-10s %-20s\n', ...
                                                '    ', 'Series Instance UID', 'Acq date','Trig Time' , 'Slice location', 'Frame ref time',  'Acq time','Instance No', 'Original image index' ) );
                        disp(  sprintf( myFormat , 'min:' ,    tempMin(6),tempMin(5),tempMin(7),tempMin(3),tempMin(1),tempMin(4),tempMin(8),tempMin(2) )  );
                        disp(  sprintf( myFormat , 'max:' ,    tempMax(6),tempMax(5),tempMax(7),tempMax(3),tempMax(1),tempMax(4),tempMax(8),tempMax(2) )  );
                        disp(  sprintf('   %-10s\n','  ')  );
                        for i=1:size(sortedIndexList,1)
                           %disp( sprintf( myFormat , ['row=' num2str(i)] , sortedIndexList(i,6),  sortedIndexList(i,5),sortedIndexList(i,7), sortedIndexList(i,3), sortedIndexList(i,1),   sortedIndexList(i,4),sortedIndexList(i,8), sortedIndexList(i,2) ) )
                        end
        
                        disp( sprintf( myFormat , 'end row:' , sortedIndexList(end,6),  sortedIndexList(end,5),sortedIndexList(end,7), sortedIndexList(end,3), sortedIndexList(end,1),   sortedIndexList(end,4),sortedIndexList(end,8), sortedIndexList(end,2) ) )
                    catch
                    end                    
                    


                %
                % Get time, duration, and halflife
                %
                    try
                        [outputStruct]=dirtyDICOMTimeAndDuration( outputStruct);
                    catch
                        disp('imlook4d ERROR: Failed reading time and duration');
                    end

                    % If "File/Open and merge" is selected, the time is calculated
                    % from Acquisition time, relative first slice.
                    try
                        %if strcmp(get(hObject,'Label'),'Open and merge')
                        if openAndMergeMode

                            [outputStruct]=dirtyDICOMTimeFromAcqTime(outputStruct);
                        end
                    catch
                    end

                %
                % Calculate number of slices and number of frames
                %
                    % Get number of patient positions (column 3) that equals first patient position
                    % => number of frames /gates/ phases
                    numberOfFrames=sum( sortedIndexList(:,3)==sortedIndexList(1,3)); % Number of frames

                    % Get number of slices from total number of images, and number
                    % of frames
                    numberOfSlices=size(sortedIndexList,1) / numberOfFrames;
                    if mod( size(sortedIndexList,1), numberOfFrames )
                       h=errordlg({'Number of slices and number of images do not match',...
                           ['Number of images i=' num2str( size(sortedIndexList,1) )], ...
                           ['Number of frames f=' num2str(numberOfFrames) '  at position=' num2str( sortedIndexList(1,3) )]...
                           ['giving number of slices i/f=' num2str( numberOfSlices ) '  (which should be an integer)'], ...
                           [''], ...
                           ['Make sure that only files acquired at same positions are opened'], ...
                           });
                       uiwait(h);
                    end
                    
                %    
                % Special - multiple images in same file
                %
                
                    % if a single DICOM file had multiple images, then above method does not work.  
                    % Use that the filename is the same for all images, to determine that this is the case.
                    % Correct above and follow the Frame increment pointer order
                    if sum(strcmp(outputStruct.dirtyDICOMFileNames(:),outputStruct.dirtyDICOMFileNames(1)))>1
                        numberOfImages=size(outputStruct.dirtyDICOMFileNames(:),1);
                        numberOfSlices = length( outputStruct.imagePosition )
                        
                        % Find all Frame Increment Pointers
                        out0=dirtyDICOMHeaderData(headers, 1, '0028', '0009',mode); % Frame increment pointer
                        counter = 0;
                        dim = [];
                        for k = 1 : (out0.valueLength / 4)
                            start = (k-1)*4 + 1;
                            tagString = out0.bytes( start : (start+3) );
                            tag = [ uint8_to_hex( tagString(2)) uint8_to_hex( tagString(1)) uint8_to_hex( tagString(4)) uint8_to_hex( tagString(3))];

                            % Leave slices, and handle separately outside loop                            
                            if ~strcmp(tag, '00540080')
                                counter = counter + 1;
                                frameIncrementPointers{counter} = tag;
                                vectorTag = dirtyDICOMHeaderData(headers, 1, tag(1:4), tag(5:8),mode,2); % Second instance (since found in 00280009)
                                vector = 256 * vectorTag.bytes(2:2:end) + vectorTag.bytes(1:2:end);
                                dim(counter) = max(vector); % vector with number of elements in each dimension
                            end
                        end
                        
                        
                        % Remove slices from dim, and handle separately (so
                        % slices always in 3:d dimension
                        numberOfSlices = 1;
                        try
                            out0=dirtyDICOMHeaderData(headers, 1, '0054', '0081',mode); % Number of slices
                            numberOfSlices = 256 * out0.bytes(2) + out0.bytes(1);
                        catch
                            
                        end
                        
                        
                        % Reshape matrix
                        nx = size(outputMatrix,1);
                        ny = size(outputMatrix,2);
                        dims = [ nx ny numberOfSlices dim];
                        outputMatrix = reshape( outputMatrix, dims);
            
                         
                         % Set time
                         
                         try
                            out=dirtyDICOMHeaderData(outputStruct.dirtyDICOMHeader, 1, '0018', '1242',mode);
                            timeStep=str2num(out.string) / 1000; % Timestep in seconds
                            outputStruct.duration = timeStep * ones( 1 , size(outputMatrix,4) );
                            outputStruct.duration2D = repmat( outputStruct.duration, size(outputMatrix,3), 1);

                            outputStruct.time = cumsum( outputStruct.duration) - outputStruct.duration;  % Start from time zero
                            outputStruct.time2D = repmat( outputStruct.time, size(outputMatrix,3), 1);
                         catch
                         end                     
                        
                        
                    end

                    
                %
                % Fix DICOM y-axis
                %
                    outputMatrix=imlook4d_fliplr(outputMatrix);  % Flip row vector (which is the y direction of the matrix)

%                 %                
%                 % New imlook4d 
%                 %             
%                     try
%                         h=imlook4d(single(reshape(outputMatrix,size(outputMatrix,1),size(outputMatrix,2),numberOfSlices,[]) ),outputStruct.time, outputStruct.duration);
%                     catch
%                         h=imlook4d(single(reshape(outputMatrix,size(outputMatrix,1),size(outputMatrix,2),numberOfSlices,[]) ));
%                     end
% 
%                     set(h,'Name', ['[' outputStruct.modality '] ' outputStruct.title]); % Window title
%                     newhandles = guidata(h);
%                     
%                     % Close imlook4d, and save only handles
%                     close(h)

                    outputMatrix = reshape(outputMatrix,size(outputMatrix,1),size(outputMatrix,2),numberOfSlices,[]);

                    newhandles.image.Cdata = outputMatrix;

                    % Save header and subheader
                    newhandles.image.dirtyDICOMHeader=outputStruct.dirtyDICOMHeader;
                    newhandles.image.dirtyDICOMFileNames=outputStruct.dirtyDICOMFileNames;
                    newhandles.image.dirtyDICOMPixelSizeString=outputStruct.dirtyDICOMPixelSizeString;
                    newhandles.image.dirtyDICOMSlicesString=outputStruct.dirtyDICOMSlicesString;
                    newhandles.image.dirtyDICOMMachineFormat=outputStruct.dirtyDICOMMachineFormat;
                    newhandles.image.dirtyDICOMIndecesToScaleFactor=outputStruct.dirtyDICOMIndecesToScaleFactor;
                    newhandles.image.dirtyDICOMMode=outputStruct.dirtyDICOMMode;   % Explicit or implicit 2 or 0
                    newhandles.image.fileType='DICOM';
                    newhandles.image.pixelSizeX=outputStruct.pixelSizeX;
                    newhandles.image.pixelSizeY=outputStruct.pixelSizeY;
                    newhandles.image.sliceSpacing=outputStruct.sliceSpacing;
                    newhandles.image.imagePosition=outputStruct.imagePosition;
                    newhandles.image.modality=outputStruct.modality;
                    
                    newhandles.image.sliceLocations=sliceLocations;
                    newhandles.image.DICOMsortedIndexList=outputStruct.dirtyDICOMsortedIndexList;
                    
                    try
                        unit=dirtyDICOMHeaderData(headers, 1, '0054', '1001' ,mode); % Unit
                        newhandles.image.unit=unit.string;
                    catch
                    end
                    
                    try
                        newhandles.image.time2D=outputStruct.time2D;
                        newhandles.image.duration2D=outputStruct.duration2D;
                    catch
                    end
                    
                    try
                        newhandles.image.halflife=outputStruct.halflife;
                    catch
                    end;
                    
                    try
                        newhandles.image.time=outputStruct.time;
                        newhandles.image.duration=outputStruct.duration;
                    catch
                    end;                    
                %
                % Read DICOM image orientation vector
                %
                try
                    out=dirtyDICOMHeaderData(outputStruct.dirtyDICOMHeader, 1, '0020', '0037',mode);  %Spacing Between Slices (can be negative number)
                    sliceStep=str2num(out.string);
                    DicomImageOrientationVector =  str2num( strrep(out.string,'\',',') )
                    % Orientation vector of x axis (3 first numbers) and y axis (3 last numbers) 
                    newhandles.image.DicomImageOrientationVector = DicomImageOrientationVector;
                    
                catch
                    DicomImageOrientationVector = [1 0 0 0 1 0];  % Assumption
                end
                    
 % Skip GUI things                   
                    
%                     % Save guidata
%                     guidata(h, newhandles);  
%                     
%                     % Set Colorscale and modality
%                     %imlook4d_set_colorscale_from_modality(h, eventdata, newhandles);
%                     
%                     % Not sure why this works - since hObject is handle to
%                     % FILE/OPEN uimenu on the imlook4d instance that opened
%                     % this file.
%                  
%                     %imlook4d_set_colorscale_from_modality( get( findobj(hObject, 'Label', 'Gray') ), eventdata, newhandles);
%                     
%                     handleToColorMenu=findobj(newhandles.EditMenu, 'Label', 'Color');  % Menu Color
        outputImageStruct = newhandles.image;
    function displayDicomListOfTags( headers, mode)

    % MACHINE INFO
    disp('MACHINE INFO');
    displayDicomTag(headers, 1, 'Modality', '0008', '0060', mode);
    displayDicomTag(headers, 1, 'Manufacturer', '0008', '0070', mode);
    displayDicomTag(headers, 1, 'Model', '0008', '1090', mode);

    % OPENING 
    disp('OPENING');
    displayDicomTag(headers, 1, '*Transfer Syntax UID', '0002', '0010', mode);
    displayDicomTag(headers, 1, ' Number of slices', '0054', '0081', mode);
    displayDicomTag(headers, 1, ' Number of images in acq', '0020', '1002', mode);
    displayDicomTag(headers, 1, '*Number of pixels', '0028', '0010', mode);
    displayDicomTag(headers, 1, ' Study time', '0008', '0031', mode);
    displayDicomTag(headers, 1, '*Rescale Slope', '0028', '1053', mode);
    displayDicomTag(headers, 1, '*Rescale Intercept', '0028', '1052', mode);
    displayDicomTag(headers, 1, ' Rescale Type', '0028', '1054', mode);
    displayDicomTag(headers, 1, ' Unit', '0054', '1001', mode);
    % SORTING
    disp('SORTING');
    displayDicomTag(headers, 1, '*Frame reference time', '0054', '1300', mode);
    displayDicomTag(headers, 1, '*Slice location', '0020', '1041', mode);
    displayDicomTag(headers, 1, ' Patient position', '0020', '0032', mode);
    displayDicomTag(headers, 1, '*Acquisition time', '0008', '0032', mode);
    displayDicomTag(headers, 1, ' Temporal Position Identifer', '0020', '0100', mode);
    displayDicomTag(headers, 1, ' Image Number', '0020', '0013', mode);
    % Get time, duration, and halflife
    disp('TIME & DURATION');
    displayDicomTag(headers, 1, 'Frame duration', '0018', '1242', mode);
    displayDicomTag(headers, 1, 'Radioactive half life', '0018', '1075', mode); 
        function displayDicomTag( headers, number, name, group, element, mode)
           % This function displays OK if tag is found, otherwise BAD
           % String representation of tag is displayed (the first
           % characters)
           %
           % INPUT
           % - headers  cell array of binary headers
           % - number   which element in headers to display
           % - name     a string to display
           % - group    hexadecimal string, 4 characters, giving the tag group
           % - element  hexadecimal string, 4 characters, giving the tag element
           % - mode     0 or 2
           %
            NAMELENGTH=35;   % Length of name string to display
            STRINGLENGTH=35; % Length of output string
            name=[name '                                                        '];                  % fill with spaces

            try
                temp=dirtyDICOMHeaderData(headers, number, group, element,mode);
                outputString=[temp.string '                                                        '];   % fill with spaces
                disp([ '   [ OK ]' '  (' group ',' element ')   ' name(1:NAMELENGTH) '=' outputString(1:STRINGLENGTH) ]);
            catch
                disp([ '   [    ]' '  (' group ',' element ')   ' name(1:NAMELENGTH) '=' 'not defined' ]);
            end
