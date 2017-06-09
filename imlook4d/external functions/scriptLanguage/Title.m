% Title
%
% Sets new imlook4d window-title based on title in imlook4d_current_handles.
% The variable historyDescriptor is added in front of existing name
% 
% Works on imlook4d instance in newHandle
% Needs the following variables:   historyDescriptor, newHandle

try
    set(imlook4d_current_handle,'Name', [historyDescriptor ' ' get(imlook4d_current_handles.figure1,'Name') ]); 
catch
%     fprintf(2,'WARNING in title:   Window title not set - historyDescriptor may not be set\n')
% 
%     disp('useage:');
%     help Title
    set(imlook4d_current_handle,'Name', [ get(imlook4d_current_handles.figure1,'Name') ]); 
end


