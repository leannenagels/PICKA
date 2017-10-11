% test rms

%folder = './sentences/spk1F-en_gb';
folder = './sentences/spk1F-nl_nl';

lst = dir(fullfile(folder, '*.wav'));

r = zeros(length(lst),1);
rr = zeros(length(lst),1);

for i=1:length(lst)
    x = audioread(fullfile(folder, lst(i).name));
    r(i) = rms(x);
    x = x/max(abs(x));
    rr(i) = rms(x);
end

