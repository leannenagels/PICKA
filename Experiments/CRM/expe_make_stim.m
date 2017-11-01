function [z, fs, info] = expe_make_stim(options, trial, is_demo)

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@mrc-cbu.cam.ac.uk> - 2010-03-16
% Medical Research Council, Cognition and Brain Sciences Unit, UK
%
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2017-08-06
% CNRS UMR 5292, FR | University of Groningen, UMCG, NL
%--------------------------------------------------------------------------

if nargin<3
    is_demo = false;
end

tmr_strategy = options.tmr_strategy;

%-------------------------------------
% Target Sentence
fprintf('Reading soundfile "%s" as target...\n', trial.target.soundfile);
[x, fs] = audioread(fullfile(options.target_corpus_path, trial.target.soundfile));

if fs~=options.fs
    x = resample(x, options.fs, fs);
    fs = options.fs;
end

switch tmr_strategy
    case 'louder_constant'
        if trial.tmr >=0
            x = x / rms(x);
        else
            x = x / rms(x) * 10^(trial.tmr/20);
        end

    case 'constant_level'
        x = x / rms(x) * 10^(trial.tmr/20);
end


target = [zeros(round(options.target_delay*fs),1); x; zeros(round(options.masker_end_delay*fs),1)];

%-------------------------------------
% Masker Sentence
[masker, masker_struct] = create_masker(options, trial, length(target));

switch tmr_strategy
    case 'louder_constant'
        if trial.tmr >=0
            masker = masker / rms(masker) * 10^(-trial.tmr/20);
        else
            masker = masker / rms(masker);
        end
    case 'constant_level'
        masker = masker / rms(masker);
end

%-------------------------------------
% Mix Target and Masker

z = target + masker;

switch tmr_strategy
    case 'constant_level'
        z = z/rms(z);
end

info.masker = masker_struct();



%===============================================================
function [masker, masker_struct] = create_masker(options, trial, n_samples)
 
% Take random pieces of masker sentences and stitch them together.

fs = options.fs;    

%Randomize sentences:

masker_struct = struct();
masker = [];
n_chunk = 1;

while length(masker) < n_samples
    %Pick a random sentence from the masker sentence_bank:
    soundfile = pick(options.masker_corpus, 1);

    % We check if the colour or number are in the selected sentence. If so we skip it.
    if ~isempty(strfind(soundfile, ['_', trial.target.colour])) || ~isempty(strfind(soundfile, sprintf('_%d', trial.target.number)))
        continue
    end

    masker_struct(n_chunk).soundfile = soundfile;

    [y, fs] = straight_process(fullfile(options.masker_corpus_path, soundfile), trial.voice.dF0, trial.voice.dVTL, options);

    % Take chunk sizes that are at least 1 sec long
    chunk_duration = rand()*(options.masker_max_chunk_duration-options.masker_min_chunk_duration) + options.masker_min_chunk_duration;
    chunk_duration = round(chunk_duration*fs);

    % Start the chunk at a random location in the file: 
    chunk_start = randi(length(y) - chunk_duration);

    chunk_ind = chunk_start + [0, chunk_duration-1];
    masker_struct(n_chunk).chunk_indices = chunk_ind;

    chunk = y(chunk_ind(1):chunk_ind(2));

    %Apply cosine ramp:
    chunk = cosgate(chunk, fs, options.masker_chunk_ramp);

    masker = [masker; chunk];

    n_chunk = n_chunk+1;

end


masker = masker(1:n_samples);
masker = cosgate(masker, fs, options.masker_ramp);

    

