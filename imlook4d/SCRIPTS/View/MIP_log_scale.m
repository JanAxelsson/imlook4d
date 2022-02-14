% MIP.m

% Start script
    StartScript;

% Modify
imlook4d_Cdata=log( max(imlook4d_Cdata,[],3) + 0.01 );

WindowTitle('MIP','prepend')

% Finish script
EndScript
