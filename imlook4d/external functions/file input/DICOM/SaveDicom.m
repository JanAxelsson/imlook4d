 function SaveDicom(imageStruct, folderPath)
 % Save Dicom files using functions derived from imlook4d 
 % Inputs: 
 %  imageStruct (where imageStruct.Cdata = matrix)
 %  path to dicom folder where saving should be
 %
 % Example: 
 %    SaveDicom(imageStruct,'/Users/jan/Desktop/test')
 
    handles.image = imageStruct;
    LocalSaveDICOM(handles, handles.image.Cdata, folderPath)
 
 % Copied and edited from imlook4d 500-rc36
 function LocalSaveDICOM(handles, matrix, newPath)
                
                        % Store dimensions
                            numberOfSlices = size(matrix,3);
                            numberOfFrames = size(matrix,4);
                
                        % Fix DICOM y-axis
                            matrix=imlook4d_fliplr(matrix);  % Flip row vector (which is the y direction of the matrix)
                
                        % Remove out of range values
                            matrix(isnan(matrix)) = 0;
                            matrix(isinf(matrix)) = 0;

                        % Read stored information
                            rows=size(matrix,2);
                            cols=size(matrix,1);

                            headers=handles.image.dirtyDICOMHeader;
                            matrix=reshape(matrix,rows,cols,[]);  % Matrix reshaped to 3D matrix (x,y,file nr) 

                            fileNames=handles.image.dirtyDICOMFileNames;
                            %indecesToScaleFactor=handles.image.dirtyDICOMIndecesToScaleFactor;
                            mode=handles.image.dirtyDICOMMode;

                        % USER INPUT:  Modify Patient ID, Patient Name, Series Description

                            try
                                % Get struct ,where patientName1.string is the
                                % string itself
                                try 
                                    patientName1=dirtyDICOMHeaderData(headers, 1,'0010', '0010',mode); 
                                catch
                                    patientName1.string=''
                                end
                                try  
                                    patientID1=dirtyDICOMHeaderData(headers, 1,'0010', '0020',mode);
                                catch
                                    patientID1.string='' 
                                end
                                try  
                                    seriesDesc1=dirtyDICOMHeaderData(headers, 1,'0008', '103E',mode);
                                catch
                                    seriesDesc1.string=''
                                end
                                try  
                                    accessionNumber=dirtyDICOMHeaderData(headers, 1,'0008', '0050',mode);
                                catch
                                    accessionNumber.string='';
                                end
                                seriesNo1=dirtyDICOMHeaderData(headers, 1,'0020', '0011',mode);
                                
                                try  
                                    modalityString=handles.image.modality;
                                catch
                                    modalityString='OT';
                                end

                                %defaultSeriesDescription=[ handles.image.history ' ' seriesDesc1.string];
                                defaultSeriesDescription= seriesDesc1.string;

                                prompt={'Patient Name: ',...
                                        'Patient ID: ',...
                                        'Series Description: ',...
                                        'Series number',...
                                        'Accesion number',...
                                        'Modality (2 chars, MR,CT,PT,NM,OT,...)'};
                                title='Modify DICOM header info';
                                numlines=1;
                                defaultanswer={patientName1.string,patientID1.string, defaultSeriesDescription ,seriesNo1.string, accessionNumber.string, modalityString};
                               %answer=inputdlg(prompt,title,numlines,defaultanswer);
                                answer = defaultanswer;
                                % Strings containing the patientName etc
                                patientName=answer{1};
                                patientID=answer{2};
                                seriesDesc=answer{3};
                                seriesNo=answer{4};
                                accessionNumberString=answer{5};
                                modalityString=answer{6};
                            catch
                            end

                        % USER INPUT:  Modify DICOM mode (commented out)

                            defaultanswer{1}=handles.image.dirtyDICOMPixelSizeString;
                            defaultanswer{2}=handles.image.dirtyDICOMSlicesString;
                            defaultanswer{3}=handles.image.dirtyDICOMMachineFormat;
                            answer=defaultanswer;

                            % Input pixels and slices
    %                         prompt={'Pixels',...
    %                                 'Slices',...
    %                                 'Byte order - b or l (little L)'};
    %                         title='Input data dimensions';
    %                         numlines=1;
    %                         answer=inputdlg(prompt,title,numlines,defaultanswer);
    % 
                             ByteOrder=answer{3};

                        % Calculate DICOM volume's min and max
                            volumeMax=max(matrix(:));
                            volumeMin=min(matrix(:));


