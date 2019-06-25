function ROI_naming_from_file( filePath)

% ROI_naming_from_file
% filePath is the name of the ROI LUT, which is a txt file
% example: ROI_naming_from_file( 'AAL2.txt')

% Start a script and record variables
StoreVariables
imlook4d_current_handle=evalin('base', 'imlook4d_current_handle');
imlook4d_current_handles=evalin('base', 'imlook4d_current_handles');
ExportUntouched; 
imlook4d_ROINames = evalin('base', 'imlook4d_ROINames');



oldFolder = cd();
folder = fileparts(which('FreeSurferColorLUT.txt') );  % Identify folder by file that I know exists
cd(folder);

if nargin==1
    [path,name,ext] = fileparts(filePath);
    file = [name ext];  
end
if nargin==0
    [file,path] = uigetfile('*.txt','Select a lookup file with number in left column and names in second column');
end

% try
%     newNames = loadtable( [ path file] );
% catch
%     newNames = loadtable( which(file) );
% end
% OLDCOLUMN = 1;
% NEWCOLUMN = 2;
% 
% 
% stop = length(imlook4d_ROINames)-1; % Exclude 'Add ROI'
% for i=1:stop
%     currentName = imlook4d_ROINames{i};
%     row = find(strcmp(newNames(:,OLDCOLUMN),currentName ));
%     if ~isempty(row) 
%         imlook4d_ROINames{i} = newNames{ row, NEWCOLUMN};
%     end
% end

imlook4d_ROINames = readRoiNamesFromFile([path file], imlook4d_ROINames);



% --------------------------------------------------
% END OF OWN CODE
% --------------------------------------------------

% Import your changes into new instance and clean up your variables
assignin('base', 'imlook4d_ROINames', imlook4d_ROINames);
ImportUntouched; 
%ClearVariables
cd(oldFolder)

