% YOUR SCRIPT NAME HERE
% ---------------------
% This is a template for an imlook4d script that runs your code and puts the results into a new imlook4d window.
% For documentation:  a) imlook4d menu "/HELP/Help",   or 
%                     b) type in matlab:   open('Scripting-imlook4d.pdf')  
%
% 1) Edit your own code, and save it in the folder USER_SCRIPTS 
%    (File naming: use "_" instead of space, and only alpha-numeric characters. File name must start with a character)
%    (Example file name: "My_First_Script.m", which will be visible in menu "/SCRIPTS/USER/My First Script")
%
% 2) Open a new imlook4d and the code can be executed on your own data from
%    the menu /SCRIPTS/USER

% Start a script and record variables
StoreVariables
Export; 

% Data fields that can be modified in your own code:
% --------------------------------------------------
% imlook4d_Cdata      - 3D, or 4D data matrix with indeces to (x, y, z, time) coordinates
% imlook4d_ROI        - 3D ROI matrix (pixels from ROI 1 has value 1, ROI2 value 2, ...)
% imlook4d_slice      - current slice number
% imlook4d_frame      - current frame number
% imlook4d_ROI_number - current ROI number
% imlook4d_ROINames   - cell with ROI names

% --------------------------------------------------
% START OWN CODE:
% --------------------------------------------------

oldFolder = cd();
folder = fileparts(which('FreeSurferColorLUT.txt') );  % Identify folder by known file
cd(folder);
[file,path] = uigetfile('*.txt','Select a lookup file with number in left column and names in second column');

switch file
    case 'AAL2.txt'
        newNames = loadtable( which('AAL2.txt') );
        OLDCOLUMN = 1;
        NEWCOLUMN = 2;
        
    case 'FreeSurferColorLUT.txt'
        newNames = loadtable( which('FreeSurferColorLUT.txt'), ' ', 6);
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
Import; 
%ClearVariables
cd(oldFolder)

