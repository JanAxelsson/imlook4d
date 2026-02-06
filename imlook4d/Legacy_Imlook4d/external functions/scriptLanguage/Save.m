% Save imlook4d data
%
function Save( string)
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
         
    imlook4d('SaveFile_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Save dialog