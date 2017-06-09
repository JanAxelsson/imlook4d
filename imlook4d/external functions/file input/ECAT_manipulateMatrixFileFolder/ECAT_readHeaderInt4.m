
function value= ECAT_readHeaderInt4(subHeader, byteN);
%
% Reads the Nth byte (byteN) in ECAT header/subHeader and converts it to a
% int2 value.
%
% function double= ECAT_readHeaderInt4( subHeader, byteN);
%
% Example 1, read FRAME_DURATION from image file subheader (ECAT 7)
%   y= ECAT_readHeaderInt4(subHeader,46); 
%
% Inputs:
%   
%   subHeader       - subHeader in uint8 matrix 512*1 or 1024*1
%   byteN           - byte N, counting from byte zero as in ECAT manual
%
% Output:
%   value           - converted value
%
% Uses:
%   uint8_to_hex    from "http://home.online.no/~pjacklam/matlab/software/util/index.html"
%   hex_to_int32    from "http://home.online.no/~pjacklam/matlab/software/util/index.html"
%
% Author:   
%   Jan Axelsson, Uppsala Imanet, 040927
%
% 
matlabIndex=byteN+1;

hexValue=[uint8_to_hex(subHeader(matlabIndex)) uint8_to_hex(subHeader(matlabIndex+1)) uint8_to_hex(subHeader(matlabIndex+2)) uint8_to_hex(subHeader(matlabIndex+3))];
hex_to_int32(hexValue);
value=hex_to_int32(hexValue);
 