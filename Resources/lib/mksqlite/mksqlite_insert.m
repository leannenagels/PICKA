function mksqlite_insert(db, table, rows)

for j=1:length(rows)
    names = fieldnames(rows(j));
    
    v = {};
    for k=1:length(names)
        f = names{k};
        v{end+1} = ConvertToString(rows(j).(f));
    end
        
    names  = implode(', ', names);
    values = implode(', ', v);
    
    mksqlite(db, sprintf('INSERT INTO %s (%s) VALUES (%s)', table, names, values));
end
    
%-----------------------------------------------------
function s = ConvertToString(data)

% Data is a number
if isnumeric(data) || islogical(data)
    if isempty(data)
        s = 'NULL';
    elseif size(data)~=[1,1]
        error('Matrices or cell arrays are not supported in SQL!');
    else
        if isnan(data) || isinf(data)
            global warning_mksqlite_insert_NaN;
            if isempty(warning_mksqlite_insert_NaN)
                warning('Inf and NaN are converted to NULL');
                warning_mksqlite_insert_NaN = 1;
            end
            s = 'NULL';
        else
            s = num2str(data);
        end
    end
% Data is a string
elseif ischar(data)
    s = sprintf('"%s"', data);
end