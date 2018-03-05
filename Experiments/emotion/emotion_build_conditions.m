function [expe, options] = emotion_build_conditions(options)

%EMOTION_BUILD_CONDITIONS(OPTIONS)
%   Creates the EXPE structure that contains the trials for the PICKA
%   Emotion experiment.
%
%   Note: the emotion names listed in options.test.emotions must coincide
%   with the file names of the sound material, as well as with the file
%   names of the sprite images.

%-------------------------------------------------------------------------
% Initial version by:
% Paolo Toffanin <p.toffanin@umcg.nl>, RuG, UMCG, Groningen, NL
%-----------------------
% Other contributors:
%   Jacqueline Libert
%   Leanne Nagels <leanne.nagels@rug.nl>
%-----------------------
% This version modified by:
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2017-12-05
% CNRS, CRNL, Lyon, FR | RuG, UMCG, Groningen, NL
%-------------------------------------------------------------------------

%~~~~~~~~~~~~~~~~~~~~
% TODO:
%   - The ladder clowns are not playing so nicely in this simplified
%   version. There might be an easy way to align the clown's beheaviour to
%   the number of trials.
%~~~~~~~~~~~~~~~~~~~~

if nargin<1
    options = emotion_options();
end

options.sound_folder = '../../Resources/sounds/emotion';
options.sound_filemask = '*.wav'; % The training files will have to be excluded for the test

% We parse the corpus
options = parse_corpus(options);

% We selection the emotions we will test
options.test.emotions = {'angry', 'sad', 'happy'};
options.order_button_emotions = randperm(length(options.test.emotions));
options.clickParrot2continue = true;

% We check we have the right corpus for them
for e=1:length(options.test.emotions)
    if ~isfield(options.test.corpus, options.test.emotions{e})
        error('Emotion "%s" was not found in the selected corpus...', options.test.emotions{e});
    end
end

options.test.n_repeat = Inf; % Number of repetition per emotion, Inf means use all available stimuli


%---------------------------------------------------------
% We create the test trials

test = struct();

for i_emotion = 1:length(options.test.emotions)
    emotion = options.test.emotions{i_emotion};
    n = length(options.test.corpus.(emotion));
    if isinf(options.test.n_repeat)
        item_order = 1:n;
    else
        item_order = [];
        while length(item_order)<options.test.n_repeat
            item_order = [item_order, randperm(min(options.test.n_repeat, n))];
        end
    end
    for ir = 1:min(options.test.n_repeat, length(item_order))
        %trial = struct();
        trial = options.test.corpus.(emotion)(item_order(ir));
        trial.emotion = emotion;
        
        trial.i_repeat = ir;
        trial.done = 0;
        
        if ~isfield(test,'trials')
            test.trials = orderfields(trial);
        else
            test.trials(end+1) = orderfields(trial);
        end
    end
end

expe.test.trials = test.trials(randperm(length(test.trials)));

 
%---------------------------------------------------------
% We create the training trials

training = struct();

for i_trial = 1:length(options.training.corpus)
    %trial = struct();
    trial = options.training.corpus(i_trial);

    trial.done = 0;

    if ~isfield(training,'trials')
        training.trials = orderfields(trial);
    else
        training.trials(end+1) = orderfields(trial);
    end
end

expe.training.trials = training.trials(randperm(length(training.trials)));

if isfield(options, 'res_filename')
    save(options.res_filename, 'options', 'expe');
else
    warning('The test file was not saved: no filename provided.');
end


%======================================================================================
function options = parse_corpus(options)

% Parse the corpus file names to extract informations like talker and
% utterance. We also fill the 'sounds_for_calibration' used for
% calibration.

options.sounds_for_calibration = {};

if ~isfield(options, 'test')
    options.test = struct();
end

if ~isfield(options, 'training')
    options.training = struct();
end

options.test.corpus = struct();
lst = dir(fullfile(options.sound_folder, options.sound_filemask));
for k=1:length(lst)
    
    options.sounds_for_calibration{k} = fullfile(options.sound_folder, lst(k).name);
    
    [~, fname] = fileparts(lst(k).name);
    tokens = explode('_', fname);
    if strcmp(tokens{1}, 'training')
        item = struct();
        item.file = lst(k).name;
        item.talker = str2num(tokens{2}(2:end));
        item.emotion = tokens{3};
        item.sentence = str2num(tokens{4}(2:end));
        item.utterance = str2num(tokens{5}(2:end));
        if ~isfield(options.training, 'corpus')
            options.training.corpus = orderfields(item);
        else
            options.training.corpus(end+1) = orderfields(item);
        end
    else
        item = struct();
        item.file = lst(k).name;
        item.talker = str2num(tokens{1}(2:end));
        emotion = tokens{2};
        item.sentence = str2num(tokens{3}(2:end));
        item.utterance = str2num(tokens{4}(2:end));
        if ~isfield(options.test.corpus, emotion)
            options.test.corpus.(emotion) = orderfields(item);
        else
            options.test.corpus.(emotion)(end+1) = orderfields(item);
        end
    end
end

