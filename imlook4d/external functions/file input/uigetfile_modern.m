function [file, path, ind] = uigetfile_modern(filter, title, startPath)
    % 1. Inställningar & Initiering
    if nargin < 1 || isempty(filter), filter = '*.*'; end
    if nargin < 2 || isempty(title), title = 'Välj fil'; end
    
    lastPath = getpref('ModernExplorer', 'LastPath', pwd);
    if nargin < 3 || isempty(startPath), startPath = lastPath; end
    
    file = 0; path = 0; ind = 0;
    currentDir = startPath;
    selectedItem = ''; 
    
    % Skapa GUI
    fig = uifigure('Name', title, 'Position', [500 400 650 550], 'WindowStyle', 'modal');
    g = uigridlayout(fig, [4 1]);
    g.RowHeight = {40, 40, '1x', 50};

    % Rad 1: Adressrad
    navGrid = uigridlayout(g, [1 2]);
    navGrid.ColumnWidth = {'1x', 60};
    pathField = uieditfield(navGrid, 'Value', currentDir, 'Editable', 'off');
    uibutton(navGrid, 'Text', 'Up ▲', 'ButtonPushedFcn', @(~,~) navigateUp());

    % Rad 2: Sökfält
    searchField = uieditfield(g, 'Placeholder', 'Sök i aktuell mapp...', ...
        'ValueChangingFcn', @(src,e) updateDisplay(e.Value));

    % Rad 3: Fillista med Sortering
    fileTable = uitable(g, ...
        'ColumnName', {'', 'Namn', 'Storlek', 'Datum'}, ...
        'ColumnWidth', {30, '1x', 90, 140}, ...
        'RowName', [], ...
        'ColumnEditable', false, ...
        'ColumnSortable', [false true true true], ... % Möjliggör klick-sortering
        'SelectionType', 'row', ...
        'CellSelectionCallback', @(src, e) handleSingleClick(e), ...
        'DoubleClickedFcn', @(src, e) handleDoubleClick());

    % Rad 4: Knappar
    btnGrid = uigridlayout(g, [1 3]);
    btnGrid.ColumnWidth = {'1x', 100, 100};
    uibutton(btnGrid, 'Text', 'Avbryt', 'ButtonPushedFcn', @(~,~) close(fig));
    openBtn = uibutton(btnGrid, 'Text', 'Öppna', 'FontWeight', 'bold', 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) uiresume(fig));

    % --- Interna Funktioner ---
    
    function updateDisplay(searchTerm)
        if nargin < 1, searchTerm = searchField.Value; end
        
        d = dir(currentDir);
        d = d(~strcmp({d.name}, '.') & ~strcmp({d.name}, '..'));
        
        is_dir = [d.isdir];
        folders = d(is_dir);
        files = d(~is_dir);
        
        if ~strcmp(filter, '*.*')
            regStr = regexptranslate('wildcard', filter);
            files = files(~cellfun(@isempty, regexp({files.name}, regStr, 'once')));
        end
        
        combined = [folders; files];
        if ~isempty(searchTerm)
            combined = combined(contains(lower({combined.name}), lower(searchTerm)));
        end
        
        n = length(combined);
        data = cell(n, 4);
        for i = 1:n
            if combined(i).isdir
                data{i,1} = '📁'; data{i,3} = '--';
            else
                data{i,1} = '📄'; data{i,3} = sprintf('%.1f KB', combined(i).bytes/1024);
            end
            data{i,2} = combined(i).name;
            data{i,4} = combined(i).date;
        end
        
        fileTable.Data = data;
        pathField.Value = currentDir;
        openBtn.Enable = 'off';
        selectedItem = '';
    end

    function handleSingleClick(e)
        if isempty(e.Indices), return; end
        row = e.Indices(1);
        
        % VIKTIGT: Läs från DisplayData för att hantera sorterad vy
        viewData = fileTable.DisplayData;
        if isempty(viewData), return; end
        
        selectedItem = viewData{row, 2};
        isDir = strcmp(viewData{row, 1}, '📁');
        
        if ~isDir, openBtn.Enable = 'on'; else, openBtn.Enable = 'off'; end
    end

    function handleDoubleClick()
        % Hämta raden som är markerad just nu
        s = fileTable.Selection;
        if isempty(s), return; end
        
        row = s(1);
        viewData = fileTable.DisplayData; % Hanterar sortering
        itemName = viewData{row, 2};
        isDir = strcmp(viewData{row, 1}, '📁');
        
        if isDir
            currentDir = fullfile(currentDir, itemName);
            searchField.Value = '';
            updateDisplay();
        else
            selectedItem = itemName;
            uiresume(fig);
        end
    end

    function navigateUp()
        parent = fileparts(currentDir);
        if ~isempty(parent) && ~strcmp(parent, currentDir)
            currentDir = parent;
            searchField.Value = '';
            updateDisplay();
        end
    end

    % Starta
    updateDisplay();
    uiwait(fig);

    % --- Returvärden ---
    if isvalid(fig)
        fullFilePath = fullfile(currentDir, selectedItem);
        if ~isempty(selectedItem) && exist(fullFilePath, 'file') && ~exist(fullFilePath, 'dir')
            file = selectedItem;
            path = [currentDir filesep];
            ind = 1;
            setpref('ModernExplorer', 'LastPath', currentDir);
        end
        delete(fig);
    end
end
