function lst = get_file_list(folder, mask)

if iscell(mask)
    lst = dir(fullfile(folder, mask{1}));
    for i_mask = 2:length(mask)
        lst = [lst; dir(fullfile(folder, mask{i_mask}))];
    end
else
    lst = dir(fullfile(folder, mask));
end