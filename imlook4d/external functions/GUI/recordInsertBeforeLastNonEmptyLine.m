 function recordInsertBeforeLastNonEmptyLine(doc, textToInsert)
    % Inserts text before the last non-empty line in a MATLAB editor document

    % Split into lines
    lines = splitlines(doc.Text);

    % Remove trailing empty lines for detection
    idx = find(~cellfun(@isempty, strtrim(lines)), 1, 'last');

    if isempty(idx)
        % If all lines are empty, just insert at the beginning
        doc.Text = textToInsert;
        return;
    end

    % Insert before that line
    lines = [lines(1:idx-1); textToInsert; lines(idx:end)];

    % Rebuild text
    doc.Text = strjoin(lines, newline);
end
