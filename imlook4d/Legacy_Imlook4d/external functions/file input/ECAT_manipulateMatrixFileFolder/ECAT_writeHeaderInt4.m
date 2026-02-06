
function header=ECAT_writeHeaderInt4(header, byteN, value);
%
% Writes a int*4 number to the Nth byte (byteN) in ECAT header/subHeader.
%
% function ECAT_writeHeaderReal( subHeader, byteN);
%
% Inputs:
%   
%   header          - subHeader/mainHeader in uint8 matrix 512*1 or 1024*1
%   byteN           - byte N, counting from byte zero as in ECAT manual
%   value           - value to write into 4 bytes starting at byteN
%
% Uses:
%   single_as_uint8_to_double from "http://home.online.no/~pjacklam/matlab/software/util/index.html"
%
% Author:   
%   Jan Axelsson, Uppsala Imanet, 080514
%
% 



hex=uint32_to_hex(value); %4-byte hex from integer

byte=byteN;
length=4;
header(byte+1:byte+length)=hex_to_uint8([hex(1:2);hex(3:4);hex(5:6);hex(7:8)]);
