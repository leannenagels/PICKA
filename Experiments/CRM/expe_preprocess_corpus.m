function expe_preprocess_corpus(mode, language, force)

if nargin<1
    mode = 2;
end

if nargin<2
    language = 'nl_nl';
end

if nargin<3
    force = false;
end

switch mode
    case 'analysis'
        mode = 1;
    case 'all'
        mode = 2;
end

options = struct();
options.language = language;
options = expe_options(options);
[expe, options] = expe_build_conditions(options);

options.force_rebuild_straight_output = force;

% ----- Preprocess analysis for all maskers

fprintf('==== Analysing all masker files ====\n');

for i=1:length(options.masker_corpus)
    fname = options.masker_corpus{i};
    fname = fullfile(options.masker_corpus_path, fname);
    fprintf('%02d/%d Analysing "%s"...\n', i, length(options.masker_corpus), fname);
    tic();
    straight_process(fname, NaN, NaN, options);
    t = toc();
    fprintf('   Done in %.2f s\n', t);
end

% ------ Synthesize the necessary voices

if mode>=2

    fprintf('==== Synthesizing for all masker files ====\n');

    trials = [expe.training.trials, expe.test.trials];
    k = 1;

    for i=1:length(trials)

        trial = trials(i);
        disp(trial.voice);

        for j=1:length(options.masker_corpus)
            fname = options.masker_corpus{j};
            fname = fullfile(options.masker_corpus_path, fname);
            fprintf('%04d/%d Synthesizing "%s" for dF0=%.2f st, dVTL=%.2f st...\n', k, length(trials)*length(options.masker_corpus), fname, trial.voice.dF0, trial.voice.dVTL);
            tic();
            straight_process(fname, trial.voice.dF0, trial.voice.dVTL, options);
            t = toc();
            fprintf('   Done in %.2f s\n', t);

            k = k+1;
        end

        fprintf('\n');
    end


end