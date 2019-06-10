function [ satisfied, missing ] = requiredToolboxSatisfied( scriptName, definitionFile)

    eval(definitionFile)

    % Guess defaults
    satisfied = true;
    missing = {};



    % Find if satisfied, and list missing toolboxes
    listed = isfield(hash,scriptName);

    if listed
        requiredToolboxes =  hash.(scriptName); % Cell array
        [ satisfied, missing ] = checkRequiredToolboxes( requiredToolboxes);
    end

    %
    % Internal functions
    %
        % Check whole list of required toolboxes
        function [ satisfied, missing ] = checkRequiredToolboxes( listOfRequiredToolboxes)
            
            satisfied = true;
            missing = {};

            for i = 1 : length( listOfRequiredToolboxes )
                % Tests for each toolbox defined here. Checks for function name
                [ satisfied, missing ] = testToolBox( listOfRequiredToolboxes{i}, 'imagingToolbox', 'bwboundaries', satisfied, missing);
                [ satisfied, missing ] = testToolBox( listOfRequiredToolboxes{i}, 'statisticalToolbox', 'kurtosis', satisfied, missing);
            end

            % Check for single required toolbox
            function  [ satisfied, missing ] = testToolBox( testThis, toolBoxName, testForFunctionName, satisfied, missing)

                if strcmp( toolBoxName, testThis)
                    toolboxExists = ~isempty( which(testForFunctionName) );
                    if ~toolboxExists
                        missing = [ missing, toolBoxName ];
                    end
                    satisfied = satisfied & toolboxExists ;
                end
