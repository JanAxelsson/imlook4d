function [answer, handles] = ModelDialog( handles, model_name, prompt, failedDefaultAnswers)

%
% Dialog
%

% Defaults from local instance if exists, otherwise second alternative
try 
    eval(['defaultanswer = handles.model.' model_name '.inputs'] );
catch
    defaultanswer = RetriveEarlierValues(model_name, failedDefaultAnswers );  % Read default if exists, or apply these as default
end

% Dialog
title=[ model_name ' inputs'];
numlines=1;
answer=inputdlg(prompt,title,numlines,defaultanswer);

% Store answer as new global dialog default
StoreValues(model_name, answer); 

% Store answer as local default in imlook4d instance
eval(['handles.model.' model_name '.inputs = answer;'] );



