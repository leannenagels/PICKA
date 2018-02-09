function fishy_preprocess(language)

options = fishy_options(struct(), struct('language', language, 'age', [], 'sex', '', 'name', ''));
options = rmfield(options, 'res_filename');

[~, options] = fishy_build_conditions(options);

addpath(options.path.straight);

for i=1:length(options.syllables) 
    syll = options.syllables{i};
    
    fprintf('%02d/%02d - %s\n', i, length(options.syllables), syll);
    
    wavIn = fullfile(options.sound_path, [syll, '.wav']);
    mat = strrep(wavIn, '.wav', '.straight.mat');
    
    if ~exist(mat, 'file')
        [x, fs] = audioread(wavIn);
        [f0, ap] = exstraightsource(x, fs);

        sp = exstraightspec(x, f0, fs);
        x_rms = rms(x);

        save(mat, 'fs', 'f0', 'sp', 'ap', 'x_rms');
    end
end

rmpath(options.path.straight);

%[i_correct, player, isi, trial] = fishy_make_stim(options, difference, u, condition)