%%**********   "ANNOTATIONS"   *********
%
%NAME:
%ReadECAT
%
%PURPOSE:
% THIS FUNCTION OPENS AN ECAT FILE AND READS THE MATRIX AND THE HEADER.
% THE FUNCTION READS ANY TYPE OF STATIC OR DYNAMIC ECAT FILES (BOTH SINGORAMS AND IMAGES) AND PERFORMS MANIPULATION
% IF NEEDED.
%
%INPUT:
% - inputfile           - ORIGINAL INPUT ECAT FILE
% - manipulatorFunction - HANDLE TO MANIPULATOR FUNCTION HERE "dummyGeneral"
% - varargin            - ADDITIONAL ARGUMENTS PASSED DIRECTLY TO
% MANIPULATOR FUNCTION
%
%OUTPUT:
% - mainHeader:         - MAIN HEADER.
% - subHeader:          - SUB HEADER.
% - new_matrix:         - A 4 DIMENSION, EITHER MANIPULATED OR NON-MANIPULATED MATRIX OF SIZE OF INPUT MATRIX
%                         [XYZR], WHERE X IS THE NUMBER OF ROWS, Y THE NUMBER OF COLUMNS,Z THE
%                         NUMBER OF IMAGES PER FRAME AND R IS THE NUMBER OF FRAMES
%
%FUNCTION CALL:
% - ECAT_readHeaderInt2
% - ECAT_readHeaderReal
%
%DATE OF CREATION:
%20060223
%%
%LATEST DATE OF MODIFICATION:
%20060404
%
%AUTHORS:
%JAN AXELSSON, PASHA RAZIFAR & ANNA RINGHEIM, UPPSALA IMANET
%
%EXAMPLE:
%[new_matrix, mainHeader, subHeader, dirstruct]=ReadECAT('test.v', @DummyGeneral);
%
%**********   " END OF ANNOTATIONS"   *********

function [new_matrix2, mainHeader, subHeader, dirstruct]=ReadECAT(inputfile,manipulatorFunction, varargin);

% start timer
    %tic;

    %Constant of blocks with size of 512 bytes
    BLOCKSIZE=512;

%Clear variables
    clear matrix new_matrix ECAT_manipulateMatrixFileIndex
    
%Global variables
    global matrix                                % current frame
    global new_matrix                            % all frames
    global ECAT_manipulateMatrixFileIndex        % index for current frame

%  Variables

    % BigEndian input file for reading
    inFile = fopen(inputfile, 'r','b');

    % BigEndian output file for writing
    %outFile = fopen(outputfile,'w','b');

    % The file extension S, a, v ...
    fileExtension=inputfile( length(inputfile));

    % Directory, first directory starts in block 2
    nextDirBlock=2;

    % Total traversed blocks
    blockCount=0;

    % Index to read last record of matrix, first matrix read in index 7
    recordIndexInDirectory=7;

    % SubHeader, global variable, we clear it here to stop error when size change
    clear subHeader;


%  Define information for specific file type
    % Guess format (S and v files)
    wordSize=2;
    wordFormat='int16';

    % Correct format (a and N files)
    if (inputfile(length(inputfile))=='a')
        wordSize=4;
        wordFormat='float32';
    end
    if (inputfile(length(inputfile))=='N')
        wordSize=4;
        wordFormat='float32';
    end


% Read initial information from directory
    % Forward past mainHeader
    blocks=1;
    blockCount=blockCount+blocks;
    words=BLOCKSIZE*(nextDirBlock-1);
    [mainHeader,count1] = fread(inFile,words,'uint8');
    %fwrite(outFile,mainHeader,'uint8');

    % Copy first directory
    blocks=1;
    blockCount=blockCount+blocks;
    words=blocks*BLOCKSIZE/4;
    [directory,count1] = fread(inFile,words,'int');
    dirstruct = directory;
    %fwrite(outFile,directory,'int');

    %Guess
    subHeaderSize=1;
    lastRecordOfMatrix=directory(recordIndexInDirectory);
    if mod(lastRecordOfMatrix,2)==0    % Correct subHeaderSize if last record is even
        subHeaderSize=2;
    end

% Loop - Read subheader and matrix

    ECAT_manipulateMatrixFileIndex=1;

    % Number of frames from main header (modification 050128)
    numberOfFrames=ECAT_readHeaderInt2(mainHeader,354);
    numberOfGates=ECAT_readHeaderInt2(mainHeader,356);         


    % For backwards compatibility with Matlab 6.5
    numberOfFrames=double(numberOfFrames);
    numberOfBeds=double(ECAT_readHeaderInt2(mainHeader,358));

    numberOfLoops=double(numberOfGates*numberOfFrames);
    
