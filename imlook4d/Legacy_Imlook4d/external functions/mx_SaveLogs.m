%**************************************************************************
%Function Name: mx_SaveMaps
%Author: Mats Jonsson
%Created: May 28 2003
%Description: Helper function to the main program that saves all selected
%	       map images and their corresponding log files.
%Input: insResult - Cell array with 3-D images.
%
% iniSelectedMaps - The selected maps as a vector of integers.
%
% insFilenames - Cell array with destination filenames as strings.
%
% insResultPath - A string with the path where the images should be saved.
%
% insMapTypes - The available map types of the model as a "map type" structure.
%
% insHeader - The source image sequence "upc_ecat_util"-type header.
%
% insInputFilenames - Cell array with blood or reference input filenames.
%
% insSelectedModel - The used model as a "model" structure.
%
% insUserParams - The used parameters as a "user parameter" structure.
%
% insTracer - The tracer name as a string.
%
% insROIName - The ROI name as a string.
%
% insFilt - Filter information.
%
% insResultFilt - Filtered result image.

% Output:
% outsSuccWritten - Cell array of strings with complete filenames of maps
%		    which were successfully written.
%Function calls: ECATwrite, mx_WriteLogPage
%Revision history:
%Name	Date        Comment
%MJ     030528      First version
%AR     080318      Roiname, filter info and filtered result image as
%                   input.
%**************************************************************************


function outsSuccWritten = mx_SaveLogs(insResult, ...
    iniSelectedMaps, ...
    insFilenames, ...
    insResultPath, ...
    insMapTypes, ...
    insHeader, ...
    insInputFilenames, ...
    insSelectedModel, ...
    insUserParams, ...
    insTracer, ...
    insROIName, ...
    insFilt, ...
    insResultFilt)

%Input parameters -----------------------------------------------------------------
sResult = insResult;
iSelectedMaps = iniSelectedMaps;
sFilenames = insFilenames;
sResultPath = insResultPath;
sMapTypes = insMapTypes;
sHeader = insHeader;
sInputFilenames = insInputFilenames;
sSelectedModel = insSelectedModel;
sUserParams = insUserParams;
sTracer = insTracer;
sROIName = insROIName;
sFilt = insFilt;
sResultFilt = insResultFilt;
%----------------------------------------------------------------------------------


%Variables ------------------------------------------------------------------------
sLogFilename = '';  %The name of the target log file corresponding to the image.
sSuccWritten = {};  %Filenames of successfully written maps.
iOK = 0;  %Flag for successful writing.
iOK2 = 0;  %Flag for successful writing of filtered images.
%----------------------------------------------------------------------------------


for i=1:length(sResult)
    if (find(iSelectedMaps==i))
        if (~isempty(sResult{i}))
            %Ask user for output name and path.
            Resultfile = [sResultPath sFilenames{i}];
            [sFilenames{i},sResultPath,FilterIndex] = uiputfile('*.v*','Save parameter map as:' ,Resultfile);
            if all(sFilenames{i}) ~= 0
                %Write map image.
                iOK1 = ECATwrite([sResultPath sFilenames{i}], ...
                    sHeader, sResult{i}, ...
                    sMapTypes(i).mapunit);
                if (~isempty(sResultFilt))
                    %Write filtered map image.
                    [temppath tempname temppath] = fileparts(sFilenames{i});
                    iOK2 = ECATwrite([sResultPath tempname '_filt' temppath], ...
                        sHeader, sResultFilt{i}, ...
                        sMapTypes(i).mapunit);
                end
                if (iOK1)
                    sSuccWritten{end+1} = [sResultPath sFilenames{i}];
                    if (iOK2)
                        [temppath tempname temppath] = fileparts(sFilenames{i});
                        sSuccWritten{end+1} = [sResultPath tempname '_filt' temppath];
                    end

                    %If blood flow model, write max flow in each slice.
                    if findstr(sSelectedModel.model_name,'Input Bloodflow (iterative)')
                        flowima = sResult{i};
                        for j=1:size(flowima,3)
                            flowslice(j) = max(max(max(flowima(:,:,j))));
                        end
                    else
                        flowslice = [];
                    end
                    %Write image log file.
                    sLogFilename = [sResultPath sFilenames{i} '_log'];
                    mx_WriteLogPage('replace', sLogFilename, sHeader, ...
                        sInputFilenames, sSelectedModel, ...
                        sUserParams, sTracer, sROIName, sFilt, {}, sSuccWritten, flowslice);

                end
            end

        end

    end
end



%Output ---------------------------------------------------------------------------
outsSuccWritten = sSuccWritten;
%----------------------------------------------------------------------------------




