REM sInstallation script for imlook4d
REM
REM Requires: Windows computer, and an installed version of MATLAB
REM 
REM This is equivalent to adding the imlook4d, including subfolders to the MATLAB path.
REM
matlab -r "directory='%CD%';addpath(genpath(directory)); savepath;path"
