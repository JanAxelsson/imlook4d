function [outputheader, frame_data]= ECAT_readfile(  filename);
% ECAT_readfile
%
% Routine for reading static and dynamic ECAT PET-data files
%
% NOTE: requires SPM99 libraries in path BELOW "file input/ECAT library"
%
% Inputs:
%   filename-  path to file
%
% Output:
%   outputheader    -  ECAT file headers
%
%  'frame_data' -  static PET-data: 3-dimensional matrix [X x Y x M] with image 
%				                    size X x Y with M slices.  
%               -  dynamic PET-data: 4-dimensional matrix [X x Y x M * T] with image 
%				                    size X x Y with M slices and T frames.
%
%
% Example: 
%   [outputheader, frame_data]= ECAT_readfile(  filename);
%
% Uses:
%   * routines in file input/ECAT library (MUST BE ABOVE SPM99 LIBRARIES IN PATH)
%   * spm99 libraries
%s
% Author:   
%   (based on mx_GetPETData by Mats Jonsson)
%
%   Jan Axelsson, Uppsala Imanet, 040224 
%       
%   

% Fixed number of slices on ECAT
SLICES=63;


%Input parameters -----------------------------------------------------------------
iNumberOfExprm = 1;
%sPrompts = insPrompts;
%----------------------------------------------------------------------------------


%Constants ------------------------------------------------------------------------
global C;
%----------------------------------------------------------------------------------


%Variables ------------------------------------------------------------------------
sFilenames = [];  %Stores the selected filenames as a structure.
sTempFilename = '';  %Stores each filename temporarily.
sTempFieldname = '';  %Used for building the struct field names.
sTempPrompt = '';  %Used for building a prompt string.
sTempHeader = [];  %Gets the file headers for each experiment.
fTempVol = [];  %Gets the PET data for each experiment.
sCpet = [];  %Holds the image data for all of the experiments as a structure.
sHeaders = [];	%Holds the file headers for all of the experiments as a structure.
iNumberOfSelectedFiles = 0;  %Holds the number of files actually selected.
iWatiFig = 0;  %Handle to the Please wait-dialog.
%----------------------------------------------------------------------------------

%Let the user select the required number of files.
for i=1:iNumberOfExprm          % Loop is heritage from orignal file, loop only once
	%sTempPrompt = sPrompts{i};
	sTempFilename = filename;   % Use fixed name
	%Check if user cancelled.
	if (isempty(sTempFilename)) 
		outsCpet = [];
		outsHeaders = [];
		outsFilenames = [];
		return;   %Exit from function.
	end
	sTempFieldname = strcat('filename', num2str(i));
	sFilenames = setfield(sFilenames, sTempFieldname, sTempFilename);
end

iNumberOfSelectedFiles = length(fieldnames(sFilenames));

%Show Please wait-message.
iWaitFig = mx_Form_Wait;

%Read the files
try
	for i=1:iNumberOfSelectedFiles  % Loop only once
		sTempFieldname = strcat('filename',num2str(i));
		eval(strcat('sTempFilename = sFilenames.', sTempFieldname, ';'));
		sTempHeader = spm_vol(sTempFilename, 'all');
		fTempVol = spm_read_vols(sTempHeader);	

		%Spm seems to multiply the data from the file with the scale factor
		%in each subheader, but not with the ECAT calibration factor. Therefore
		%perform this multiplication here.
		fTempVol = fTempVol * sTempHeader(1).mh.ECAT_CALIBRATION_FACTOR;
        
        disp(['ECAT_CALIBRATION_FACTOR=' num2str(sTempHeader(1).mh.ECAT_CALIBRATION_FACTOR)]);
        disp(['CALIBRATION_UNITS=' num2str(sTempHeader(1).mh.CALIBRATION_UNITS)]);
        disp(['DATA_UNITS=' sTempHeader(1).mh.DATA_UNITS]);
        
		%Perform unit check and conversion.
		if (sTempHeader(1).mh.CALIBRATION_UNITS == 1)  %Calibrated data.
			if (~strcmpi(sTempHeader(1).mh.DATA_UNITS, 'Bq/cc'))
				set(iWaitFig, 'Visible', 'off');
				%mx_ErrorMsg('Unknown PET data unit.'); % Jan commented out 040224
                disp('WARNING Unknown PET data unit.'); % Jan changed 040224
				outsCpet = [];
				outsHeaders = [];
				outsFilenames = [];
				%return; % Jan commented out 040224
			end
		elseif (sTempHeader(1).mh.CALIBRATION_UNITS == 0)  %Uncalibrated data.
				%mx_ErrorMsg('Cannot load file with uncalibrated data.'); % Jan commented out 040224
                disp('WARNING Cannot load file with uncalibrated data.'); % Jan changed 040224
				outsCpet = [];
				outsHeaders = [];
				outsFilenames = [];
				%return; % Jan commented out 040224		
		else
			set(iWaitFig, 'Visible', 'off');
			%mx_ErrorMsg('Unknown PET data unit.'); % Jan commented out 040224
            disp('WARNING Unknown PET data unit.'); % Jan changed 040224
			outsCpet = [];
			outsHeaders = [];
			outsFilenames = [];
			%return; % Jan commented out 040224
		end

		sCpet = setfield(sCpet, strcat('exprm',num2str(i)),fTempVol);		
		sHeaders = setfield(sHeaders, strcat('exprm',num2str(i)),sTempHeader);

	end

    catch
	set(iWaitFig, 'Visible', 'off');
	mx_ErrorMsg('Error when reading files.');
    end

%Remove Please wait-message.
set(iWaitFig, 'Visible', 'off'); 

frame_data=getfield(sCpet, 'exprm1'); 
outputheader=getfield(sHeaders, 'exprm1'); 

%----------------------------------------------------------------------------------

%
% DONE --------------------
%

%
% HERE FOLLOWS DIAGNOSTIC OUTPUT PLOTS
%

disp(['max(fTempVol(:))=' num2str(max(fTempVol(:))) ]);
disp(['min(fTempVol(:))=' num2str(min(fTempVol(:))) ]);
%
% Display montage of all slices 
%

    % Graph-positioning parameters
	NCols=9;
	NRows=7;
	GI=1;	% Graph index, initial value
            
for i=1:SLICES  
        subplot(NRows,NCols,GI), imagesc(frame_data(:,:,i));GI=GI+1; 
        set(gca,'XTick', []);set(gca,'YTick', [])
        set(colorbar('vert'),'fontsize',6);  
end;

% 
% Display stack of all slices
% 
%imlook3d(frame_data);
