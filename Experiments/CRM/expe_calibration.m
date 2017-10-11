options = expe_options();
options.language = 'nl_nl';

addpath(options.path.straight);
addpath(options.path.tools);

[training, test, options] = expe_build_conditions(options);

lst = dir(fullfile(options.target_corpus_path, '*.wav'));

x = [];

for i=1:length(lst)
    [y, fs] = audioread(fullfile(options.target_corpus_path, lst(i).name));
    y = y/rms(y)*options.reference_rms;
    x = [x; y];
end

x = x*10^(options.gain/20);

p = audioplayer(x, fs, 24);
p.play();