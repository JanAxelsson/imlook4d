function endbyte= ECAT_endbyte(  frame,  slices,  pixelx,  pixely);
% ECAT_endbyte
%
% Routine for calculating end byte of matrix for ECAT image/scn files
%
% function endbyte= ECAT_endbyte( int frame, int slices, int pixelx, int pixely);
%
% Inputs:
%   frame -    frame number
%   slices -   number of slices in file
%   pixelx -   number of pixels in first dimension
%   pixely -   number of pixels in second dimension
%
% Output:
%   byte position for last byte in last image in frame
%
% Uses:
%   none
%
% Author:   
%   Jan Axelsson, Uppsala Imanet, 031208

blocksize=512;  % bytes
datasize=2;     % bytes per data point

endbyte=blocksize*(2+frame)+datasize*pixelx*pixely*frame*slices;