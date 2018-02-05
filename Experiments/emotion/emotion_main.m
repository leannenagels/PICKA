function emotion_main(options, phase)

%EMOTION_MAIN(OPTIONS, PHASE)
%   The main loop that goes through the trials for the PICKA Emotion
%   experiment.
%   
%   OPTIONS needs to have been generated in EMOTION_RUN to point to a valid
%   test file.

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

    rng('shuffle')
    
    simulateSubj = false;
    if strcmp(options.subject_name, 'test')
        simulateSubj = true;
    end
    
    % Update Matlab's path
    paths2Add = {options.path.spritekit, options.path.tools};
    for ipath = 1 : length(paths2Add)
        if ~exist(paths2Add{ipath}, 'dir')
            error('"%s" does not exist, check the emotion_options.m', paths2Add{ipath});
        else
            addpath(paths2Add{ipath});
        end
    end
    
    % Create the result structure and load the subject's results/options file
    results = struct();
    load(options.res_filename);
    
    %{
    % EG: don't know what this is doing, but because we changed the
    % structure of the experiment, this is probably not needed anymore.
    
    % emotion_checkOptions
     [attempt, expe, options, results, cue] = emotion_checkOptions(options, phase, cue);
%    [attempt, expe, options, results, cue] = emotion_checkOptions_Debi(options, phase, cue);
    if isempty(attempt) && isempty(expe) && isempty(options) && isempty(results)
        return
    end
    
    % make sure there is a soundDir
    if ~exist(options.soundDir, 'dir')
        error(['Sounds folder ' options.soundDir ' does not exists']);
    end
    if isempty(dir([options.soundDir '*.wav']))
        error([options.soundDir ' does not contain sound files']);
    end
    %}
    
    % ! Should this be changed? Set volume level
    %volume = SoundVolume(.44);
    % SOME CALIBRATION/ATTENUATION 
    %
    %fprintf('stimuli displayed at %f of the volume\n', volume);
    
    %% Game Stuff 
    [G, Buttons, gameCommands, Confetti, Parrot, Pool, ...
        Clownladder, Splash, ladder_jump11, clown_jump11, Drops, ExtraClown] = emotion_game(options); 
    G.onMouseRelease = @buttonupfcn;
    G.onMousePress   = @buttondownfcn;
    %G.onKeyPress = @keypressfcn;
    
    
    % Calibration & sound level
    if ~isfield(options, 'gain')
        if ~exist('emotion_gain.m', 'file')
            warndlg({'Calibration was not performed!',...
                'We are using a gain of 0.0 dB for now...'}, 'PICKA :: Emotion', 'modal');
            options.gain = 0;
        else
            options.gain = emotion_gain();
        end
    end
    check_sound_volume_warning(options.subject_name);
    
    
    %{
    % figure out how to make sure they are NEW random number every time
    % classify emotion soundFiles
    emotionvoices = classifyFiles(options.soundDir, phase);
    % randomize training files
    tmp = emotionvoices(strcmp({emotionvoices.phase}, 'training'));
    tmp = tmp(randperm(length(tmp)));
    % randomize test files
    tmp1 = emotionvoices(strcmp({emotionvoices.phase}, 'test'));
    tmp1 = tmp1(randperm(length(tmp1)));
    % merge randomized training and test files
    emotionvoices = [tmp; tmp1]; %;
%     nFile = length (emotionvoices);
%         for iFile = 1 : nFile
%             if strcmp(phase, 'training')
%             emotionvoices = emotionvoices(strcmp({emotionvoices.phase}, 'training'));
% %             emotionvoices = tmp(randperm(length(tmp)));
%             else
%             emotionvoices = emotionvoices(strcmp({emotionvoices.phase}, 'test'));
% %             emotionvoices = tmp1(randperm(length(tmp1)));
%             end
%         end    
    %}
    
    
    %% ============= Main loop =============   
    ladderStep = 1;
    starting = 0;
    % We keep going while there are some undone trials
    while any([expe.( phase ).trials.done]~=1)
        if ~simulateSubj
            while starting == 0
                uiwait();
            end
        else
            gameCommands.State = 'empty';
        end
        
        itrial = find([expe.( phase ).trials.done]==0, 1, 'first');
        trial = expe.(phase).trials(itrial);
                
        if itrial == 1
            % for training no pool or clowns
            switch phase
                case 'training'
                    Clownladder.State = 'empty';
                    ExtraClown.State = 'empty';
                    Pool.State = 'empty'; 
                case 'test'
                    Clownladder.State = 'ground';
                    Pool.State = 'pool'; 
                    ExtraClown.State = 'on';
            end
            Confetti.State = 'off';
        end      
        
        % activate buttons
        for ib = 1:length(Buttons)
            Buttons{ib}.State = 'on';
        end
%         ButtonJoy.State = 'on';
%         ButtonSad.State = 'on';
%         ButtonAngry.State = 'on';
        Parrot.State = 'neutral';
        pause(1);
           
        Parrot.State = 'parrot_1';
        pause(0.5)

%         emotionVect = strcmp({emotionvoices.emotion}, expe.(phase).condition(itrial).voicelabel);
%         phaseVect = strcmp({emotionvoices.phase}, phase);
%         possibleFiles = [emotionVect & phaseVect];
%         indexes = 1:length(possibleFiles);
%         indexes = indexes(possibleFiles);
%         
%         if isempty(emotionvoices(indexes)) % extend structure with missing files and redo selection
%             nLeft = length(emotionvoices);
%             tmp = classifyFiles(options.soundDir, phase);
%             emotionvoices(nLeft + 1 : nLeft + length(tmp)) = tmp;
%             clear tmp
%             emotionVect = strcmp({emotionvoices.emotion}, expe.(phase).condition(itrial).voicelabel);
%             phaseVect = strcmp({emotionvoices.phase}, phase);
%             possibleFiles = [emotionVect & phaseVect];
%             indexes = 1:length(possibleFiles);
%             indexes = indexes(possibleFiles);
%         end
    
        %this should store all names of possibleFiles 
