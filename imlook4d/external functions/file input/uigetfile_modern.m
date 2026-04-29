function [file, path, ind] = uigetfile_modern(filter, title, startPath)
    % --- Setup and Input Handling ---
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
    fig.CloseRequestFcn = @(~,~) cleanClose();
    
    % --- OS-Specific Icon Setup ---
    imgDir = fullfile(fileparts(mfilename('fullpath')), 'images');
    s_folder = []; s_file = [];
    switch computer
        case {'PCWIN', 'PCWIN64'}, fImg = 'win_folder.png'; fiImg = 'win_file.png';
        case {'MACI64', 'MACA64'}, fImg = 'mac_folder.png'; fiImg = 'mac_file.png';
        otherwise, fImg = 'lin_folder.png'; fiImg = 'lin_file.png';
    end
    
    pf = fullfile(imgDir, fImg); pfi = fullfile(imgDir, fiImg);
    if exist(pf, 'file'), s_folder = uistyle('Icon', pf); end
    if exist(pfi, 'file'), s_file = uistyle('Icon', pfi); end

    % --- Layout ---
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
    filterDD = uidropdown(filterGrid, 'Items', filter(:,2), 'ItemsData', filter(:,1), ...
        'ValueChangedFcn', @(src,e) updateDisplay()); 

    btnGrid = uigridlayout(g, [1 3], 'ColumnWidth', {'1x', 100, 100});
    uibutton(btnGrid, 'Text', 'Cancel', 'ButtonPushedFcn', @(~,~) cleanClose());
    openBtn = uibutton(btnGrid, 'Text', 'Open', 'FontWeight', 'bold', 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) uiresume(fig));

    fileTable.CellSelectionCallback = @(src, e) handleSingleClick(e);
    fileTable.DoubleClickedFcn = @(src, e) handleDoubleClick();

    % --- Functions ---

    function manualPathEdit(newPath)
        if exist(newPath, 'dir'), currentDir = newPath; searchField.Value = ''; updateDisplay();
        else, uialert(fig, ['Folder not found: ' newPath], 'Invalid Path'); pathField.Value = currentDir; end
    end

    function updateDisplay(searchTerm)
        if nargin < 1, searchTerm = searchField.Value; end
        
        % Kill any existing timer before starting a new folder load
        if isfield(fig.UserData, 'loadTimer') && isvalid(fig.UserData.loadTimer)
            stop(fig.UserData.loadTimer); delete(fig.UserData.loadTimer);
        end

        d = dir(currentDir);
        d = d(~strncmp({d.name}, '.', 1)); 
        folders = d([d.isdir]);
        files = d(~[d.isdir]);
        
        activeFilter = filterDD.Value;
        if ~isempty(files) && ~any(strcmp(activeFilter, {'*.*', '*'}))
            extList = strsplit(activeFilter, ';');
            matchIdx = false(1, length(files));
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
        
        fileTable.Data = {};
        removeStyle(fileTable);
        pathField.Value = currentDir;
        openBtn.Enable = 'off';
        
        if isempty(combined), return; end
        
        % Stage 1: Load N files immediately
        N = 50; 
        totalItems = length(combined);
        processBatch(1, min(N, totalItems));
        
        % Stage 2: Background Timer
        if totalItems > N
            t = timer('ExecutionMode', 'fixedSpacing', 'Period', 0.05, ...
                      'TimerFcn', @(~,~) timerBatchLoad(), 'UserData', N + 1); 
            fig.UserData.loadTimer = t;
            start(t);
        end

        function timerBatchLoad()
            if ~isvalid(fig), stop(t); delete(t); return; end
            sIdx = t.UserData;
            eIdx = min(sIdx + 99, totalItems);
            processBatch(sIdx, eIdx);
            if eIdx >= totalItems, stop(t); delete(t); else, t.UserData = eIdx + 1; end
        end

        function processBatch(sIdx, eIdx)
            batchSize = eIdx - sIdx + 1;
            batchData = cell(batchSize, 4);
            for i = sIdx:eIdx
                row = i - sIdx + 1;
                batchData{row, 2} = combined(i).name;
                batchData{row, 4} = combined(i).date;
                if combined(i).isdir
                    batchData{row, 1} = ''; batchData{row, 3} = '--';
                    if ~isempty(s_folder), addStyle(fileTable, s_folder, 'cell', [i, 1]); else, batchData{row, 1} = '📁'; end
                else
                    batchData{row, 1} = ''; batchData{row, 3} = sprintf('%.1f KB', combined(i).bytes/1024);
                    if ~isempty(s_file), addStyle(fileTable, s_file, 'cell', [i, 1]); else, batchData{row, 1} = '📄'; end
                end
            end
            fileTable.Data = [fileTable.Data; batchData];
        end
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
        p = fileparts(currentDir);
        if ~isempty(p) && ~strcmp(p, currentDir), currentDir = p; searchField.Value = ''; updateDisplay(); end
    end

    function cleanClose()
        uiresume(fig);
    end

    updateDisplay();
    uiwait(fig);

    % --- ULTIMATE CLEANUP ---
    if isvalid(fig)
        % Kill timer safely
        if isfield(fig.UserData, 'loadTimer') && isvalid(fig.UserData.loadTimer)
            stop(fig.UserData.loadTimer); delete(fig.UserData.loadTimer);
        end
        if ~isempty(selectedItem)
            file = selectedItem; path = [currentDir filesep];
            [~, ind] = ismember(filterDD.Value, filter(:,1));
        end
        delete(fig);
    end
end