%                         % Get new file paths
%                             suggestedDirName=get(handles.figure1, 'Name');
%                             cleanedDirName=regexprep(suggestedDirName, '[*"/[]:;|=\\]', '_');  % Avoid characters that are not accepted in Windows file names
% 
%                             % Create new directory describing DICOM file
%                             previousDirectory=pwd();
%                             cd .. 
%                             guessedDirectory=pwd();
%                             %%guessedDirectory=[previousDirectory filesep cleanedDirName];
%                             %%mkdir(previousDirectory,cleanedDirName);        % Guess a directory
%                             %%cd(guessedDirectory);                           % Go to guessed directory (uigetdir will be placed here)                
% 
%                            %newPath=uigetdir(guessedDirectory,'Select directory to save files to');
%                           %newPath=java_uigetdir(guessedDirectory,'Make an empty directory to save all DICOM files within'); % Use java directory open dialog (nicer than windows)
%                           newPath=java_uigetdir(previousDirectory,'Select/create directory to save files to'); % Use java directory open dialog (nicer than windows)
%                           if newPath == 0
%                               disp('Cancelled by user');
%                               return
%                           end
                          
                          
                          % Make directory if not existing
                          fn = fullfile(newPath);
                          if ~exist(fn, 'dir')
                              disp(['Make directory = ' newPath ]);
                              mkdir(fn);
                          end

                            try
                                cd(newPath);                                    % Go to selected directory
                            catch
                                try
                                    mkdir(newPath);
                                catch
                                    error(['imlook4d ERROR - failed creating directory' newPath]);
                                end
                            end
% 
%                             if( ~strcmp( guessedDirectory,newPath) )                   % If guessed wrong directory
%                                 try
%                                     rmdir([previousDirectory filesep cleanedDirName])
%                                 catch
%                                 end
%                             end




    %                         newPath=uigetdir(pwd(),'Select directory to save files to');
    %                         cd(newPath);



                        % Modify headers

                            iNumberOfSelectedFiles = size(headers,2);
                            iNumberOfSelectedFiles=size(matrix,3);  % This definition allows for truncated matrices, as for instance from Patlak model

                            
                            
                            
                            
                            waitBarHandle = waitbar(0,'Saving DICOM files');	% Initiate waitbar with text


                            seriesInstanceUID=generateUID();
                            interval = round( iNumberOfSelectedFiles/50);
                             for i=1:iNumberOfSelectedFiles
                                 %disp(i)
                                 if (mod(i, interval)==0) waitbar(i/iNumberOfSelectedFiles); end 
                                 
                                    % Set Modality
                                     headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0008', '0060',mode, modalityString); % ImageType

                                     % Change image properties
                                     headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0008', '0008',mode, 'DERIVED\SECONDARY'); % ImageType
                                     headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0008' ,'2111',mode, 'imlook4d - not for clinical use'); % Derivation Description


                                 % Set scale factors (Fails if scale factor not existing)
                                 try

                                    % Get indeces to header
                                        scaleFactor=dirtyDICOMHeaderData(headers, i, '0028', '1053',mode);
                                        intercept=dirtyDICOMHeaderData(headers, i, '0028', '1052',mode);

                                    %Calculate scale factor
                                        maxval = max(max(abs(matrix(:,:,i))));  %Maximum absolute value in image.
                                        scale_factor = maxval/32767;
                                        scale_factor=1.01*scale_factor;   % Play it safe

                                        %%%scale_factor=1;

                                        valueString=num2str(scale_factor);

                                    % Find out scaling to use for matrix data, assuming zero intercept
                                         scale_factor=str2num(valueString);  % This is a  smaller value due to truncation of decimals in scale factor

                                    % Divide by scale factor
                                        matrix(:,:,i) = matrix(:,:,i)./scale_factor;  %Divide by scale factor.     

                                    % Slope + Intercept   
                                        headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0028', '1053',mode, valueString);
                                        headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0028', '1052',mode, '0');
                                 catch
                                        disp('Scale factor probably missing');
                                 end


                                % Pixel representation (Make it signed) 
                                try
                                    headers{i}=dirtyDICOMModifyHeaderUS(headers{i}, '0028', '0103',mode, 1); % Make signed (0=unsigned)
                                catch
                                end

                                % Pixels (Value representation US)
                                    headers{i}=dirtyDICOMModifyHeaderUS(headers{i}, '0028', '0010',mode, rows); % rows
                                    headers{i}=dirtyDICOMModifyHeaderUS(headers{i}, '0028', '0011',mode, cols); % columns

                                    % Set value length for image (7FE0,0010)
                                    goalValueLength=2*rows*cols;
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '7FE0', '0010',mode, num2str(goalValueLength)); % New valuelength for image

                                    % Set pixel size
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0028', '0030',mode, [ num2str(handles.image.pixelSizeX) '\' num2str(handles.image.pixelSizeY)]);


                                % Unit
                                    try
                                        headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0054', '1001',mode, handles.image.unit);  % Unit
                                        headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0028', '1054',mode, handles.image.unit);  % Rescale type (unit after rescale slope/intercept is applied)
                                    catch end

                                % UIDs
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0020', '000E',mode, seriesInstanceUID);  % Series Instance UID

                                    SOPInstanceUID=generateUID();
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0008', '0018',mode, SOPInstanceUID);      % SOP Instance UID
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0002', '0003',mode, SOPInstanceUID);      % Media Storage UID

                                 % Patient 
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0010', '0010',mode,patientName); 
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0010', '0020',mode,patientID); 

                                 % Series 
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0008', '103E',mode,seriesDesc);              % Study number
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0020', '0011',mode, seriesNo);

                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0008', '0050',mode, accessionNumberString);

                                 % File names
                                    %newFileNames{i}=SOPInstanceUID;
                                    newFileNames{i}=num2str(i);



                                 % TO DO - 
                                 % number of images
                                 % instance number
                                 % image position

                                 % Make static
                                 if size(handles.image.Cdata,4)==1
                                 %if size(matrix,4)==1
                                    headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '0054', '1000',mode, 'STATIC\IMAGE');  % Series Type
                                    headers{i}=dirtyDICOMModifyHeaderUS(headers{i}, '0054', '0101',mode, 1);  % Number of Time Slices
                                 end

                                 %
                             end
                            close(waitBarHandle);
                            
                            
                        % If multiple images in one dicom file, reshape
                            if size( unique(fileNames),2 )==1   % Multiple images in the same file is characterized by having the same file name for each slice
                              
