
function value= ECAT_readHeaderReal(subHeader, byteN);
%
% Reads the Nth byte (byteN) in ECAT header/subHeader and converts it to a
% real value.
%
% function double= ECAT_readHeaderReal( subHeader, byteN);
%
% Example 1, read X_OFFSET from image file subheader (ECAT 7)
%   y= ECAT_readHeaderReal(subHeader, 10); 
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
%   single_as_uint8_to_double from "http://home.online.no/~pjacklam/matlab/software/util/index.html"
%
% Author:   
%   Jan Axelsson, Uppsala Imanet, 040927
%
% 
matlabIndex=byteN+1;
value=single_as_uint8_to_double(subHeader(matlabIndex:matlabIndex+3)');