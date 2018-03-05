function [expe, options] = gender_build_conditions(options)

%GENDER_BUILD_CONDITIONS(OPTIONS)
%   Creates the EXPE structure that contains the trials for the PICKA
%   Gender experiment.

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

    % gender_options must be called first

    %----------- Signal options
    options.fs = 44100;
    %if is_test_machine
    %    options.attenuation_dB = 3;  % General attenuation
    %else
        options.attenuation_dB = 27; % General attenuation
    %end
    options.ear = 'both'; % right, left or both

    %----------- Design specification
    options.test.n_repeat = 1; % Number of repetition per condition
    options.test.retry = 1; % Number of retry if measure failed
    

    %  training
    %  added training, maybe for young kids good to see if they understand

    % -------- Stimuli options
    options.test.f0s = [0 -6 -12]; % kids version
    options.test.vtls = [0 1.8 3.6]; % kids version

    nF0 = length(options.test.f0s);
    nVtls = length(options.test.vtls);

    
    switch options.language
        case 'nl_nl'
            options.word_list = {'Bus', 'Leeg', 'Pen', 'Vaak'};
        case 'en_gb'
            options.word_list = {'bike', 'hat', 'pool', 'watch'};
        otherwise
            error('Language must be "nl_nl" or "en_gb", but instead "%s" provided.', options.language);
    end
    
    nWords = length(options.word_list);
    
    % We update the sound folders
    options.sound_path_local = fullfile(options.sound_path, options.language);
    options.tmp_path_local = fullfile(options.tmp_path, options.language);
    
    options.sounds_for_calibration = {};
    lst = dir(fullfile(options.tmp_path_local, '*.wav'));
    for k=1:length(lst)    
        options.sounds_for_calibration{k} = fullfile(options.tmp_path_local, lst(k).name);
    end
    
    options.test.total_ntrials = nWords * nVtls * nF0;
    %{
    %EG: why do we need to know the duration?
    oneSampleFile = fullfile(options.tmp_path, [word_list{1} ...
        sprintf('_GPR%d_VTL%.2f', options.test.f0s(1), options.test.vtls(1)) '.wav']);
    if exist(oneSampleFile, 'file')
        fileinfo = audioinfo(oneSampleFile);  
        options.word_duration = fileinfo.Duration;
    else
        options.word_duration = 850e-3; % PT this is just measured looking 
        % at the lenght of the word bus without silence in the current dataset
    end
    %}
    options.lowpass = 4000;
    options.force_rebuild_sylls = 0;

    % ==================================================== Build test block

    %{
    % EG: it looks like there was here some pseudo-random code to make sure
    % some things are balanced. I'm not sure what it really achieved, and
    % pure random seems to be fine, so switching to this. We only make sure
    % in the for loop that for each voice we have the same number of male
    % and female faces.
    options.test.faces = {'woman_1','woman_2','woman_3','woman_4','woman_5','woman_6','woman_7', ...
      'man_1','man_2','man_3','man_4','man_5','man_6','man_7'};
    nFaces = length(options.test.faces);
    nRepetitions = ceil(options.test.total_ntrials/nFaces);
    nFemales = sum(strncmp(options.test.faces, 'woman', 5));
    nMales = nFaces - nFemales;
    indexes = repmat([1:nFemales], 1, nRepetitions);
    indexes = indexes(randperm(length(indexes)));
    indexes(options.test.total_ntrials/2 + 1 : end) = [];
    indexesM = repmat([(1:nMales) + nFemales], 1, nRepetitions);
    indexesM = indexesM(randperm(length(indexesM)));
    indexesM(options.test.total_ntrials/2 + 1 : end) = [];
    indexes = [indexes indexesM];
    indexes = indexes(randperm(length(indexes)));
    options.test.faces = options.test.faces(indexes);
    %}
    options.test.face_genders = {'man', 'woman'};
    options.test.number_faces = 7; % How many faces do we have per gender
    
    options.test.hands = {'handremote_'};
    %{
    options.test.hands = {'handremote_'}; % + 'handbang_', + 'handknob_%d';
    indexing = repmat ([1:length(options.test.hands)], 1, ...
        length(indexes)/length(options.test.hands));
    indexing = indexing (randperm(length(indexes)));
    options.test.hands = options.test.hands(indexing);
    %}
    
    test = struct();

    %counter = 1;
    for ir = 1 : options.test.n_repeat
        for i_f0 = 1 : nF0 % length(options.test.f0s)
            for i_vtl = 1 : nVtls % length(options.test.vtls)
                i_words = randperm(nWords);
                for i_face_gender = 1:2
                    face_gender = options.test.face_genders{i_face_gender};
                    i_word_start = (i_face_gender-1)*nWords/2+1;
                    for i_word = (1:nWords/2)-1+i_word_start
                        trial = struct();
                        trial.f0 = options.test.f0s(i_f0);
                        trial.vtl = options.test.vtls(i_vtl);
                        trial.word = options.word_list{i_words(i_word)};
                        trial.i_repeat = ir;
                        trial.done = 0;
                        %trial.face = options.test.faces{counter};
                        trial.face = sprintf('%s_%d', face_gender, randi(options.test.number_faces));
                        trial.face_gender = face_gender;
                        trial.hands = options.test.hands{randi(length(options.test.hands))};
                        if ~isfield(test,'trials')
                            test.trials = orderfields(trial);
                        else
                            test.trials(end+1) = orderfields(trial);
                        end
                    end
                end
            end
        end
    end

    % ====================================== Create the expe structure and save

    expe.test.trials = test.trials(randperm(length(test.trials)));
    
    if isfield(options, 'res_filename')
        save(options.res_filename, 'options', 'expe');
    else
        warning('The test file was not saved: no filename provided.');
    end
end

