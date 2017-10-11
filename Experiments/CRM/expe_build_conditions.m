function [training, test, options] = expe_build_conditions(options)

% Setups all conditions that will be tested in the experiment

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@mrc-cbu.cam.ac.uk> - 2010-03-15
% Medical Research Council, Cognition and Brain Sciences Unit, UK
%
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2017-08-06, 2017-10-04
% CNRS UMR 5292, FR | University of Groningen, UMCG, NL
%--------------------------------------------------------------------------

options.fs = 44100;

% Target corpus
options.target_corpus_language = options.language; % options.language must have been normalized (e.g., nl_nl)
options.target_corpus_path = ['../../Resources/sounds/CRM/spk1F-', options.target_corpus_language];
options.target_corpus_filemask = 'dog_*.wav';
% To only use certain colours, use something like:
% options.target_corpus_filemask = {'dog_yellow_*.wav', 'dog_black_*.wav'};

options.target_corpus = parse_corpus(options.target_corpus_path, options.target_corpus_filemask);

options.n_colours    = length(options.target_corpus.colours);
options.n_numbers    = length(options.target_corpus.numbers);
options.n_call_signs = length(options.target_corpus.call_signs);

% We randomize the order so that the colours are shuffled differently for
% each subject
options.target_corpus.colours = options.target_corpus.colours(randperm(options.n_colours));

options.image_path = '../../Resources/images/CRM';
options.images = {'woman+dog.jpg'};

% Masker corpus
options.masker_corpus_language = options.language;
options.masker_corpus_path = options.target_corpus_path;
options.masker_corpus_filemask = 'cat_*.wav';

lst = get_file_list(options.masker_corpus_path, options.masker_corpus_filemask);
options.masker_corpus = {lst(:).name};

options.cache_path = '../../Resources/tmp/CRM';

options.voices = struct(); % Voices are defined as difference in F0 and VTL semitones re. target
i = 1;
for dF0 = linspace(0, -12, 3)
    for dVTL = linspace(0, 3.8, 3)
        options.voices(i).dF0  = dF0;
        options.voices(i).dVTL = dVTL;
        i = i+1;
    end
end

options.n_voices = length(options.voices);

% The smallest RMS of normalized en_gb corpus is 0.0823
% The smallest RMS of normalized nl_nl corpus is 0.0856
% We chose as reference RMS 0.0823/sqrt(2) so that Target and Masker can be
% added at 0 dB TMR without clipping

options.reference_rms = 0.0823/sqrt(2);
% For TMR>0, this is the RMS of the target
% For TMR<0, this is the RMS of the masker

% The gain needs to be adjusted for calibration
% What is adjusted is the reference RMS
options.gain = -21+1.2; % Calibrated to 65 dB SPL for Sennheiser HD600, with KEMAR head assembly + Svantek SLM on 07/08/2017

options.tmrs = [-5, 0, 5];
options.target_delay = 750e-3;
options.masker_end_delay = 250e-3;
options.masker_min_chunk_duration = 250e-3;
options.masker_max_chunk_duration = 500e-3;
options.masker_chunk_ramp = 2e-3;
options.masker_ramp = 50e-3;

options.test.n_repeat = 7;
options.training.n_repeat = 1;

%change block size for breaks
options.training.block_size = 20;
options.test.block_size = 20;

%options.ear = 'both';

%------ Testing block

test = struct();

for i_repeat = 1:options.test.n_repeat
    for i_voice = [1, 3, 7, 9]
        for i_tmr = 1:length(options.tmrs)
    
            trial = struct();

            [trial.target.colour, trial.target.colour_index] = pick(options.target_corpus.colours);
            [trial.target.number, trial.target.number_index] = pick(options.target_corpus.numbers);
            trial.target.call_sign = 'dog';
            trial.target.soundfile = sprintf('%s_%s_%d.wav', trial.target.call_sign, trial.target.colour, trial.target.number);
            
            trial.image = options.images{1};

            trial.voice = options.voices(i_voice);
            trial.voice.index = i_voice;


            trial.i_repeat = i_repeat;
            trial.tmr = options.tmrs(i_tmr);

            trial.visual_feedback = 0;

            trial.done = 0;

            if ~isfield(test,'trials')
                test.trials = orderfields(trial);
            else
                test.trials(end+1) = orderfields(trial);
            end
        end
    end
end

test.trials = test.trials(randperm(length(test.trials)));

%------ Training block

training = struct();

i = 1;
for i_repeat = 1:options.training.n_repeat
    for i_voice = 1:options.n_voices

        trial = struct();

        [trial.target.colour, trial.target.colour_index] = pick(options.target_corpus.colours);
        [trial.target.number, trial.target.number_index] = pick(options.target_corpus.numbers);
        trial.target.call_sign = 'dog';
        trial.target.soundfile = sprintf('%s_%s_%d.wav', trial.target.call_sign, trial.target.colour, trial.target.number);

        trial.voice = options.voices(i_voice);
        trial.voice.index = i_voice;

        trial.image = options.images{1};

        trial.i_repeat = i_repeat;
        if i<=3
            trial.tmr = Inf;
        else
            trial.tmr = 6;
        end

        trial.visual_feedback = 0;

        trial.done = 0;
        
        i = i+1;

        if ~isfield(training,'trials')
            training.trials = orderfields(trial);
        else
            training.trials(end+1) = orderfields(trial);
        end
    end
end

% We keep the trials in the same order
%training.trials = training.trials(randperm(length(training.trials)));

%-----------------------------

expe.test = test;
expe.training = training;
                
if isfield(options, 'res_filename')
    save(options.res_filename, 'options', 'expe');
else
    warning('The test file was not saved: no filename provided.');
end

