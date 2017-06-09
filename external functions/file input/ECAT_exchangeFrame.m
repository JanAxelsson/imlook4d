function ECAT_exchangeFrame(  filename1, filename2, outputFileName, frameToExchange,  slices,  pixelx,  pixely);
%
% Writes file 1 but exchanges a given frame with that from file 2
% 
% function ECAT_exchangeFrame(  filename1, filename2, outputFileName, frameToExchange,  slices,  pixelx,  pixely);
%
% Example:
%   CAT_exchangeFrame(  'E:\G_rot(0 0 30).v', 'E:\G4.v', 'E:\test.v', 2,  74,  128,  128);
%
% Inputs:
%   
%   filename1       - input file 1, which is essentially copied
%   filename2       - input file 2, from which frame (frameToExchange) is copied
%   outputFileName  - output file name
%   frameToExchange - frame to exchange
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
start=ECAT_startbyte(frameToExchange,slices,pixelx,pixely)

% Input
fid1 = fopen(filename1);
fid2 = fopen(filename2);
% Output
fid3 = fopen(outputFileName,'w');

% Copy header and frames up to frameToExchange from file 1
[A1,count1] = fread(fid1,(start-1),'int8');
fwrite(fid3,A1,'int8');
% Forward past header in file 2
[temp,count1] = fread(fid2,(start-1),'int8');

% Copy images from file 2 
[temp,count1] = fread(fid1, pixelx*pixely*slices,'int16');    
[A2,count1] = fread(fid2, pixelx*pixely*slices,'int16');
fwrite(fid3,A2,'int16');

% Copy rest of file
[A1,count1] = fread(fid1,inf,'int8');
[temp,count1] = fread(fid2,inf,'int8');
fwrite(fid3,A1,'int8');

% Tidy up
fclose(fid1);
fclose(fid2);
fclose(fid3);



