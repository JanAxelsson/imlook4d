function setModelsCheckbox()

    % Clear all 
    ModelsMenu = get(gcbo,'Parent');
    
    subMenues = findall(ModelsMenu,'Type','uimenu');
    for i = 1: length(subMenues)
        set( subMenues(i), 'Checked', 'off' );
    end
    
    % Set this checkbox
    set(gcbo,'Checked','on')
    