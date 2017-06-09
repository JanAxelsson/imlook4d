%%**********   "ANNOTATIONS"   *********
%
%NAME:
%DummyGeneral
%
%PURPOSE:
% THIS FUNCTION RETURNS INPUT MATRIX UNTOUCHED. INPUT MATRIX IS THE MATRIX CONTAINING DATA FROM A SINGLE FRAME.
%
%INPUT:
% - varargin            - ADDITIONAL ARGUMENTS PASSED DIRECTLY TO MANIPULATOR FUNCTION
%
%OUTPUT
%NONE
%
%COMMENTWS:
% GLOBAL VARIABLES  (This is the only way to stop "memory leak", that
%                    memory is not garbage collected and defragmented fast
%                    enough in MATLAB)      
%                    These variables can be accessed and changed in manipulatorFunction
%
%               - global matrix
%               - global new_matrix
%               - global mainHeader
%               - global subHeader
%               - global ECAT_manipulateMatrixFileIndex
%               - i
%FUNCTION CALL:
%NONE
%
%DATE OF CREATION:
%20040927
%%
%LATEST DATE OF MODIFICATION:
%20060403, PASHA RAZIFAR
% 
%AUTHORS:
%JAN AXELSSON, UPPSALA IMANET
%
%EXAMPLE:
%[new_matrix,numberOfFrames]=ECAT_manipulateMatrixFinal('test.S', 'new_test.s',63,'Name of the saved matrix',@DummyGeneral);
%
%**********   " END OF ANNOTATIONS"   *********
function DummyGeneralFinal(varargin)

    global matrix
    global new_matrix
%     global mainHeader
%     global subHeader
    global ECAT_manipulateMatrixFileIndex
%     global i

% Copy current frame matrix to correct position in new_matrix
new_matrix(:,ECAT_manipulateMatrixFileIndex)=matrix;
    




