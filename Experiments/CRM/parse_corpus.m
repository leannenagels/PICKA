function corpus = parse_corpus(folder, filemask)

lst = get_file_list(folder, filemask);

call_signs = {};
colours    = {};
numbers    = [];

for i=1:length(lst)
    [~, filename, ~] = fileparts(lst(i).name);
    parts = strsplit(filename, '_');
    
    call_signs{i} = parts{1};
    colours{i}    = parts{2};
    numbers(i)    = str2num(parts{3});
end

corpus = struct();
corpus.call_signs = unique(call_signs);
corpus.colours    = unique(colours);
corpus.numbers    = unique(numbers);


            