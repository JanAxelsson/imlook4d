function [file, path, ind] = uigetfile_modern(filter, title, startPath)
    % 1. Setup
    if nargin < 1 || isempty(filter), filter = {'*.*', 'All Files (*.*)'}; end
    if ischar(filter), filter = {filter, sprintf('Filter (%s)', filter)}; end
    if iscell(filter) && size(filter, 2) == 1, filter = [filter, filter]; end
    if nargin < 2 || isempty(title), title = 'Select File'; end
    if nargin < 3 || isempty(startPath), startPath = pwd; end
    if ~exist(startPath, 'dir'), startPath = pwd; end
    
    file = 0; path = 0; ind = 0;
    currentDir = startPath;
    selectedItem = ''; 
    combined = []; 

    % --- GUI Creation ---
    fig = uifigure('Name', title, 'Position', [500 400 750 600], 'WindowStyle', 'modal');
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

    g = uigridlayout(fig, [5 1]);
    g.RowHeight = {40, 40, '1x', 40, 50};

    pathGrid = uigridlayout(g, [1 2], 'ColumnWidth', {'1x', 60});
    pathField = uieditfield(pathGrid, 'Value', currentDir, 'Editable', 'on', ...
        'ValueChangedFcn', @(src,e) manualPathEdit(src.Value));
    uibutton(pathGrid, 'Text', 'Up ▲', 'ButtonPushedFcn', @(~,~) navigateUp());

    searchField = uieditfield(g, 'Placeholder', 'Search in current folder...', ...
        'ValueChangingFcn', @(src,e) updateDisplay(e.Value));

    fileTable = uitable(g, 'ColumnName', {'', 'Name', 'Size', 'Date'}, ...
        'ColumnWidth', {35, '1x', 90, 140}, 'RowName', [], 'ColumnSortable', true, 'SelectionType', 'row');

    filterGrid = uigridlayout(g, [1 2], 'ColumnWidth', {80, '1x'});
    uilabel(filterGrid, 'Text', 'File type:');
    filterDD = uidropdown(filterGrid, 'Items', filter(:,2), 'ItemsData', filter(:,1), 'ValueChangedFcn', @(src,e) updateDisplay()); 

    btnGrid = uigridlayout(g, [1 3], 'ColumnWidth', {'1x', 100, 100});
    uibutton(btnGrid, 'Text', 'Cancel', 'ButtonPushedFcn', @(~,~) uiresume(fig));
    openBtn = uibutton(btnGrid, 'Text', 'Open', 'FontWeight', 'bold', 'Enable', 'off', 'ButtonPushedFcn', @(~,~) uiresume(fig));

    fileTable.CellSelectionCallback = @(src, e) handleSingleClick(e);
    fileTable.DoubleClickedFcn = @(src, e) handleDoubleClick();

    % --- Functions ---
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
        fileTable.Data = data; pathField.Value = currentDir; openBtn.Enable = 'off';
    end

    function handleSingleClick(e)
        if isempty(e.Indices), return; end
        row = e.Indices(1);
        if row <= length(combined)
            selectedItem = combined(row).name;
            if ~combined(row).isdir, openBtn.Enable = 'on'; else, openBtn.Enable = 'off'; end
        end
    end

    function handleDoubleClick()
        s = fileTable.Selection; if isempty(s), return; end
        row = s(1);
        if row <= length(combined) && combined(row).isdir
            currentDir = fullfile(currentDir, combined(row).name); searchField.Value = ''; updateDisplay();
        elseif row <= length(combined)
            selectedItem = combined(row).name; uiresume(fig);
        end
    end

    function navigateUp()
        p = fileparts(currentDir); if ~isempty(p) && ~strcmp(p, currentDir), currentDir = p; searchField.Value = ''; updateDisplay(); end
    end

    updateDisplay();
    uiwait(fig);
    if isvalid(fig)
        if ~isempty(selectedItem), file = selectedItem; path = [currentDir filesep]; [~, ind] = ismember(filterDD.Value, filter(:,1)); end
        delete(fig);
    end
end
