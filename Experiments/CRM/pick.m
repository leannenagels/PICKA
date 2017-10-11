function [k, i] = pick(lst, n)

if nargin<2
    n = 1;
end

i = randperm(length(lst), n);

if n==1
    if iscell(lst)
        k = lst{i};
    else
        k = lst(i);
    end
else
    k = lst(i);
end