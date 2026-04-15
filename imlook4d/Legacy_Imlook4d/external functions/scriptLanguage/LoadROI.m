% Load imlook4d ROI
%
function LoadROI( filePath)
     try  
         imlook4d_current_handle=evalin('base', 'imlook4d_current_handle');
     catch
         disp('failed importing imlook4d_current_handle');
     end;

     try  
         imlook4d_current_handles=evalin('base', 'imlook4d_current_handles');
     catch
         disp('failed importing imlook4d_current_handles');
     end;  
         
    imlook4d('LoadRoiPushbutton_Callback', imlook4d_current_handles.LoadROI,{} ,imlook4d_current_handles, filePath)