% --------------
% Single -bed    
% --------------    
    if numberOfBeds==0

        for i=1:numberOfLoops                                 
            % Check if new directory structure present.
            if (i==31*1+1)|(i==31*2+1)|(i==31*3+1)
                blocks=1;
                blockCount=blockCount+blocks;
                words=blocks*BLOCKSIZE/4;
                [directory,count1] = fread(inFile,words,'int');
                dirstruct(:, size(dirstruct,2)+1 ) = directory;
                recordIndexInDirectory=7;
            end


            % Get position of matrix from directory
            lastRecordOfMatrix=directory(recordIndexInDirectory);

            % Copy  subheader
            blocks=subHeaderSize;
            blockCount=blockCount+blocks;
            words=blocks*BLOCKSIZE/1;
            try
                [subHeader(:,i),count1] = fread(inFile,words,'uint8');
            catch
                disp(['Problem with i=' num2str(i)]);
            end
            %fwrite(outFile,subHeader(:,i),'uint8');

            % Read matrix
            blocks=lastRecordOfMatrix-blockCount;
            blockCount=blockCount+blocks;
            words=blocks*BLOCKSIZE/wordSize;
            try
                [matrix,count1] = fread(inFile, words, wordFormat);
            catch
                disp(['Problem with i=' num2str(i)]);
                matrix=zeros(size(matrix));
            end
            matrix=single(matrix);

            % update count only if more than one frame in matrix (will be 1 in all other cases)
            if (size(new_matrix,2)~=1)
                ECAT_manipulateMatrixFileIndex=i;
            end

            % Declare new_matrix size, and catch memory errors
            % create matrix based on size of first matrix
            if(i==1)
                   new_matrix=single(zeros( size(matrix,1), numberOfLoops ));      % REPLACED 070514 /JAN
            end;

            % Manipulate matrix  (using manipulatorFunction, which is the input argument to this function)
            % Manipulation takes place here in manipulatorFunction
            %feval(manipulatorFunction,varargin{:});% JAN 100416
            
            new_matrix(:,ECAT_manipulateMatrixFileIndex)=matrix;% JAN 100416


            % set up for next turn in loop
            recordIndexInDirectory=recordIndexInDirectory+4;

        end
% --------------
% Multiple-bed  
% --------------
    else
        for i=1:numberOfBeds+1

            % Check if new directory structure present.
            if (i==32)
                blocks=1;
                blockCount=blockCount+blocks;
                words=blocks*BLOCKSIZE/4;            
                [directory,count1] = fread(inFile,words,'int');
                dirstruct(:,2) = directory;
                %fwrite(outFile,directory,'int');
                recordIndexInDirectory=7;
            end


            % Get position of matrix from directory
            lastRecordOfMatrix=directory(recordIndexInDirectory);

            % Copy  subheader
            blocks=subHeaderSize;
            blockCount=blockCount+blocks;
            words=blocks*BLOCKSIZE/1;
            [subHeader(:,i),count1] = fread(inFile,words,'uint8');
            %fwrite(outFile,subHeader(:,i),'uint8');

            % Read matrix
            blocks=lastRecordOfMatrix-blockCount;
            blockCount=blockCount+blocks;
            words=blocks*BLOCKSIZE/wordSize;
            [matrix,count1] = fread(inFile, words, wordFormat);

            % update count only if more than one frame in matrix (will be 1 in all other cases)
            if (size(new_matrix,2)~=1)
                ECAT_manipulateMatrixFileIndex=i;
            end

            % Declare new_matrix size, and catch memory errors
            % create matrix based on size of first matrix
            if(i==1)
                try
                    new_matrix=zeros( size(matrix,1), numberOfBeds+1 );
                catch
                    new_matrix=zeros( size(matrix,1), 1 );
                    warning('- only last matrix will be output ');
                end
            end;

            % Manipulate matrix  (using manipulatorFunction, which is the input argument to this function)
            % Manipulation takes place here in manipulatorFunction
            %feval(manipulatorFunction,varargin{:});  % JAN 100416
            
            new_matrix(:,ECAT_manipulateMatrixFileIndex)=matrix;% JAN 100416

            % set up for next turn in loop
            recordIndexInDirectory=recordIndexInDirectory+4;

        end
    end
    clear matrix;

    %Store as single to save memory.
    new_matrix = single(new_matrix);

    %ECAT calibration factor from main header.
    ECATCalibFact = ECAT_readHeaderReal(mainHeader, 144);

    %Multiply data with ECAT calibration factor to convert from ECAT counts to Bq/cc.

    if ECATCalibFact==0  % Set ECATCalib factor to one if zero (Turku and MedCon makes this mistake)  /JAN
        ECATCalibFact=1;
        disp('Warning:  Corrected ECAT Calibration Factor from 0 to 1');
    end
    disp(['ECAT Calibration Factor (from main header)=' num2str(ECATCalibFact)]);
    disp([' Maximum non-scaled pixel value=' num2str(max(new_matrix(:)) )]);
    new_matrix = new_matrix .* single(ECATCalibFact);

% Scale factor

     if ~isempty(strfind(fileExtension, 'v')) & isempty(strfind(inputfile, 'tx'))  %ECAT image file, not transmission file. Change later to something better!!
         for i=1:numberOfLoops
            try
                ECATScaleFact = ECAT_readHeaderReal(subHeader(:,i), 26);
            catch
                disp(['Problem with i=' num2str(i)]);
            end

             if ECATScaleFact==0
                disp(['ReadECAT WARNING: ECAT scale factor=' num2str(ECATScaleFact) '(frame=' num2str(i) ')']);
             end

             %Multiply data with scale factor.
             try
                new_matrix(:,i) = new_matrix(:,i) * single(ECATScaleFact);
             catch
                disp(['Problem with i=' num2str(i)]);
            end

         end
     else
         disp('ReadECAT WARNING: suspected not emission file (file ending should be .v)');
     end

     disp([' Maximum pixel value=' num2str(max(new_matrix(:))) ]);

% Finish     
     
    %Get the size of matrix
    % siz=size(matrix);
    xsize = double( ECAT_readHeaderInt2(subHeader(:,1), 4) );
    ysize = double( ECAT_readHeaderInt2(subHeader(:,1), 6) );
    zsize = double( ECAT_readHeaderInt2(subHeader(:,1), 8) );

    % Take off values that are outside matrix (for matrices not fitting in even block sizes) 
    for i=1:numberOfLoops
        temp_matrix(:,i)=new_matrix(1:xsize*ysize*zsize, i);
    end
    
    % Reshape the new matrix to 4D matrix
    new_matrix2=reshape( temp_matrix ,[xsize,ysize,zsize,numberOfLoops]);


    % Clean up
    fclose(inFile);
