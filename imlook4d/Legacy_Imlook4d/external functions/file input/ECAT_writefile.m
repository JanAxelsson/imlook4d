function ECAT_writefile(  filename, header, frame_data, unit);
% ECAT_writefile
%
% Routine for writing static ECAT PET-data files
%
% Inputs:
%   filename-   path to output file
%   header -    struct from ECAT_readfile (original file header)
%   frame_data -static PET-data: 3-dimensional matrix [X x Y x M] with image 
%				                    size X x Y with M slices.  
%   unit-       A string containing the unit for inclusion in the file header.
%
% Output:
%   none
%				                    
% Uses:
%   mx_WritePETData and routines in file input/ECAT library
%
% Author:   
%   Jan Axelsson, Uppsala Imanet, 040224 
%       
%   

mx_WritePETData(filename, header, frame_data, unit);

