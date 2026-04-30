function outputPath = uigetdir_modern(guessedDirectory, dialogTitle)
    % UIGETDIR_MODERN Modern directory picker without Java
    % Keyboard: Return/Enter is used ONLY for navigation, never for final selection.

    % --- Setup ---
    if nargin < 1 || isempty(guessedDirectory), guessedDirectory = pwd; end
    if nargin < 2 || isempty(dialogTitle), dialogTitle = 'Select Folder'; end
    if ~exist(guessedDirectory, 'dir'), guessedDirectory = pwd; end
    
    outputPath = 0;
    currentDir = guessedDirectory;
    combined = []; 

    % --- GUI Creation ---
    fig = uifigure('Name', dialogTitle, 'Position', [500 400 750 650], 'WindowStyle', 'modal');
    fig.CloseRequestFcn = @(~,~) cleanClose();
    
    % Keyboard Shortcuts
    fig.WindowKeyPressFcn = @(src, e) handleKeyPress(e);
    
    % --- OS and Theme-aware Icon Setup ---
    imgDir = fullfile(fileparts(mfilename('fullpath')), 'images');
    % Robust detection based on background color
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

    % Row 1: Path Navigation
    pathGrid = uigridlayout(g, [1 3], 'ColumnWidth', {'1x', 60, 100});
    pathField = uieditfield(pathGrid, 'Value', currentDir, 'Editable', 'on', ...
        'ValueChangedFcn', @(src,e) manualPathEdit(src.Value));
    uibutton(pathGrid, 'Text', 'Up ▲', 'ButtonPushedFcn', @(~,~) navigateUp());
    uibutton(pathGrid, 'Text', 'New Folder', 'ButtonPushedFcn', @(~,~) makeNewFolder());

    % Row 2: Search
    searchField = uieditfield(g, 'Placeholder', 'Search...', ...
        'ValueChangingFcn', @(src,e) updateDisplay(e.Value));

    % Row 3: Table
    folderTable = uitable(g, 'ColumnName', {'', 'Name', 'Size', 'Date'}, ...
        'ColumnWidth', {35, '1x', 90, 140}, 'RowName', [], 'ColumnSortable', true, 'SelectionType', 'row');

    % Row 4: Toggle Files
    showFilesCB = uicheckbox(g, 'Text', 'Show files', 'Value', false, ...
        'ValueChangedFcn', @(~,~) updateDisplay());

    % Row 5: Action Buttons
    btnGrid = uigridlayout(g, [1 3], 'ColumnWidth', {'1x', 100, 100});
    uibutton(btnGrid, 'Text', 'Cancel', 'ButtonPushedFcn', @(~,~) cleanClose());
    selectBtn = uibutton(btnGrid, 'Text', 'Select Folder', 'FontWeight', 'bold', ...
        'ButtonPushedFcn', @(~,~) finalizeSelection());

    folderTable.DoubleClickedFcn = @(src, e) handleDoubleClick();

    % --- Functions ---
    
    function handleKeyPress(e)
        focusedObj = fig.CurrentObject;
        switch e.Key
            case 'return'
                % ENTER only navigates, never closes the dialog
                if isequal(focusedObj, pathField)
                    manualPathEdit(pathField.Value);
                elseif isequal(focusedObj, folderTable)
                    handleDoubleClick();
                end
            case 'escape'
                cleanClose();
        end
    end

    function manualPathEdit(newPath)
        if exist(newPath, 'dir')
            currentDir = newPath;
            searchField.Value = '';
            updateDisplay();
        end
    end

    function makeNewFolder()
        newName = inputdlg('Folder name:', 'New Folder', [1 50], {'New Folder'});
        if isempty(newName), return; end
        newP = fullfile(currentDir, newName{1});
        if exist(newP, 'dir'), uialert(fig, 'Exists.', 'Error');
        else, [s, m] = mkdir(newP); if s, currentDir = newP; updateDisplay(); else, uialert(fig, m, 'Error'); end; end
    end

    function updateDisplay(searchTerm)
        if nargin < 1, searchTerm = searchField.Value; end
        if ~exist(currentDir, 'dir'), return; end
        
        d = dir(currentDir);
        d = d(~strncmp({d.name}, '.', 1)); 
        if ~showFilesCB.Value, d = d([d.isdir]); end
        
        folders = d([d.isdir]); 
        files = d(~[d.isdir]);
        combined = [folders; files];
        
        if ~isempty(searchTerm) && ~isempty(combined)
            combined = combined(contains(lower({combined.name}), lower(searchTerm)));
        end
        
        folderTable.Data = {}; removeStyle(folderTable);
        pathField.Value = currentDir;
        if isempty(combined), return; end
        
        data = cell(length(combined), 4);
        for i = 1:length(combined)
            data{i,2} = combined(i).name; data{i,4} = combined(i).date;
            if combined(i).isdir
                data{i,1} = ''; data{i,3} = '--';
                if ~isempty(s_folder), addStyle(folderTable, s_folder, 'cell', [i, 1]); else, data{i,1} = '📁'; end
            else
                data{i,1} = ''; data{i,3} = sprintf('%.1f KB', combined(i).bytes/1024);
                if ~isempty(s_file), addStyle(folderTable, s_file, 'cell', [i, 1]); else, data{i,1} = '📄'; end
                addStyle(folderTable, s_grey, 'row', i);
            end
        end
        folderTable.Data = data;
    end

    function handleDoubleClick()
        s = folderTable.Selection; if isempty(s), return; end
        row = s(1);
        if combined(row).isdir
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
        enteredPath = pathField.Value;
        
        % If a subfolder is selected in the table, use that
        s = folderTable.Selection;
        if ~isempty(s)
            row = s(1);
            if combined(row).isdir
                enteredPath = fullfile(currentDir, combined(row).name);
            end
        end

        % Existence check
        if ~exist(enteredPath, 'dir')
            choice = uiconfirm(fig, sprintf('Folder does not exist:\n%s\n\nCreate it?', enteredPath), ...
                'Create Folder?', 'Options', {'Yes', 'No'}, 'DefaultOption', 'Yes');
            if strcmp(choice, 'Yes')
                [status, msg] = mkdir(enteredPath);
                if ~status, uialert(fig, msg, 'Error'); return; end
            else, return; end
        end
        
        outputPath = enteredPath;
        uiresume(fig);
    end

    function cleanClose()
        outputPath = 0;
        uiresume(fig);
    end

    updateDisplay();
    uiwait(fig);
    if isvalid(fig), delete(fig); end
end
