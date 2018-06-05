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
    [pathstr,name,ext] = fileparts(filePath);
    file = [name ext];  
end
if nargin==0
    [file,path] = uigetfile('*.txt','Select a lookup file with number in left column and names in second column');
end

switch file
    case 'AAL2.txt'
        newNames = loadtable( which('AAL2.txt') );
        OLDCOLUMN = 1;
        NEWCOLUMN = 2;
        
    case 'FreeSurferColorLUT.txt'
        newNames = loadtable( which('FreeSurferColorLUT.txt'), ' ', 6);
        OLDCOLUMN = 1;
        NEWCOLUMN = 2;
        
    case 'labels_Neuromorphometrics.txt'
        newNames = loadtable( which('labels_Neuromorphometrics.txt') );
        OLDCOLUMN = 1;
        NEWCOLUMN = 2;
        
    otherwise
        error('No valid ROI name lookup-table found');
        return
end


stop = length(imlook4d_ROINames)-1 % Exclude 'Add ROI'
for i=1:stop
    currentName = imlook4d_ROINames{i};
    row = find(strcmp(newNames(:,OLDCOLUMN),currentName ));
    if ~isempty(row) 
        imlook4d_ROINames{i} = newNames{ row, NEWCOLUMN};
    end
end



% --------------------------------------------------
% END OF OWN CODE
% --------------------------------------------------

% Import your changes into new instance and clean up your variables
assignin('base', 'imlook4d_ROINames', imlook4d_ROINames);
ImportUntouched; 
%ClearVariables
cd(oldFolder)

