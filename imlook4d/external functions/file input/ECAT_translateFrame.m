function ECAT_translateFrame(  filename1, outputFileName, frameToTranslate,  pixelsToTranslate, slices,  pixelx,  pixely);
%
% Translates a frame in positive direction a given number of pixels.
% 
% function ECAT_translateFrame(  filename1, outputFileName, frameToTranslate,  pixelsToTranslate, slices,  pixelx,  pixely);
%
% Example 1 (move 1 row down):
%   ECAT_translateFrame(  'E:\G_rot(0 0 30).v','E:\test.v', 2, 128, 74,  128,  128);
%
% Inputs:
%   
%   filename1       - input file 1
%   outputFileName  - output file name
%   frameToTranslate- frame to translate
%   pixelsToTranslate- number of pixels that the translation should move
%   slices          - number of slices in file
%   pixelx          - number of pixels in first dimension
%   pixely          - number of pixels in second dimension
%
% Output:
%   none
%
% Uses:
%   ECAT_startbyte
%
% Author:   
%   Jan Axelsson, Uppsala Imanet, 031209

% First frame
start=ECAT_startbyte(frameToTranslate,slices,pixelx,pixely)

% Input
fid1 = fopen(filename1);
% Output
fid3 = fopen(outputFileName,'w');

% Copy header and frames until frameToTranslate from file 1
[A1,count1] = fread(fid1,(start-1),'int8');
fwrite(fid3,A1,'int8');

% Translate images from file 1 
[A1,count1] = fread(fid1, pixelx*pixely*slices,'int16');  
A_translated=zeros(size(A1));   % Zero fill => pixels not moved will be zero
%sA_translated=A1;                 % Leave non-moved pixels untouched
A_translated( (pixelsToTranslate+1):(pixelx*pixely*slices),1 )=A1(1:(pixelx*pixely*slices - pixelsToTranslate) ,1);

fwrite(fid3,A_translated,'int16');

% Copy rest of file
[A1,count1] = fread(fid1,inf,'int8');
fwrite(fid3,A1,'int8');

% Tidy up
fclose(fid1);
fclose(fid3);



