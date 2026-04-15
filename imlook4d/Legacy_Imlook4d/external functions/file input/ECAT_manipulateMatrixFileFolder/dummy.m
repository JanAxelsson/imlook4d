function dummy(varargin)
% This function is a manipulator function to use in ECAT_manipulateMatrixFile
%
% Dummy function that returns untouched matrix.
% Useful for ECAT_manipulateMatrixFile, if only last matrix should be read.
% 
% Inputs:
%   
%   varargin         - arguments passed here by  ECAT_manipulateMatrixFile
%   global variables
%
% Outputs:
%
%   global variables
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
%   Jan Axelsson, Uppsala Imanet, 040927
    global matrix
    global new_matrix
    global mainHeader
    global subHeader
    global ECAT_manipulateMatrixFileIndex

% Copy current frame matrix to correct position in new_matrix
new_matrix(:,ECAT_manipulateMatrixFileIndex)=matrix;





