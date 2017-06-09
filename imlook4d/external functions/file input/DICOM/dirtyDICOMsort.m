 function [outputMatrix, DICOMStruct]=dirtyDICOMsort( matrix, DICOMStruct)
        %
        % input:    matrix                                          4D matrix
        %
        %           a struct containing a minimum of the following fields
        %           DICOMStruct.dirtyDICOMHeader
        %           DICOMStruct.dirtyDICOMFileNames 
        %           DICOMStruct.dirtyDICOMMode                      explicit=2 implicit=0
        %           DICOMStruct.dirtyDICOMIndecesToScaleFactor
        %
        %           
        %
        % output:   outputMatrix                                     4D matrix  
        %
        %           a struct which is unchanged EXCEPT for the fields
        %           listed as minimum input arguments
        
        % Sorting, how it works
        % ---------------------
        % The sorting should give 
        %   (p1,t1), (p2,t1), ... (pN,t1)
        %   (p1,t2), ..
        %   ...
        %   (p1,tN), ..           (pN,tM)
        % where p represents position and t time
        % This means that in practice we have have a list of images
        %   (p1,t1)
        %   (p2,t1)
        %   ...
        %   (pN,t1)
        %   (p1,t2)
        %   ....
        %
        % Thus, the first key to sort on is time, and the secondary key is
        % position.
        %
        % Sorting
        % --------------
        % Sorting is basically in the order of 
        % 1) Series    [6 Series instance UID]
        % 2) Time      [5 Acq Date] [4 Acq time] [7 Trigger Time]  [1 Frame ref time] 
        % 3) Slice     [3 Slice location]
        % 4) A number  [8 Instance number]  


        %
        % Initialize
        %
                waitBarHandle = waitbar(0,'Sorting DICOM files');	% Initiate waitbar with text
        
                % Default sorted data to original order
                sortedData=matrix;                       
                sortedHeaders=DICOMStruct.dirtyDICOMHeader;
                sortedFileNames=DICOMStruct.dirtyDICOMFileNames; 
                %sortedIndecesToScaleFactor=DICOMStruct.dirtyDICOMIndecesToScaleFactor; 
                mode=DICOMStruct.dirtyDICOMMode;
                
                last=size(sortedHeaders,2);  % Used when iterating files
                numberOfImages=last;

          %
          % Build list on how to sort
          %                      
             % Build index with columns (see comment block below)
                
                for i=1:last
                  if (mod(i, 100)==0) waitbar(i/last); end
                  
                  
                  % Frame Ref. Time
                  try
                    out=dirtyDICOMHeaderData(sortedHeaders, i, '0054', '1300',mode);  % Frame ref time 
                  catch
                    out.string='0';
                  end
                  indexlist(i,1)=str2num(out.string); 

                  
                  % Acq. time
                  try
                    out=dirtyDICOMHeaderData(sortedHeaders, i, '0008', '0032',mode);  % Acq time
                    indexlist(i,4)=str2num(out.string);
                  catch
                    out.string='0';   
                    indexlist(i,4)=str2num(out.string);
                  end
                   

                  
                  % Acq. date
                  try
                    out=dirtyDICOMHeaderData(sortedHeaders, i, '0008', '0022',mode);  % Acq date
                  catch
                    out.string='0';    
                  end
                  %indexlist(i,5)=str2num(out.string);
                  indexlist(i,5)=str2num( strrep(out.string,'.','') ); % Remove '.' from string
                  
                  %Image index   
                    indexlist(i,2)=i;                    % Index to Nth image in original order
                    
                    
                  % Position
                  %try
                  %  out=dirtyDICOMHeaderData(sortedHeaders, i, '0020', '1041',mode);  % Position
                  %  indexlist(i,3)=str2num(out.string);
                 % catch
                      try
                        out=dirtyDICOMHeaderData(sortedHeaders, i, '0020', '0032',mode);  % Position
                        str=out.string;
                        temp=strfind(str,'\'); 
                        indexlist(i,3)=str2num( str(temp(2)+1:end));  %
                        
                      catch
                        indexlist(i,3)=0;   
                      end
                   %end
                  

                  % Series instance UID                  
                  try
                      out=dirtyDICOMHeaderData(sortedHeaders, i, '0020', '000E',mode);  %Series Instance UID
                      %out=dirtyDICOMHeaderData(sortedHeaders, i, '0008', '0018',mode);  %SOP Instance UID
                      
                      % Store a numerical value with enought precision
                      temp=strrep(out.string,'.','');
                      temp2=str2num(temp(end-14:end));  
                      
                      indexlist(i,6)=temp2;
                  catch
                      disp('imlook4d/dirtyDICOMsort:  Reading Series Instance UID failed');
                      indexlist(i,6)=0;  
                  end             
                  
                  
                  % Trigger time 
                  try
                      out=dirtyDICOMHeaderData(sortedHeaders, i, '0018', '1060',mode); % Trigger time 
                      indexlist(i,7)=str2num(out.string);
                  catch
                      out.string='0'; 
                      indexlist(i,7)=str2num(out.string);
                  end
      
                  
                  % Instance number
                  try
                      out=dirtyDICOMHeaderData(sortedHeaders, i, '0020', '0013',mode); % Instance number
                  catch
                      out.string='0';    
                  end
                  
                  % If zero length instance number - make one up
                  if length(out.string)==0
                      indexlist(i,8)=i;
                  else
                    indexlist(i,8)=str2num(out.string);    
                  end
                end
                
            %
            % Calculate number of slices and number of frames
            %
            % Get number of patient positions (column 3) that equals first patient position
            % => number of frames /gates/ phases
                numberOfFrames=sum( indexlist(:,3)==indexlist(1,3)); % Number of frames

                % Get number of slices from total number of images, and number
                % of frames
                numberOfSlices=size(indexlist,1) / numberOfFrames;

          %         
          % Perform sorting of indexList   
          %
                % Sorting is basically in the order of 
                % 1) Series    [6 Series instance UID]
                % 2) Time      [5 Acq Date]  [7 Trigger Time]  
                % 3) Slice     [3 Slice location]
                % 4) Time2     [1 Frame ref time] [4 Acq time]
                % 5) A number  [8 Instance number]     (this is fallback if no other sorting works)
                %
                % where the following information is in columns in the indexList:
                % col1:  (Time2)  frame reference time(0054,1300) (relative start of acquistion)
                % col2:  ( )      original image index
                % col3:  (Slice)  slice location (0020,1041)
                % col4:  (Time2)   acquisition time (0008,0032) (clock time; fixed for each bed)
                % col5:  (Time)   acquisition date (0008, 0022)
                % col6:  (Series) series instance uid (0020,000E)
                % col7:  (Time)   trigger Time (0018,1060)
                % col8:  (Number) instance number (0020,0013)
                %
                % Some of the tags are not present in some types of scans,
                % so the idea is to cover the information needed, by adding
                % all possible tags for 1), 2), 3), and fallback on 4).
                
                disp('sorting ');
                
     
            
                % Sort everything except slice location
