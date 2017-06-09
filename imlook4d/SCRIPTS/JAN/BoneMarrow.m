% Get bone and bone marrow from CT
%
% Requires: MATLAB Imaging Toolbox 
% 

if (~areTheseToolboxesInstalled({'Image Processing Toolbox'}) )
    warndlg('Missing the required toolbox:  Image Processing Toolbox');
    return
end

StartScript

marrowROINumber=MakeROI('marrow');                      % ROI to put marrow in (use imlook4d_ROI_number if same
boneROINumber=MakeROI('bone');
CTThreshold='300'; % Hounsfield value for Bone

waitBarHandle = waitbar(0,'Filling holes in ROIs');	% Initiate waitbar with text
N=size(imlook4d_Cdata,3);  % Number of slices

% Find Bone 
defaultanswer={'100%',CTThreshold, '1' , 'end'};
Threshold_ROI;  % Current ROI is the last selected

% Find Bone Marrow in each slice
for i=1:N
    waitbar(i/N);          % Update waitbar
    
    %imlook4d_ROI(:,:,i)=imlook4d_ROI_number*imfill(imlook4d_ROI(:,:,i)==imlook4d_ROI_number,'holes');  % logical
    
    % Hard bone (2D logical)
    HardBone=(imlook4d_ROI(:,:,i)==boneROINumber);
    
    % Hard bone + marrow (2D logical)
    BoneAndMarrow=imfill(HardBone,'holes');
    
    % Marrow
    Marrow=xor(BoneAndMarrow,HardBone);
    
    % Build Bone and Marrow ROIs
    imlook4d_ROI(:,:,i)=marrowROINumber*Marrow+boneROINumber*HardBone;  
    
end


close(waitBarHandle);                           % Close waitbar
toc
EndScript
