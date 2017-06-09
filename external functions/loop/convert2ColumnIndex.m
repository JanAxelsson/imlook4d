function value = convert2ColumnIndex(columnName)
    columnName = upper(columnName);
    value = 0;
    for i = 1 : length(columnName)
        delta = int8(columnName(i)) - 64;
        value = value*26+ delta;
    end