% Erode_ROI.m
%
% SCRIPT for imlook4d to Fill hole in ROI .
%
%
% Inputs :
% - output ROI number, "new" or "current"
%
%
% Jan Axelsson



if (~areTheseToolboxesInstalled({'Image Processing Toolbox'}) )
    warndlg('Missing the required toolbox:  Image Processing Toolbox');
    return
end



% INITIALIZE

    %  imlook4d_current_handles is updated whenever SCRIPTS menu in imlook4d is
    %  selected
        
    % Export to workspace
    StoreVariables
    Export
    % Read default if exists, or apply these as default
    defaultanswer = RetriveEarlierValues('Erode_ROI', {'3', '3', '3'} ); 
    
  
    
    % Get user input
    prompt={'Width x (pixels)', 'Width y (pixels)', 'Width z (pixels)' };
        title='Erode by';
        numlines=1;
    answer=inputdlg(prompt,title,numlines,defaultanswer);
    if isempty(answer)  % cancelled inputdlg and clean up
        ClearVariables
        return
    end

    dx = str2num(answer{1});
    dy = str2num(answer{2});
    dz = str2num(answer{3});

    
    % Store answer as new dialog default
    StoreValues('Erode_ROI', answer ); 

% 
% PROCESS
%

roiMatrix = imlook4d_ROI == imlook4d_ROI_number;
sum(roiMatrix(:))

se = strel('cuboid',[ dx dy dz]);
newRoi = imerode(roiMatrix,se); 
sum(newRoi(:))

imlook4d_ROI( ( imlook4d_ROI == imlook4d_ROI_number) ) = 0;  % Clean this ROI, before drawing what is left
imlook4d_ROI( newRoi ) = imlook4d_ROI_number;  % draw what is left after erode

%   
% FINALIZE
%
       
    % Import into imlook4d from Workspace
   % imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles); % Import from workspace to current imlook4d instance
    ImportUntouched
    %Import % Adds ROI to handles in import function

    % Store default until next tim
    %imlook4d_store.Threshold.inputs =  answer;
   
   ClearVariables
    %disp('SCRIPTS/Threshold.m DONE');