%         toPlay = randperm(length(emotionvoices(indexes)),1);
        %[y, Fs] = audioread([options.soundDir emotionvoices(itrial).name]);
        [y, Fs] = audioread(fullfile(options.sound_folder, trial.file));
        player = audioplayer(y, Fs);
        iter = 1;
        play(player)
        tic();       
        
        % parrot talks while soundFile is playing
        while true
            Parrot.State = ['parrot_' sprintf('%i', mod(iter, 2) + 1)];
            iter = iter + 1;
            pause(0.1);
            if ~isplaying(player)
                Parrot.State = 'neutral';
                break;
            end
        end   
%         for ib = 1:length(Buttons)
%             Buttons{ib}.State = 'on';
%         end
        
        if ~simulateSubj
            uiwait();
            pause(0.2);
            for ib = 1:length(Buttons)
                Buttons{ib}.State = 'off';
            end        
        else
            response.timestamp = now();
            response.response_time = toc();
            response.emotion = options.(phase).emotions{randi(length(options.(phase).emotions))};
            response.correct = strcmp(response.emotion, trial.emotion);
        end
           
       % correctness       
       response.trial = trial;
       response.correct = strcmp(response.emotion, trial.emotion);
       
       % confetti if correct and shake if incorrect
       if response.correct == 1
            for confettiState = 1:7
                Confetti.State = sprintf('confetti_%d', confettiState);
                pause(0.2)
            end
            Confetti.State = 'off';
            pause(0.3)
        else
            for shakeshake = 1:2
                for parrotshake = 1:3
                    Parrot.State = sprintf('parrot_shake_%d', parrotshake);
                    pause(0.1)
                end
            end
        end % if response.correct
    
        fprintf('Clicked button: %s\n', response.emotion);
        fprintf('Response time : %d ms\n', round(response.response_time*1000));
        fprintf('Response correct: %d\n\n', response.correct);
        
        expe.(phase).trials(itrial).done = 1;
        
        results.(phase).responses(itrial) = response;
        %if strcmp(phase, 'test')
        %    results.(phase).responses(itrial) = response;
        %elseif strcmp(phase, 'training')
        %    results.(phase).responses(itrial) = response;
        %end
            
        save(options.res_filename, 'options', 'expe', 'results');
        
        % clownladder state
        % We make the clown move up the ladder every trial, until it has
        % reached the top (clownladder_7b)
        if strcmp(phase, 'test')
            nStep = [2, 5, 8, 10, 13, 16, 18, 20, 23, 26, 28, 31, 34, 36];
            if ismember(itrial,nStep)==1
                Clownladder.State = sprintf('clownladder_%d%c', ladderStep,'a');
                pause (0.2)
                Clownladder.State = sprintf('clownladder_%d%c', ladderStep,'b');
                pause (0.2)
                ladderStep = ladderStep + 1;
            end
            if strcmp(Clownladder.State, 'clownladder_7b')
                % The clown is that the top of the ladder, time to jump!
                for ijump = 1:10
                    Clownladder.State = sprintf('clownladder_jump_%d', ijump);
                    pause(0.1)
                end
                Clownladder.State = 'empty';
                ladder_jump11.State = 'ladder_jump_11';
                clown_jump11.State = 'clown_jump_11';
                for isplash = 1:3
                    Splash.State = sprintf('sssplash_%d', isplash);
                    pause(0.07)
                end
                pause(0.5)
                Splash.State = 'empty';
                ladder_jump11.State = 'empty';
                clown_jump11.State = 'empty';
                ExtraClown.State = 'empty';
                Clownladder.State = 'ground';
                ladderStep = 1;
                for idrop = 1:2
                    Drops.State = sprintf('sssplashdrops_%d', idrop);
                    pause(0.1)
                end
                Drops.State = 'empty';
                
            end   
        end
    end % while there are undone trials
    
    Clownladder.State = 'end';
    gameCommands.Scale = 2; 
    gameCommands.State = 'finish';   
    
    % it might be that this closes also the GUI for the experimenter
    % close gcf
    G.delete();

    % remove paths
    for iPath = 1 : length(paths2Add)
        rmpath(paths2Add{iPath});
    end
    
%%------------------------------------ embedded game functions    
    
    % function that tracks button presses
    function buttonupfcn(hObject, callbackdata)
        
        locClick = get(hObject,'CurrentPoint');
        if starting == 1
            click_located = false;
            for i=1:length(Buttons)
                button = Buttons{i};
                if is_click_on_sprite(button, locClick)
                    response.response_time = toc();
                    response.timestamp = now();
                    button.State = 'press';
                    response.emotion = button.ID;
                    uiresume();
                    click_located = true;
                    break
                end
            end
            
            if ~click_located && options.clickParrot2continue && is_click_on_sprite(Parrot, locClick)
                response.response_time = toc();
                response.timestamp = now();
                button.State = 'press';
                response.emotion = 'none';
                uiresume();
                tic();
            end
        else %  else of 'if starting == 1'
            if is_click_on_sprite(gameCommands, locClick)
                starting = 1;
                gameCommands.State = 'empty';
                pause(1)
                uiresume();
            end
        end
        
    end

    function buttondownfcn(hObject, callbackdata)
        
        locClick = get(hObject,'CurrentPoint');
        if starting == 1
            for i=1:length(Buttons)
                button = Buttons{i};
                if is_click_on_sprite(button, locClick)
                    button.State = 'press';
                else
                    button.State = 'on';
                end
            end
            
        end
        
    end 

end
