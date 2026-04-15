% Refresh_All.m
%
% Calls Duplicate repeteadly for all open imlook4d instances, and closes
% original.  This refreshes all windows
%

    StoreVariables;

    disp('SCRIPTS/Refresh_All.m entered');
     
    g=findobj('Tag', 'imlook4d');  % Seems to find in order of creation
    w = waitbar(0, 'Starting');
    n = length(g);
    for j = n : -1 : 1  % Loop backward so that latest window is created last
        % Save only figures and imlook4d instances
        if strcmp( get( g(j),'Tag'), 'imlook4d' )  
             try
                 windowname = g(j).Name ;
                 waitIndex =  (n - j) + 1;
                 disp( [ '(' num2str(waitIndex) ' / ' num2str(n) ') Refreshing window ' windowname ]);
                 waitbar( waitIndex / n,  w, [ '(' num2str(waitIndex)  ' / ' num2str(n) ') Refreshing window = ' windowname ] );

                 % Refresh by Duplicating, moving to same position, and closing original
                 imlook4d_current_handle = g(j);
                 Duplicate
                 newHandle.Position = g(j).Position;
                 close( g(j));


             catch EXCEPTION
                dispRed( ['Failed refreshing ' windowname ]);
                close( g(j));
             end
        end
    end   
    close(w)

 %   
 % FINALIZE
 %     
   ClearVariables;