%                               % If Detectors column was opene into slice
%                               % column, then exchange back
%                               
%                                  % NM (0054,0021) US #2 [2] Number of Detectors
%                                  try 
%                                      numberOfDetectorsInScan=dirtyDICOMHeaderData(handles.image.dirtyDICOMHeader, 1,'0054', '0021',mode); 
%                                      numberOfDetectors=numberOfDetectorsInScan.bytes(1)+256*numberOfDetectorsInScan.bytes(2);
%                                  catch
%                                      numberOfDetectors=1; 
%                                  end   
%                                  if (numberOfDetectors == numberOfSlices) % Assume detectors in 3d column
%                                     matrix = reshape( matrix, rows, cols, [], numberOfFrames); 
%                                     matrix = permute( matrix, [1 2 5 4 3]);  % swap back to what is whas in original Dicom file
%                                  end

                                % Assume same order as displayed
                                % Allow only changing number of slices
                                
                                % Change Slices vector if exist
                                numberOfSlices = size(matrix,3);
                                try
                                    out0=dirtyDICOMHeaderData(headers, 1, '0054', '0080',mode,2); % Slice vector
                                    newString = out0.string( 1 : 2*numberOfSlices);
                                    headers{1} = dirtyDICOMModifyHeaderString( headers{1}, '0054', '0080',mode, newString, 2); % Occurs first in '00280009' Frame increment pointer

                                    headers{1} = dirtyDICOMModifyHeaderUS(headers{1}, '0054', '0081',mode, numberOfSlices)
                                catch
                                    disp('Error modifying slice vector');
                                end
                                
                                
                                 
                                 matrix=matrix(:);

                               %tempFileName=fileNames(1);
                               tempFileName=newFileNames(1);
                               fileNames=0;
                               fileNames=tempFileName;

                               tempHeader=headers(1);
                               headers=0;
                               headers=tempHeader;

                               iNumberOfSelectedFiles=1;

                               % Set value length for image (7FE0,0010)
                               i=1;
                               headers{i}=dirtyDICOMModifyHeaderString(headers{i}, '7FE0', '0010',mode, num2str(length(matrix)*2 )); % New valuelength for image
                            end


                        % Write to DICOM
                            % This function reuses file names (good for traceability)

                            %Dirty_Write_DICOM(matrix, headers(1:iNumberOfSelectedFiles), fileNames(1:iNumberOfSelectedFiles), ByteOrder);
                            Dirty_Write_DICOM(matrix, headers(1:iNumberOfSelectedFiles), newFileNames(1:iNumberOfSelectedFiles), ByteOrder);

                        % Clean up
                            cd('..');   % Move out of DICOM directory