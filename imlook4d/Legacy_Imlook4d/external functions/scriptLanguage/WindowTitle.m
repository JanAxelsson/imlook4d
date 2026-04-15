function WindowTitle( string, mode)

% Import from workspace
 try  
     imlook4d_current_handles=evalin('base', 'imlook4d_current_handles');
 catch
     disp('failed importing imlook4d_Cdata');
 end;

 % If mode exists
if nargin==2
    if strcmp(mode,'prepend')
        string=[ string ' ' get(imlook4d_current_handles.figure1,'Name')];
    end

    if strcmp(mode,'append')
        string=[ get(imlook4d_current_handles.figure1,'Name') ' ' string];
    end
end

set(gcf,'Name',string)
