 % Opens a new imlook4d, and
 % creates variables in workspace:
 %   imlook4d_current_handle
 %   imlook4d_current_handles
 % 
 % Optional return handle to imlook4d instance as output argument
 
   function h=Open( arg1 )  
   
   if nargin()==0 
         h=imlook4d();
   end
   
   if nargin()==1
       try
         dummy=getINPUTS();
       catch
       end
       h=imlook4d(arg1);
   end
   
   handles = guidata(h);

   
   % Set new handles
   assignin('base', 'imlook4d_current_handle', h);
   assignin('base', 'imlook4d_current_handles', handles);
   
   
    