%                 sortedIndexList_tmp=sortrows(indexlist,...
%                     [6 ...
%                     5 7 ...
%                     1 4 ...
%                     8] ...
%                     );  
                sortedIndexList_tmp=sortrows(indexlist,...
                    [  ...
                    5 7 ...
                    4 1 ...
                    6 ...
                    8] ...
                    );  
                
                % Second pass: sort slice location
                range=1:numberOfSlices;
                for i=1:numberOfFrames
                    sortedIndexList( range ,:) =sortrows(sortedIndexList_tmp( range ,:),[3] );  
                    range=range+numberOfSlices;
                end
                
                %
                % Special case - multidimensional CT (triggered)
                %
                    % This case is regognized by having several of the same  positions after each other.
                    try
                        if sortedIndexList(1,3)==sortedIndexList(2,3)
                          % Fall back on Instance Number
                            sortedIndexList=sortrows(indexlist,8);  
                        end
                    catch
                    end
                

          %
          % Sort all stored data
          %       
                disp('sorting data');
                % Sort according to index list
                for i=1:last            
                    if (mod(i, 100)==0) waitbar(i/last); end
                    imageNumber=sortedIndexList(i,2);           % original image number for time-sorted images
                    sortedData(:,:,i)=matrix(:,:,imageNumber);  % place 
                    sortedHeaders{i}=DICOMStruct.dirtyDICOMHeader{imageNumber};
                    sortedFileNames{i}=DICOMStruct.dirtyDICOMFileNames{imageNumber};
                    sortedIndecesToScaleFactor{i}=DICOMStruct.dirtyDICOMIndecesToScaleFactor{imageNumber};

                    temp=sortedFileNames{i};
                    %disp( [ 'fileName=' temp(end-20:end) 'new=' num2str(i) '  time=' num2str(indexlist(i,1)) ' original image nr='  num2str(indexlist(i,2)) '   position='   num2str(indexlist(i,3) )]);
                end 
                

                

        %
        % Create output variables
        %                         
                outputMatrix=sortedData;
                
                DICOMStruct.dirtyDICOMSlicesString=num2str(numberOfSlices);
                DICOMStruct.dirtyDICOMHeader=sortedHeaders;
                DICOMStruct.dirtyDICOMFileNames=sortedFileNames;
                DICOMStruct.dirtyDICOMIndecesToScaleFactor=sortedIndecesToScaleFactor;
                DICOMStruct.dirtyDICOMMode=mode;   % Explicit or implicit 2 or 0

                % HERE the acq time, frame ref time, and position could be
                % included in DICOMStruct
                %
                % This would possibly save time for other routines that
                % also reads this information from header
                DICOMStruct.sliceLocations=sortedIndexList(:,3);
                  
                DICOMStruct.dirtyDICOMsortedIndexList=sortedIndexList;
        %
        % Finalize
        %
            close(waitBarHandle);
