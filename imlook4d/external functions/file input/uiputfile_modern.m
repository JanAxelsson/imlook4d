function [file, path, ind] = uiputfile_modern(filter, title, startPath)
    % 1. Robust filter handling
    if nargin < 1 || isempty(filter)
        filter = {'*.*', 'All Files (*.*)'};
    elseif ischar(filter)
        filter = {filter, sprintf('Filter (%s)', filter)};
    end
    if iscell(filter) && size(filter, 2) == 1
        filter = [filter, filter];
    end
    
    if nargin < 2 || isempty(title), title = 'Save File'; end
    if nargin < 3 || isempty(startPath), startPath = pwd; end
    
    defaultFile = '';
    if ~exist(startPath, 'dir')
        [parent, name, ext] = fileparts(startPath);
        if exist(parent, 'dir')
            currentDir = parent; 
            defaultFile = [name ext];
        else
            currentDir = pwd;
        end
    else
        currentDir = startPath;
    end
    
    file = 0; path = 0; ind = 0;
    selectedItem = defaultFile; 

    % --- Create GUI ---
    fig = uifigure('Name', title, 'Position', [500 400 750 650], 'WindowStyle', 'modal');
    fig.CloseRequestFcn = @(~,~) uiresume(fig);
    
    g = uigridlayout(fig, [6 1]);
    g.RowHeight = {40, 40, '1x', 40, 40, 50};

    % Row 1: Path and Buttons
    pathGrid = uigridlayout(g, [1 3], 'ColumnWidth', {'1x', 60, 100});
    pathField = uieditfield(pathGrid, 'Value', currentDir, 'Editable', 'on', ...
        'ValueChangedFcn', @(src,e) manualPathEdit(src.Value));
    uibutton(pathGrid, 'Text', 'Up ▲', 'ButtonPushedFcn', @(~,~) navigateUp());
    uibutton(pathGrid, 'Text', 'New Folder', 'ButtonPushedFcn', @(~,~) makeNewFolder());

    % Row 2: Search
    searchField = uieditfield(g, 'Placeholder', 'Search in current folder...', ...
        'ValueChangingFcn', @(src,e) updateDisplay(e.Value));

    % Row 3: Table
    fileTable = uitable(g, ...
        'ColumnName', {'', 'Name', 'Size', 'Date'}, ...
        'ColumnWidth', {30, '1x', 90, 140}, ...
        'RowName', [], 'ColumnSortable', true, 'SelectionType', 'row');

    % Row 4: Filename
    nameGrid = uigridlayout(g, [1 2], 'ColumnWidth', {80, '1x'});
    uilabel(nameGrid, 'Text', 'File name:');
    nameField = uieditfield(nameGrid, 'Value', defaultFile);

    % Row 5: Filter
    filterGrid = uigridlayout(g, [1 2], 'ColumnWidth', {80, '1x'});
    uilabel(filterGrid, 'Text', 'Save as:');
    filterDD = uidropdown(filterGrid, 'Items', filter(:,2), 'ItemsData', filter(:,1), ...
        'ValueChangedFcn', @(src,e) updateDisplay()); 

    % Row 6: Buttons
    btnGrid = uigridlayout(g, [1 3], 'ColumnWidth', {'1x', 100, 100});
    uibutton(btnGrid, 'Text', 'Cancel', 'ButtonPushedFcn', @(~,~) uiresume(fig));
    uibutton(btnGrid, 'Text', 'Save', 'FontWeight', 'bold', 'ButtonPushedFcn', @(~,~) trySave());

    % Callbacks
    fileTable.CellSelectionCallback = @(src, e) handleSingleClick(e);
    fileTable.DoubleClickedFcn = @(src, e) handleDoubleClick();

    % --- Functions ---
    function makeNewFolder()
        newName = inputdlg('Enter folder name:', 'New Folder', [1 50], {'New Folder'});
        if isempty(newName), return; end
        
        newPath = fullfile(currentDir, newName{1});
        if exist(newPath, 'dir')
            uialert(fig, 'Folder already exists.', 'Error');
        else
            [status, msg] = mkdir(newPath);
            if status
                currentDir = newPath;
                searchField.Value = '';
                updateDisplay();
            else
                uialert(fig, msg, 'Error Creating Folder');
            end
        end
    end

    function manualPathEdit(newPath)
        if exist(newPath, 'dir')
            currentDir = newPath; 
            searchField.Value = ''; 
            updateDisplay();
        else
            uialert(fig, ['Folder not found: ' newPath], 'Invalid Path'); 
            pathField.Value = currentDir; 
        end
    end

    function updateDisplay(searchTerm)
        if nargin < 1, searchTerm = searchField.Value; end
        d = dir(currentDir); d = d(~strncmp({d.name}, '.', 1)); 
        folders = d([d.isdir]); files = d(~[d.isdir]);
        activeFilter = filterDD.Value;
        if ~isempty(files) && ~any(strcmp(activeFilter, {'*.*', '*'}))
            extList = strsplit(activeFilter, ';'); matchIdx = false(1, length(files));
            for i = 1:length(extList)
                regStr = regexptranslate('wildcard', strtrim(extList{i}));
                matchIdx = matchIdx | ~cellfun(@isempty, regexp({files.name}, regStr, 'once', 'ignorecase'));
            end
            files = files(matchIdx);
        end
        combined = [folders; files];
        if ~isempty(searchTerm) && ~isempty(combined)
            combined = combined(contains(lower({combined.name}), lower(searchTerm)));
        end
        data = cell(length(combined), 4);
        for i = 1:length(combined)
            if combined(i).isdir
                data{i,1} = '📁'; data{i,3} = '--';
            else
                data{i,1} = '📄'; data{i,3} = sprintf('%.1f KB', combined(i).bytes/1024);
            end
            data{i,2} = combined(i).name; data{i,4} = combined(i).date;
        end
        fileTable.Data = data; pathField.Value = currentDir;
    end

    function handleSingleClick(e)
        if isempty(e.Indices), return; end
        vData = fileTable.Data; row = e.Indices(1);
        if isempty(vData) || row > size(vData, 1), return; end
        if strcmp(vData{row, 1}, '📄')
            nameField.Value = vData{row, 2}; 
        end
    end

    function handleDoubleClick()
        s = fileTable.Selection; if isempty(s), return; end
        vData = fileTable.Data; row = s(1);
        if strcmp(vData{row, 1}, '📁')
            currentDir = fullfile(currentDir, vData{row, 2}); 
            searchField.Value = ''; 
            updateDisplay();
        else
            nameField.Value = vData{row, 2}; 
            trySave(); 
        end
    end

    function navigateUp()
        p = fileparts(currentDir); 
        if ~isempty(p) && ~strcmp(p, currentDir)
            currentDir = p; 
            searchField.Value = ''; 
            updateDisplay(); 
        end
    end

    function trySave()
        resFile = nameField.Value;
        if isempty(resFile)
            uialert(fig, 'Please enter a file name.', 'Missing Name'); 
            return; 
        end
        [~, ~, currentExt] = fileparts(resFile);
        activeFilter = filterDD.Value;
        if isempty(currentExt) && ~strcmp(activeFilter, '*.*')
            allExts = strsplit(activeFilter, ';');
            firstExt = strrep(allExts{1}, '*', '');
            if contains(activeFilter, '.nii.gz')
                resFile = [resFile '.nii.gz'];
            else
                resFile = [resFile firstExt];
            end
        end
        if exist(fullfile(currentDir, resFile), 'file')
            userChoice = uiconfirm(fig, sprintf('File "%s" already exists. Replace?', resFile), 'Confirm Save', 'Options', {'Yes', 'No'}, 'DefaultOption', 'No');
            if strcmp(userChoice, 'No'), return; end
        end
        selectedItem = resFile; 
        uiresume(fig);
    end

    updateDisplay();
    uiwait(fig);
    if isvalid(fig)
        if ~isempty(selectedItem)
            file = selectedItem; path = [currentDir filesep];
            [~, ind] = ismember(filterDD.Value, filter(:,1));
        end
        delete(fig);
    end
end
