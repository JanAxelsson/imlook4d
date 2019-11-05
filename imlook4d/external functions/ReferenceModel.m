

% Find out if undefined ref region

RefRegionDefined = false; % Guess
if isfield(imlook4d_current_handles.model, 'common')
    if isfield(imlook4d_current_handles.model.common, 'ReferenceROINumbers')
        RefRegionDefined = true;
    end
    if isempty( imlook4d_current_handles.model.common.ReferenceROINumbers)
        RefRegionDefined = false;
    end
end

% Set Reference region if not defined
if ~RefRegionDefined
   Select_Reference_ROIs
end