function [file, path, ind] = uiputfile_modern(filter, title, startPath)
    % --- Setup and Input Handling ---
    if nargin < 1 || isempty(filter), filter = {'*.*', 'All Files (*.*)'}; end
    if ischar(filter), filter = {filter, sprintf('Filter (%s)', filter)}; end
    if iscell(filter) && size(filter, 2) == 1, filter = [filter, filter]; end
    if nargin < 2 || isempty(title), title = 'Save File'; end
    if nargin < 3 || isempty(startPath), startPath = pwd; end
    
    % Logic to extract default filename and path
    defaultFile = '';
    if ~exist(startPath, 'dir')
        [parent, name, ext] = fileparts(startPath);
        if ~isempty(parent) && exist(parent, 'dir')
            currentDir = parent;
            defaultFile = [name ext];
        else
            currentDir = pwd;
            defaultFile = startPath;
        end
    else
        currentDir = startPath;
    end
    
    file = 0; path = 0; ind = 0;
    selectedItem = defaultFile; 
    combined = []; 

    % --- GUI Figure with Failsafe ---
    fig = uifigure('Name', title, 'Position', [500 400 750 700], 'WindowStyle', 'modal', 'Visible', 'off');
    fig.CloseRequestFcn = @(~,~) cleanClose();
    fig.WindowKeyPressFcn = @(src, e) handleKeyPress(e);
    
    % --- Icon Setup (Flat folder structure) ---
    imgDir = fileparts(mfilename('fullpath')); 
    isDark = mean(fig.Color) < 0.5;
    switch computer
        case {'PCWIN', 'PCWIN64'}, fName = 'win_folder'; fiName = 'win_file';
        case {'MACI64', 'MACA64'}, fName = 'mac_folder'; fiName = 'mac_file';
        otherwise, fName = 'lin_folder'; fiName = 'lin_file';
    end
    
    if isDark, fN_f = [fName '_dark.png']; fiN_f = [fiName '_dark.png'];
    else, fN_f = [fName '.png']; fiN_f = [fiName '.png']; end
    
    s_folder = []; s_file = [];
    pf = fullfile(imgDir, fN_f); pfi = fullfile(imgDir, fiN_f);
    if isDark && ~exist(pf, 'file'), pf = fullfile(imgDir, [fName '.png']); end
    if isDark && ~exist(pfi, 'file'), pfi = fullfile(imgDir, [fiName '.png']); end
    if exist(pf, 'file'), s_folder = uistyle('Icon', pf); end
    if exist(pfi, 'file'), s_file = uistyle('Icon', pfi); end

    % --- Layout ---
    g = uigridlayout(fig, [7 1]);
    g.RowHeight = {40, 40, '1x', 40, 40, 40, 50};

    % Row 1: Path
    pathGrid = uigridlayout(g, [1 3], 'ColumnWidth', {'1x', 60, 100});
    pathField = uieditfield(pathGrid, 'Value', currentDir, 'Editable', 'on', ...
        'ValueChangedFcn', @(src,e) manualPathEdit(src.Value));
    uibutton(pathGrid, 'Text', 'Up ▲', 'ButtonPushedFcn', @(~,~) navigateUp());
    uibutton(pathGrid, 'Text', 'New Folder', 'ButtonPushedFcn', @(~,~) makeNewFolder());

    % Row 2: Search
    searchField = uieditfield(g, 'Placeholder', 'Search...', 'ValueChangingFcn', @(src,e) updateDisplay(e.Value));

    % Row 3: Table
    fileTable = uitable(g, 'ColumnName', {'', 'Name', 'Size', 'Date'}, ...
        'ColumnWidth', {35, '1x', 90, 140}, 'RowName', [], 'ColumnSortable', true, ...
        'SelectionType', 'row', 'BusyAction', 'cancel', 'Interruptible', 'off');

    % Row 4: Show Files Checkbox
    showFilesCB = uicheckbox(g, 'Text', 'Show files', 'Value', false, ...
        'ValueChangedFcn', @(~,~) updateDisplay());

    % Row 5: Filename Input
    nameGrid = uigridlayout(g, [1 2], 'ColumnWidth', {80, '1x'});
    uilabel(nameGrid, 'Text', 'File name:');
    nameField = uieditfield(nameGrid, 'Value', defaultFile);

    % Row 6: Filter Dropdown (Now only controls default extension)
    filterGrid = uigridlayout(g, [1 2], 'ColumnWidth', {80, '1x'});
    uilabel(filterGrid, 'Text', 'Save as:');
    filterDD = uidropdown(filterGrid, 'Items', filter(:,2), 'ItemsData', filter(:,1)); 

    % Row 7: Action Buttons
    btnGrid = uigridlayout(g, [1 3], 'ColumnWidth', {'1x', 100, 100});
    uibutton(btnGrid, 'Text', 'Cancel', 'ButtonPushedFcn', @(~,~) cleanClose());
    uibutton(btnGrid, 'Text', 'Save', 'FontWeight', 'bold', 'ButtonPushedFcn', @(~,~) trySave());

    fileTable.CellSelectionCallback = @(src, e) handleSingleClick(e);
    fileTable.DoubleClickedFcn = @(src, e) handleDoubleClick();

    % --- Functions ---
    function handleKeyPress(e)
        if ~isvalid(fig), return; end
        if strcmp(e.Key, 'escape'), cleanClose(); end
        if strcmp(e.Key, 'return') && isequal(fig.CurrentObject, pathField), manualPathEdit(pathField.Value); end
    end

    function makeNewFolder()
        newName = inputdlg('Folder name:', 'New Folder', [1 50], {'New Folder'});
        if isempty(newName), return; end
        newP = fullfile(currentDir, newName{1});
        if exist(newP, 'dir'), uialert(fig, 'Exists.', 'Error');
        else, [s, m] = mkdir(newP); if s, currentDir = newP; updateDisplay(); else, uialert(fig, m, 'Error'); end; end
    end

    function manualPathEdit(newPath)
        if exist(newPath, 'dir'), currentDir = newPath; updateDisplay(); end
    end

    function updateDisplay(searchTerm)
        if ~isvalid(fig), return; end
        try
            if nargin < 1, searchTerm = searchField.Value; end
            if isfield(fig.UserData, 'loadTimer') && isvalid(fig.UserData.loadTimer)
                stop(fig.UserData.loadTimer); delete(fig.UserData.loadTimer);
            end

            d = dir(currentDir); d = d(~strncmp({d.name}, '.', 1)); 
            
            % Apply Show Files toggle
            if ~showFilesCB.Value, d = d([d.isdir]); end
            
            folders = d([d.isdir]); 
            files = d(~[d.isdir]); % No more filtering by extension here!
            
            combined = [folders; files];
            if ~isempty(searchTerm) && ~isempty(combined)
                combined = combined(contains(lower({combined.name}), lower(searchTerm)));
            end
            
            fileTable.Data = {}; removeStyle(fileTable); pathField.Value = currentDir;
            if isempty(combined), return; end
            
            N = 50; totalItems = length(combined);
            processBatch(1, min(N, totalItems));
            if totalItems > N
                t = timer('ExecutionMode', 'fixedSpacing', 'Period', 0.05, 'TimerFcn', @(~,~) timerBatchLoad(), 'UserData', N + 1); 
                fig.UserData.loadTimer = t; start(t);
            end
        catch, end

        function timerBatchLoad()
            if ~isvalid(fig), stop(t); delete(t); return; end
            try
                sIdx = t.UserData; eIdx = min(sIdx + 99, totalItems);
                processBatch(sIdx, eIdx);
                if eIdx >= totalItems, stop(t); delete(t); else, t.UserData = eIdx + 1; end
            catch, stop(t); delete(t); end
        end

        function processBatch(sIdx, eIdx)
            batchData = cell(eIdx - sIdx + 1, 4);
            for i = sIdx:eIdx
                row = i - sIdx + 1;
                batchData{row, 2} = combined(i).name; batchData{row, 4} = combined(i).date;
                if combined(i).isdir
                    batchData{row, 1} = ''; batchData{row, 3} = '--';
                    if ~isempty(s_folder), addStyle(fileTable, s_folder, 'cell', [i, 1]); end
                else
                    batchData{row, 1} = ''; batchData{row, 3} = sprintf('%.1f KB', combined(i).bytes/1024);
                    if ~isempty(s_file), addStyle(fileTable, s_file, 'cell', [i, 1]); end
                end
            end
            fileTable.Data = [fileTable.Data; batchData];
        end
    end

    function handleSingleClick(e)
        if isempty(e.Indices), return; end
        row = e.Indices(1);
        if row <= length(combined) && ~combined(row).isdir, nameField.Value = combined(row).name; end
    end

    function handleDoubleClick()
        if ~isvalid(fig), return; end
        s = fileTable.Selection; if isempty(s), return; end
        row = s(1);
        if row <= length(combined) && combined(row).isdir
            currentDir = fullfile(currentDir, combined(row).name); searchField.Value = ''; updateDisplay();
        elseif row <= length(combined)
            nameField.Value = combined(row).name; trySave();
        end
    end

    function navigateUp()
        p = fileparts(currentDir); if ~isempty(p) && ~strcmp(p, currentDir), currentDir = p; updateDisplay(); end
    end

    function trySave()
        resFile = nameField.Value; if isempty(resFile), uialert(fig, 'Enter name.', 'Missing'); return; end
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

    function cleanClose()
        if isvalid(fig), uiresume(fig); end
    end

    % --- Execution ---
    updateDisplay();
    fig.Visible = 'on';
    uiwait(fig);

    if isvalid(fig)
        if isfield(fig.UserData, 'loadTimer') && isvalid(fig.UserData.loadTimer), stop(fig.UserData.loadTimer); delete(fig.UserData.loadTimer); end
        if ~isempty(selectedItem)
            file = selectedItem; path = [currentDir filesep];
            [~, ind] = ismember(filterDD.Value, filter(:,1));
        end
        delete(fig);
    end
end
