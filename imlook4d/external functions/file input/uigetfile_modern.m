function [file, path, ind] = uigetfile_modern(filter, title, startPath)
    % 1. Robust hantering av filter-input
    if nargin < 1 || isempty(filter)
        filter = {'*.*', 'Alla filer (*.*)'};
    elseif ischar(filter)
        filter = {filter, sprintf('Filter (%s)', filter)};
    elseif iscell(filter) && size(filter, 2) == 1
        % Om bara extensions skickats som cell-array, skapa namn-kolumn
        filter = [filter, filter];
    end
    
    if nargin < 2 || isempty(title), title = 'Välj fil'; end
    
    lastPath = getpref('ModernExplorer', 'LastPath', pwd);
    if nargin < 3 || isempty(startPath), startPath = lastPath; end
    if ~exist(startPath, 'dir'), startPath = pwd; end
    
    % Initialisera returvärden
    file = 0; path = 0; ind = 0;
    currentDir = startPath;
    selectedItem = ''; 

    % --- Skapa GUI ---
    fig = uifigure('Name', title, 'Position', [500 400 750 600], 'WindowStyle', 'modal');
    % Se till att figuren raderas ordentligt vid stängning (kryss-knapp)
    fig.CloseRequestFcn = @(~,~) uiresume(fig);
    
    g = uigridlayout(fig, [5 1]);
    g.RowHeight = {40, 40, '1x', 40, 50};

    % Rad 1: Sökväg och Upp-knapp
    pathGrid = uigridlayout(g, [1 2], 'ColumnWidth', {'1x', 60});
    pathField = uieditfield(pathGrid, 'Value', currentDir, 'Editable', 'off');
    uibutton(pathGrid, 'Text', 'Upp ▲', 'ButtonPushedFcn', @(~,~) navigateUp());

    % Rad 2: Sökfält
    searchField = uieditfield(g, 'Placeholder', 'Sök i aktuell mapp...', ...
        'ValueChangingFcn', @(src,e) updateDisplay(e.Value));

    % Rad 3: Tabell
    fileTable = uitable(g, ...
        'ColumnName', {'', 'Namn', 'Storlek', 'Datum'}, ...
        'ColumnWidth', {30, '1x', 90, 140}, ...
        'RowName', [], ...
        'ColumnSortable', [false true true true], ...
        'SelectionType', 'row');

    % Rad 4: Filter
    filterGrid = uigridlayout(g, [1 2], 'ColumnWidth', {80, '1x'});
    uilabel(filterGrid, 'Text', 'Filtyp:');
    filterDD = uidropdown(filterGrid, ...
        'Items', filter(:,2), ...
        'ItemsData', filter(:,1), ...
        'ValueChangedFcn', @(src,e) updateDisplay()); 

    % Rad 5: Knappar
    btnGrid = uigridlayout(g, [1 3], 'ColumnWidth', {'1x', 100, 100});
    uibutton(btnGrid, 'Text', 'Avbryt', 'ButtonPushedFcn', @(~,~) uiresume(fig));
    openBtn = uibutton(btnGrid, 'Text', 'Öppna', 'FontWeight', 'bold', 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) uiresume(fig));

    % Callbacks för interaktion
    fileTable.CellSelectionCallback = @(src, e) handleSingleClick(e);
    fileTable.DoubleClickedFcn = @(src, e) handleDoubleClick();

    % --- Funktioner ---
    function updateDisplay(searchTerm)
        if nargin < 1, searchTerm = searchField.Value; end
        
        d = dir(currentDir);
        d = d(~strncmp({d.name}, '.', 1)); % Dölj dolda filer
        
        is_dir = [d.isdir];
        folders = d(is_dir);
        files = d(~is_dir);
        
        % --- KORRIGERAD FILTRERING ---
        activeFilter = filterDD.Value;
        if ~isempty(files) % Kör bara om det faktiskt finns filer att filtrera
            if ~any(strcmp(activeFilter, {'*.*', '*'}))
                extList = strsplit(activeFilter, ';');
                matchIdx = false(1, length(files)); % Säkerställ korrekt storlek
                for i = 1:length(extList)
                    pattern = strtrim(extList{i});
                    regStr = regexptranslate('wildcard', pattern);
                    % ignorecase är viktigt för Windows-kompatibilitet
                    matchIdx = matchIdx | ~cellfun(@isempty, regexp({files.name}, regStr, 'once', 'ignorecase'));
                end
                files = files(matchIdx); 
            end
        else
            files = []; % Säkerställ att den är tom om inga filer fanns från början
        end
        % ------------------------------
        
        combined = [folders; files];
        if ~isempty(searchTerm) && ~isempty(combined)
            combined = combined(contains(lower({combined.name}), lower(searchTerm)));
        end
        
        % Bygg data för tabellen
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
        vData = fileTable.Data; % Använd Data istället för DisplayData för högre stabilitet
        row = e.Indices(1);
        if isempty(vData) || row > size(vData, 1), return; end
        
        selectedItem = vData{row, 2};
        if strcmp(vData{row, 1}, '📄')
            openBtn.Enable = 'on';
        else
            openBtn.Enable = 'off';
        end
    end

    function handleDoubleClick()
        % Notera: Selection kan vara tom om man klickar för snabbt
        s = fileTable.Selection;
        if isempty(s), return; end
        
        vData = fileTable.Data;
        row = s(1);
        
        if strcmp(vData{row, 1}, '📁')
            currentDir = fullfile(currentDir, vData{row, 2});
            searchField.Value = '';
            updateDisplay();
        else
            selectedItem = vData{row, 2};
            uiresume(fig);
        end
    end

    function navigateUp()
        p = fileparts(currentDir);
        if ~isempty(p) && ~strcmp(p, currentDir)
            currentDir = p; 
            updateDisplay(); 
        end
    end

    % Starta
    updateDisplay();
    uiwait(fig);

    % Hantera resultat efter uiresume
    if isvalid(fig)
        if ~isempty(selectedItem)
            fullP = fullfile(currentDir, selectedItem);
            if exist(fullP, 'file') && ~exist(fullP, 'dir')
                file = selectedItem; 
                path = [currentDir filesep];
                [~, ind] = ismember(filterDD.Value, filter(:,1));
                setpref('ModernExplorer', 'LastPath', currentDir);
            end
        end
        delete(fig);
    end
end
