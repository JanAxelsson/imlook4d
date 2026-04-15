
% ClearVariables
allVariablesNow=[];                             % Make this variable name to be included
allVariablesNow=whos();
allVariablesNow=struct2cell(allVariablesNow); 
allVariablesNow=allVariablesNow(1,:);         % All variables as cell array of strings

%NOTE: Stored variables in imlook4d_variables_before_script

% Remove stored variables
differ=setdiff(allVariablesNow(1,:),imlook4d_variables_before_script(1,:) );

for i=1:size(differ,2)
    clear(differ{i});
end

clear i differ

