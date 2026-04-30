function outputPath = uigetdir_modern(guessedDirectory, dialogTitle)
    % UIGETDIR_MODERN - High-stability version to prevent MATLAB hangs
    
    % --- Initial Setup ---
    if nargin < 1 || isempty(guessedDirectory), guessedDirectory = pwd; end
    if nargin < 2 || isempty(dialogTitle), dialogTitle = 'Select Folder'; end
    if ~exist(guessedDirectory, 'dir'), guessedDirectory = pwd; end
    
    outputPath = 0;
    currentDir = guessedDirectory;
    combined = []; 

    % --- GUI Figure with Failsafe ---
    fig = uifigure('Name', dialogTitle, 'Position', [500 400 750 650], ...
        'WindowStyle', 'modal', ...
        'Visible', 'off'); % Create hidden, show when ready
    
    % CRITICAL: Always resume and delete properly
    fig.CloseRequestFcn = @(~,~) cleanClose();
    fig.WindowKeyPressFcn = @(src, e) handleKeyPress(e);
    
    % --- OS and Theme-aware Icon Setup ---
    imgDir = fullfile(fileparts(mfilename('fullpath')), 'images');
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
    s_grey = uistyle('FontColor', [0.5 0.5 0.5]);

    % --- Layout ---
    g = uigridlayout(fig, [5 1]);
    g.RowHeight = {40, 40, '1x', 40, 50};

    % Navigation
    pathGrid = uigridlayout(g, [1 3], 'ColumnWidth', {'1x', 60, 100});
    pathField = uieditfield(pathGrid, 'Value', currentDir, 'Editable', 'on', ...
        'ValueChangedFcn', @(src,e) manualPathEdit(src.Value));
    uibutton(pathGrid, 'Text', 'Up ▲', 'ButtonPushedFcn', @(~,~) navigateUp());
    uibutton(pathGrid, 'Text', 'New Folder', 'ButtonPushedFcn', @(~,~) makeNewFolder());

    % Search
    searchField = uieditfield(g, 'Placeholder', 'Search...', ...
        'ValueChangingFcn', @(src,e) updateDisplay(e.Value));

    % Table
    folderTable = uitable(g, 'ColumnName', {'', 'Name', 'Size', 'Date'}, ...
        'ColumnWidth', {35, '1x', 90, 140}, 'RowName', [], 'SelectionType', 'row', ...
        'BusyAction', 'cancel', 'Interruptible', 'off'); % Prevent callback pile-up
    folderTable.DoubleClickedFcn = @(src, e) handleDoubleClick();

    showFilesCB = uicheckbox(g, 'Text', 'Show files', 'Value', false, ...
        'ValueChangedFcn', @(~,~) updateDisplay());

    % Actions
    btnGrid = uigridlayout(g, [1 3], 'ColumnWidth', {'1x', 100, 100});
    uibutton(btnGrid, 'Text', 'Cancel', 'ButtonPushedFcn', @(~,~) cleanClose());
    uibutton(btnGrid, 'Text', 'Select Folder', 'FontWeight', 'bold', ...
        'ButtonPushedFcn', @(~,~) finalizeSelection());

    % --- Protected Internal Functions ---

    function handleKeyPress(e)
        if ~isvalid(fig), return; end
        if strcmp(e.Key, 'escape'), cleanClose(); end
        if strcmp(e.Key, 'return')
            if isequal(fig.CurrentObject, pathField), manualPathEdit(pathField.Value); end
            % Enter does NOT finalize selection per your preference
        end
    end

    function manualPathEdit(newPath)
        if exist(newPath, 'dir')
            currentDir = newPath; 
            updateDisplay();
        end
    end

    function updateDisplay(searchTerm)
        if ~isvalid(fig), return; end
        try
            if nargin < 1, searchTerm = searchField.Value; end
            d = dir(currentDir);
            d = d(~strncmp({d.name}, '.', 1)); 
            if ~showFilesCB.Value, d = d([d.isdir]); end
            
            folders = d([d.isdir]); files = d(~[d.isdir]);
            combined = [folders; files];
            if ~isempty(searchTerm) && ~isempty(combined)
                combined = combined(contains(lower({combined.name}), lower(searchTerm)));
            end
            
            % Update UI
            folderTable.Data = {}; 
            removeStyle(folderTable);
            pathField.Value = currentDir;
            
            data = cell(length(combined), 4);
            for i = 1:length(combined)
                data{i,2} = combined(i).name; data{i,4} = combined(i).date;
                if combined(i).isdir
                    data{i,1} = ''; data{i,3} = '--';
                    if ~isempty(s_folder), addStyle(folderTable, s_folder, 'cell', [i, 1]); end
                else
                    data{i,1} = ''; data{i,3} = sprintf('%.1f KB', combined(i).bytes/1024);
                    if ~isempty(s_file), addStyle(folderTable, s_file, 'cell', [i, 1]); end
                    addStyle(folderTable, s_grey, 'row', i);
                end
            end
            folderTable.Data = data;
        catch ME
            fprintf('UI Update Error: %s\n', ME.message);
        end
    end

    function handleDoubleClick()
        if ~isvalid(fig), return; end
        s = folderTable.Selection;
        if isempty(s), return; end
        row = s(1);
        if row <= length(combined) && combined(row).isdir
            currentDir = fullfile(currentDir, combined(row).name);
            searchField.Value = '';
            updateDisplay();
        end
    end

    function navigateUp()
        p = fileparts(currentDir); 
        if ~isempty(p) && ~strcmp(p, currentDir), currentDir = p; updateDisplay(); end
    end

    function finalizeSelection()
        if ~isvalid(fig), return; end
        target = pathField.Value;
        s = folderTable.Selection;
        if ~isempty(s) && s(1) <= length(combined) && combined(s(1)).isdir
            target = fullfile(currentDir, combined(s(1)).name);
        end

        if ~exist(target, 'dir')
            choice = uiconfirm(fig, 'Create new folder?', 'Confirm', 'Options', {'Yes', 'No'});
            if strcmp(choice, 'Yes'), mkdir(target); else, return; end
        end
        outputPath = target;
        uiresume(fig);
    end

    function cleanClose()
        outputPath = 0;
        if isvalid(fig), uiresume(fig); end
    end

    % --- Start ---
    updateDisplay();
    fig.Visible = 'on';
    uiwait(fig);

    % --- Final Failsafe ---
    if isvalid(fig), delete(fig); end
end
