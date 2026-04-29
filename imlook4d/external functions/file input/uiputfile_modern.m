function [file, path, ind] = uiputfile_modern(filter, title, startPath)
    % 1. Setup
    if nargin < 1 || isempty(filter), filter = {'*.*', 'All Files (*.*)'}; end
    if ischar(filter), filter = {filter, sprintf('Filter (%s)', filter)}; end
    if iscell(filter) && size(filter, 2) == 1, filter = [filter, filter]; end
    if nargin < 2 || isempty(title), title = 'Save File'; end
    if nargin < 3 || isempty(startPath), startPath = pwd; end
    
    defaultFile = '';
    if ~exist(startPath, 'dir')
        [parent, name, ext] = fileparts(startPath);
        if exist(parent, 'dir'), currentDir = parent; defaultFile = [name ext]; else, currentDir = pwd; end
    else, currentDir = startPath; end
    
    file = 0; path = 0; ind = 0;
    selectedItem = defaultFile; 
    combined = [];

    % --- GUI Creation ---
    fig = uifigure('Name', title, 'Position', [500 400 750 650], 'WindowStyle', 'modal');
    fig.CloseRequestFcn = @(~,~) uiresume(fig);
    
    % --- OS-Specific Icon Setup ---
    imgDir = fullfile(fileparts(mfilename('fullpath')), 'images');
    s_folder = []; s_file = [];
    switch computer
        case {'PCWIN', 'PCWIN64'}
            fImg = 'win_folder.png'; fiImg = 'win_file.png';
        case {'MACI64', 'MACA64'}
            fImg = 'mac_folder.png'; fiImg = 'mac_file.png';
        otherwise
            fImg = 'lin_folder.png'; fiImg = 'lin_file.png';
    end
    path_f = fullfile(imgDir, fImg); path_fi = fullfile(imgDir, fiImg);
    if exist(path_f, 'file'), s_folder = uistyle('Icon', path_f); end
    if exist(path_fi, 'file'), s_file = uistyle('Icon', path_fi); end

    g = uigridlayout(fig, [6 1]);
    g.RowHeight = {40, 40, '1x', 40, 40, 50};

    pathGrid = uigridlayout(g, [1 3], 'ColumnWidth', {'1x', 60, 100});
    pathField = uieditfield(pathGrid, 'Value', currentDir, 'Editable', 'on', 'ValueChangedFcn', @(src,e) manualPathEdit(src.Value));
    uibutton(pathGrid, 'Text', 'Up ▲', 'ButtonPushedFcn', @(~,~) navigateUp());
    uibutton(pathGrid, 'Text', 'New Folder', 'ButtonPushedFcn', @(~,~) makeNewFolder());

    searchField = uieditfield(g, 'Placeholder', 'Search in current folder...', 'ValueChangingFcn', @(src,e) updateDisplay(e.Value));

    fileTable = uitable(g, 'ColumnName', {'', 'Name', 'Size', 'Date'}, ...
        'ColumnWidth', {35, '1x', 90, 140}, 'RowName', [], 'ColumnSortable', true, 'SelectionType', 'row');

    nameGrid = uigridlayout(g, [1 2], 'ColumnWidth', {80, '1x'});
    uilabel(nameGrid, 'Text', 'File name:');
    nameField = uieditfield(nameGrid, 'Value', defaultFile);

    filterGrid = uigridlayout(g, [1 2], 'ColumnWidth', {80, '1x'});
    uilabel(filterGrid, 'Text', 'Save as:');
    filterDD = uidropdown(filterGrid, 'Items', filter(:,2), 'ItemsData', filter(:,1), 'ValueChangedFcn', @(src,e) updateDisplay()); 

    btnGrid = uigridlayout(g, [1 3], 'ColumnWidth', {'1x', 100, 100});
    uibutton(btnGrid, 'Text', 'Cancel', 'ButtonPushedFcn', @(~,~) uiresume(fig));
    uibutton(btnGrid, 'Text', 'Save', 'FontWeight', 'bold', 'ButtonPushedFcn', @(~,~) trySave());

    fileTable.CellSelectionCallback = @(src, e) handleSingleClick(e);
    fileTable.DoubleClickedFcn = @(src, e) handleDoubleClick();

    % --- Functions ---
    function makeNewFolder()
        newName = inputdlg('Enter folder name:', 'New Folder', [1 50], {'New Folder'});
        if isempty(newName), return; end
        newP = fullfile(currentDir, newName{1});
        if exist(newP, 'dir'), uialert(fig, 'Folder exists.', 'Error');
        else, [s, m] = mkdir(newP); if s, currentDir = newP; searchField.Value = ''; updateDisplay(); else, uialert(fig, m, 'Error'); end; end
    end

    function manualPathEdit(newPath)
        if exist(newPath, 'dir'), currentDir = newPath; searchField.Value = ''; updateDisplay();
        else, uialert(fig, ['Folder not found: ' newPath], 'Invalid Path'); pathField.Value = currentDir; end
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
        removeStyle(fileTable);
        for i = 1:length(combined)
            data{i,2} = combined(i).name; data{i,4} = combined(i).date;
            if combined(i).isdir
                data{i,1} = ''; data{i,3} = '--';
                if ~isempty(s_folder), addStyle(fileTable, s_folder, 'cell', [i, 1]); else, data{i,1} = '📁'; end
            else
                data{i,1} = ''; data{i,3} = sprintf('%.1f KB', combined(i).bytes/1024);
                if ~isempty(s_file), addStyle(fileTable, s_file, 'cell', [i, 1]); else, data{i,1} = '📄'; end
            end
        end
        fileTable.Data = data; pathField.Value = currentDir;
    end

    function handleSingleClick(e)
        if isempty(e.Indices), return; end
        row = e.Indices(1);
        if row <= length(combined) && ~combined(row).isdir, nameField.Value = combined(row).name; end
    end

    function handleDoubleClick()
        s = fileTable.Selection; if isempty(s), return; end
        row = s(1);
        if row <= length(combined) && combined(row).isdir
            currentDir = fullfile(currentDir, combined(row).name); searchField.Value = ''; updateDisplay();
        elseif row <= length(combined)
            nameField.Value = combined(row).name; trySave();
        end
    end

    function navigateUp()
        p = fileparts(currentDir); if ~isempty(p) && ~strcmp(p, currentDir), currentDir = p; searchField.Value = ''; updateDisplay(); end
    end

    function trySave()
        resFile = nameField.Value;
        if isempty(resFile), uialert(fig, 'Enter name.', 'Missing'); return; end
        [~, ~, cExt] = fileparts(resFile);
        if isempty(cExt) && ~strcmp(filterDD.Value, '*.*')
            exs = strsplit(filterDD.Value, ';'); cleanE = strrep(exs{1}, '*', '');
            if contains(filterDD.Value, '.nii.gz'), resFile = [resFile '.nii.gz']; else, resFile = [resFile cleanE]; end
        end
        if exist(fullfile(currentDir, resFile), 'file')
            c = uiconfirm(fig, sprintf('Replace "%s"?', resFile), 'Confirm', 'Options', {'Yes', 'No'}, 'DefaultOption', 'No');
            if strcmp(c, 'No'), return; end
        end
        selectedItem = resFile; uiresume(fig);
    end

    updateDisplay();
    uiwait(fig);
    if isvalid(fig)
        if ~isempty(selectedItem), file = selectedItem; path = [currentDir filesep]; [~, ind] = ismember(filterDD.Value, filter(:,1)); end
        delete(fig);
    end
end
