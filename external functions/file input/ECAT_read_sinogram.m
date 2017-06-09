function [test_sinogram]= ECAT_read_sinogram(  filename1, outputFileName, slices,  pixelx,  pixely);
%
% Reads an ECAT static sinogram
% 
% function [test_sinogram] ECAT_read_sinogram(  filename1, outputFileName, slices,  pixelx,  pixely);
%
% Example 1 (static sinogram):
%   slices=144;pixelx=288;pixely=63;A=ECAT_read_sinogram(  'AAPostRelocation_1010_64f6_se4.S', 'E:\data\test.S', slices,  pixelx,  pixely);
%
% Inputs:
%   
%   filename1       - input file 1
%   outputFileName  - output file name
%   slices          - number of slices in file                  144
%   pixelx          - number of pixels in first dimension       288
%   pixely          - number of pixels in second dimension       63
%
% Output:
%   sinogram
%
% Uses:
%   none
%
% Author:   
%   Jan Axelsson, Uppsala Imanet, 040921
%
% 

% First frame
start=2048+1;

% Input
fid1 = fopen(filename1, 'r','b');
% Output
fid3 = fopen(outputFileName,'w','b');

% Copy header and frames 
[A1,count1] = fread(fid1,(start-1),'int8');
fwrite(fid3,A1,'int8');

% Read sinogram images from file 1 
[A1,count1] = fread(fid1, pixelx*pixely*slices,'int16');  

% Write matrix to data file
% fwrite(fid3,A1,'int16');

% Copy rest of file
[A2,count1] = fread(fid1,inf,'int8');
% fwrite(fid3,A2,'int8');

% Tidy up
fclose(fid1);
fclose(fid3);

% Create output variable
tic;
test_sinogram=reshape(A1,[288 63 144]);
toc;

%----------------------------------------------------------------------------------

%
% DONE --------------------
%

%
% HERE FOLLOWS DIAGNOSTIC OUTPUT PLOTS
%

if (1==1) % START OF DIAGNOSTIC OUTPUT
    
% Test output sinogram to two views

	%test_sinogram=reshape(A1,[288 63 144]);
	figure;
    imagesc(test_sinogram(:,:,144)');           %last sinogram in ECAT 3D view
	
	%exchange dimensions 1 and 3, and rotate
	test_sinogram_shifted=shiftdim(test_sinogram,2);	
	for i=1:63
        test_sinogram_rotated(:,:,i)=rot90(test_sinogram_shifted(:,:,i));
	end 
    figure;
	imagesc(test_sinogram_rotated(:,:,30)');    % middle sinogram in typical 2D view


%
% Display montage of all slices 
%
	figure;
    %make 3-dimensional matrix from vector
    test_sinogram=reshape(A1,[288 63 144]);
    
	%exchange dimensions 1 and 3, and rotate
	test_sinogram_shifted=shiftdim(test_sinogram,2);	
	for i=1:63
        test_sinogram_rotated(:,:,i)=rot90(test_sinogram_shifted(:,:,i));
	end    
    
    % Graph-positioning parameters
	NCols=9;
	NRows=7;
	GI=1;	% Graph index, initial value
                
	for i=1:63  
            subplot(NRows,NCols,GI), imagesc(test_sinogram_rotated(:,:,30)');GI=GI+1; 
            set(gca,'XTick', []);set(gca,'YTick', [])
            set(colorbar('vert'),'fontsize',6);  
	end;

% 
% Display stack of all slices
% 
%imlook3d(frame_data);
end % END OF DIAGNOSTIC OUTPUT