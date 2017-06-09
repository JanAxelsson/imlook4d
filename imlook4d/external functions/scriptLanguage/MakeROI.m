function addROI = MakeROI( string)
% MakeROI(string)
%
% Creates a roi in current imlook4d instance


if (nargin == 0)
        % Try to get input from workspace INPUTS variable
          INPUTS=getINPUTS();
          string=INPUTS{1};
          evalin('base','clear INPUTS'); 
end


addROI = -1;

% Import from workspace
 try  
     imlook4d_current_handles=evalin('base', 'imlook4d_current_handles');
 catch
     disp('failed importing imlook4d_current_handles');
 end;
 
 
 try  
     imlook4d_current_handle=evalin('base', 'imlook4d_current_handle');
 catch
     disp('failed importing imlook4d_current_handle');
 end;
  
 try  
     imlook4d_ROINames=evalin('base', 'imlook4d_ROINames');
 catch
     disp('failed importing imlook4d_ROINames');
 end;
 
 

 % Create ROI
try      
        % Add to imlook4d_ROINames
        
        imlook4d_ROINames{end+1,1} = imlook4d_ROINames{end,1};  % Move 'Add ROI' to bottom
        imlook4d_ROINames{end-1,1} = string;  % Add new second to last
        assignin('base', 'imlook4d_ROINames', imlook4d_ROINames);
        addROI = length( imlook4d_ROINames ) - 1;  % Number of ROIs

        % Emulate creation in ROI Menu 
         %( This is done on Import - is it needed somewhere without Import ? )
        addROI = length(get(imlook4d_current_handles.ROINumberMenu,'String')); % The last line number in ROINumberMenu - which means "Add ROI"
        set(imlook4d_current_handles.ROINumberMenu,'Value',addROI)       
        imlook4d('ROINumberMenu_Callback', imlook4d_current_handles.ROINumberMenu,{},imlook4d_current_handles,string);  % Create ROI with name from string variable
catch
    disp('useage:');
    help MakeROI
end
