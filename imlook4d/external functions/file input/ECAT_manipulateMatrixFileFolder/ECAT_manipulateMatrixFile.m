function [ mainHeader, subHeader, new_matrix]= ECAT_manipulateMatrixFile(inputfile, outputfile, manipulatorFunction, varargin);
%
% Traverses dynamic ECAT matrix file (sinogram or image) and performs
% manipulation on each matrix as defined in manipulatorFunction with
% arguments args.  A new output file is created.  Works for studies up to
% 31 frames.  If out of memory error, only last frame is returned in
% new_matrix.
% 
% function  [ mainHeader, subHeader, new_matrix] newMatrix= ECAT_manipulateMatrixFile(inputfile, outputfile, manipulatorFunction, args);
%
% Example 1, referencing a manipulator-function defined as "function test(a, b)" :
%    [ mainHeader, subHeader, new_matrix]=ECAT_manipulateMatrixFile(  'E:\PET-centrum\Typical PET data\Siemens HR+\NEMA attenuation correction\AAPostRelocation_1010_64f4_tx2.S', 'E:\data\test.S', @test, 0, 20);
%
% Example 2, referencing a manipulator-function defined as "function randpois4()" :
%    [ mainHeader, subHeader, new_matrix]=ECAT_manipulateMatrixFile(  'E:\PET-centrum\Typical PET data\Siemens HR+\NEMA attenuation correction\AAPostRelocation_1010_64f4_tx2.S', 'E:\data\test.S', @randpois4);
%
% Example 3, referencing dummy function that only returns matrix , "function dummy()" :
%    [ mainHeader, subHeader, new_matrix]=ECAT_manipulateMatrixFile(
%    'E:\PET-centrum\Typical PET data\Siemens HR+\Hennerud - PIB med bloddata\Hennerud_1e8e_ac43_3.v', 'E:\data\test.v', @dummy);
% 
% Inputs:
%   
%   inputfile           - original file
%   outputfile          - output file with Poisson distributed noise
%   manipulatorFunction - handle to manipulator function
%                          This function is defined by the user and must follow the format:
%                          function f(arg1, arg2, ..., argN);
%                          with global variables JANA_ECAT_matrix,  JANA_ECAT_new_matrix
%   varargin            - additional arguments passed directly to manipulatorFunction
%
% Output:
%   newMatrix           - the last matrix element in file
%
% GLOBAL VARIABLES  (This is the only way to stop "memory leak", that
%                    memory is not garbage collected and defragmented fast
%                    enough in MATLAB)      
%                    These variables can be accessed and changed in manipulatorFunction
%
%     global matrix
%     global new_matrix
%     global mainHeader
%     global subHeader
%     global ECAT_manipulateMatrixFileIndex
% 
%
% Uses:
%   none
%
% Author:   
%   Jan Axelsson, Uppsala Imanet, 040923
%
% 

%
%  Constants
%
	BLOCKSIZE=512;                                  % We use blocks of 512 bytes

%
%   Global variables
%
    global matrix                                               % current frame
    global new_matrix                                       % all frames
    global mainHeader                                       % main header for both input and manipulated output file
    global subHeader                                       % sub header for both input and manipulated output file
    global ECAT_manipulateMatrixFileIndex        % index for current frame
   
%
%  Variables
%
	inFile = fopen(inputfile, 'r','b');             % BigEndian input file for reading
	outFile = fopen(outputfile,'w','b');            % BigEndian output file for writing
	fileExtension=inputfile( length(inputfile));    % The file extension S, a, v ...
	nextDirBlock=2;                                 % Directory, first directory starts in block 2
	blockCount=0;                                   % Total traversed blocks
    recordIndexInDirectory=7;                       % Index to read last record of matrix, first matrix read in index 7
    clear subHeader;                                % SubHeader, global variable, we clear it here to stop error when size change
%
%   Initialize
%
    tic;    % start timer
    
%
%  Define information for specific file type
%
   
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

