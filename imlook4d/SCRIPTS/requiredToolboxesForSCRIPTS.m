
% Defininition of required toolboxes. Start with "hash." followed by script name
hash.ExampleScriptUsingAllDefinedToolBoxes = {'imagingToolbox', 'statisticalToolbox'}; % This is just an example, this script does not exist.

% Existing script dependencies
hash.Flood_Fill_ROI = {'imagingToolbox'};
hash.Flood_Fill_within_ROI = {'imagingToolbox'};
hash.Register_with_Fiducial_Markers = {'imagingToolbox'};
hash.Adaptive_threshold_within_ROI = {'imagingToolbox'};
%hash.Adaptive_threshold_within_ROI = {'dummyToolbox'};


% NOTE : 
% The naming and tests for different toolboxes are defined in 
% requiredToolboxSatisfied.m