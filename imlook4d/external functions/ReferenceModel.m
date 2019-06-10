

% Find out if undefined ref region

RefRegionUndefined = true; % Guess
if isfield(imlook4d_current_handles.model, 'common')
    if isfield(imlook4d_current_handles.model.common, 'ReferenceROINumbers')
        RefRegionUndefined = false;
    end
end

% Set Reference region if not defined
if RefRegionUndefined
   Select_Reference_ROIs
end