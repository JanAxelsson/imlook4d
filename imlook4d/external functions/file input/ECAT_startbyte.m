function startbyte= ECAT_startbyte(  frame,  slices,  pixelx,  pixely);
% ECAT_startbyte
%
% Routine for calculating start byte of matrix for ECAT image/scn files
%
% function startbyte= ECAT_startbyte( int frame, int slices, int pixelx, int pixely);
%
% Inputs:
%   frame -    frame number
%   slices -   number of slices in file
%   pixelx -   number of pixels in first dimension
%   pixely -   number of pixels in second dimension
%
% Output:
%   byte position for first byte in first image in frame
%
% Uses:
%   none
%
% Author:   
%   Jan Axelsson, Uppsala Imanet, 031208

blocksize=512;  % bytes
datasize=2;     % bytes per data point

startbyte=blocksize*(2+frame)+datasize*pixelx*pixely*(frame-1)*slices+1;