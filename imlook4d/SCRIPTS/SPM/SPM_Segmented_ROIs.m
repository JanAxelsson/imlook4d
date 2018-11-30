% Script recording started at : 20-Jun-2018 08:24:35
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
if ~verifySpmExists()
    return
end
StartScript; % Start a script and open a new instance of imlook4d to play with

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


%% Open c1-c5

currentFile = imlook4d_current_handles.image.file;
cFile = [ 'c1' currentFile];

% Open c1
V = spm_vol(cFile);
A = spm_read_vols(V); % Individual's c1... file

X = size(A,1);
Y = size(A,2);
Z = size(A,3);

M = zeros( X,Y,Z,5); 
M(:,:,:,1) = A;

% Open c2-c5
for i = 2:5
    cFile = [ 'c' num2str(i) currentFile];
    V = spm_vol(cFile);
    A = spm_read_vols(V); % Individual's c1... file
    M(:,:,:,i) = A;
end

%% Create ROI
maxM = max( M,[],4);
ROIs = zeros( X,Y,Z);
 for i = 1:size(M,4) % Loop frames in Y 
    ROIs = ROIs + i * ( ...
        ( M(:,:,:,i) == maxM ) & ( M(:,:,:,i) > 0.50 ) ...
        );

    %ROIs = ROIs + i * ( M(:,:,:,i) == maxM );
end
NewROIs = reshape(ROIs,X,Y,Z ); 

%% Save ROI file in Nifti
newFile = [ imlook4d_current_handles.image.folder  'TPM_based_ROIs.nii'];


V.fname = newFile;
V.dt = [16 0];
V = spm_write_vol(V, NewROIs);

LoadROI(newFile);


% --------------------------------------------------
% END OF OWN CODE
% --------------------------------------------------

%EndScript; % Import your changes into new instance and clean up your variables