%
% Read initial information from directory
%
	
	% Forward past mainHeader
	blocks=1;  
    blockCount=blockCount+blocks;
	words=BLOCKSIZE*(nextDirBlock-1);
	[mainHeader,count1] = fread(inFile,words,'uint8');  fwrite(outFile,mainHeader,'uint8');
	
	% Copy first directory 
	blocks=1;  
    blockCount=blockCount+blocks;
	words=blocks*BLOCKSIZE/4;
	[directory,count1] = fread(inFile,words,'int');  fwrite(outFile,directory,'int');
	
	% Extract directory information from first directory
	%numberOfFrames=directory(4); 
   % disp( ['-Number of frames= ' num2str(numberOfFrames)]);
	
	subHeaderSize=1; %Guess  
    lastRecordOfMatrix=directory(recordIndexInDirectory);
	if mod(lastRecordOfMatrix,2)==0    % Correct subHeaderSize if last record is even
        subHeaderSize=2; 
	end
    %disp([ '-Subheader size '  num2str(subHeaderSize), ' blocks (1 block=512 bytes)']);    
%
% Loop - Read subheader and matrix
%

    ECAT_manipulateMatrixFileIndex=1;

    % Number of frames from main header (modification 050128)
    numberOfFrames=ECAT_readHeaderInt2(mainHeader,354);
    numberOfFrames=double(numberOfFrames);  % For backwards compatibility with Matlab 6.5

    for i=1:numberOfFrames
           %numberOfFrames

            % Check if new directory structure present.
            if (i==32)
                blocks=1;  
                blockCount=blockCount+blocks;
                words=blocks*BLOCKSIZE/4;
                [directory,count1] = fread(inFile,words,'int');  fwrite(outFile,directory,'int');   
                recordIndexInDirectory=7;
            end    


            % Get position of matrix from directory	
            lastRecordOfMatrix=directory(recordIndexInDirectory);

            % Copy  subheader 
            blocks=subHeaderSize;  
            blockCount=blockCount+blocks;
            words=blocks*BLOCKSIZE/1;
            [subHeader(:,i),count1] = fread(inFile,words,'uint8');  
            fwrite(outFile,subHeader(:,i),'uint8');

            % Read matrix
            blocks=lastRecordOfMatrix-blockCount; 
            blockCount=blockCount+blocks;
            words=blocks*BLOCKSIZE/wordSize;
            [matrix,count1] = fread(inFile, words, wordFormat);   

            if (size(new_matrix,2)~=1)         % update count only if more than one frame in matrix (will be 1 in all other cases)
                ECAT_manipulateMatrixFileIndex=i;    
            end    

            % Declare new_matrix size, and catch memory errors     
            if(i==1)    % create matrix based on size of first matrix
                try        
                    new_matrix=zeros( size(matrix,1), numberOfFrames );
               catch
                    new_matrix=zeros( size(matrix,1), 1 );   
                    warning('- only last matrix will be output ');
                end   
            end;

        % Manipulate matrix  (using manipulatorFunction, which is the input argument to this function) 
        feval(manipulatorFunction,varargin{:}); % Manipulation takes place here in manipulatorFunction

        % Write matrix
        disp(['Frame='  num2str(i) '     matrixsize=' num2str(size(matrix,1)) ' words (' wordFormat ')     time=' num2str(toc) ' seconds     Number of blocks=' num2str(blockCount)  '     Number of bytes=' num2str(BLOCKSIZE*blockCount)]);
       try
          fwrite(outFile,new_matrix(:,i),wordFormat);
       catch
            warning('- One-matrix mode ');
            fwrite(outFile,new_matrix(:,1),wordFormat);
        end

        % set up for next turn in loop
        recordIndexInDirectory=recordIndexInDirectory+4;	

    end
 
    % Create output variable
    %new_matrix=reshape(matrix,[288 63 144]);

    % Clean up
    fclose(inFile);
    fclose(outFile);
  
%
% Display some file information
%
    % Define dimensions of matrix   
    % Common to image and sinogram
    dimx=ECAT_readHeaderInt2(subHeader, 4);dimy=ECAT_readHeaderInt2(subHeader, 6);

    % Sinogram
     if (ECAT_readHeaderInt2(mainHeader, 50) ==1 );
         dimz=ECAT_readHeaderInt2(subHeader, 10);
         disp ('File type=2D sinogram');
     end;
     if (ECAT_readHeaderInt2(mainHeader, 50) ==11);
         dimz=ECAT_readHeaderInt2(subHeader, 10);
         disp ('File type=3D sinogram');
         % exchange dimy och dimz 
         temp=dimz; dimz=dimy;dimy=temp;
     end;

    % Image
     if (ECAT_readHeaderInt2(mainHeader, 50) ==7);
         dimz=ECAT_readHeaderInt2(subHeader, 8);
         disp ('File type=Image Volume 16');
     end;

     disp( ['image dimensions:   x='  num2str(dimx) 'y='  num2str(dimy) 'z='  num2str(dimz)])
