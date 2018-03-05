function fishy_main(res_filename, phase)


    if nargin > 0
        %expe = varargin{1};
        %options = varargin{2};
        %phase = varargin{3};
        results = struct();
        load(res_filename); % expe, options, results
    else
        % code executed only when fishy is run within this file.
        options = fishy_options();
        participant.name = 'test';
        participant.age = 24;
        participant.age = 8;
        participant.sex = 'f';
        participant.language = 'nl_nl'; % English or Dutch
        participant.kidsOrAdults = 'Kid';
        %addpath(options.path.tools);
        %options.home = getHome();
        %rmpath(options.path.tools);
        options = fishy_options(options, participant);
        paths2Add = {options.path.spritekit, options.path.tools};
        for ipath = 1 : length(paths2Add)
            if ~exist(paths2Add{ipath}, 'dir')
                error([paths2Add{ipath} ' does not exists, check the ../']);
            else
                addpath(paths2Add{ipath});
            end
        end
        [expe, options] = fishy_build_conditions(options);
        results = struct();
        phase = expe.phases{1};
        expe.training.conditions(1).done = 0;
    end
    
    % Calibration & sound level
    if ~isfield(options, 'gain') || ~exist('fishy_gain.m', 'file')
        if ~exist('fishy_gain.m', 'file')
            warndlg({'Calibration was not performed!',...
                'We are using a gain of 0.0 dB for now...'}, options.experiment_label, 'modal');
            uiwait();
            options.gain = 0;
        else
            options.gain = fishy_gain();
        end
    elseif options.gain ~= fishy_gain()
        b1 = sprintf('Keep the result file''s gain (%.1f dB)', options.gain);
        b2 = sprintf('Change to the FISHY_GAIN value (%.1f dB)', fishy_gain());
        blb = questdlg(sprintf('The GAIN in the results file (%.1f dB) is different from the gain in FISHY_GAIN (%.1f dB).', options.gain, fishy_gain()), ...
                options.experiment_label, b1, b2, b1);
        switch blb
            case b2
                if ~isfield(options, 'comments')
                    options.comments = {};
                end
                options.comments{end+1} = sprintf('Gain was updated from %.1f dB to %.1f dB on %s', options.gain, fishy_gain(), datestr(now()));
                options.gain = fishy_gain();
        end

    end
    check_sound_volume_warning(options.subject_name);
    
    
    session = getSession();
    
    if ~isfield(expe, 'session')
        expe.session = session;
    else
        expe.session(end+1) = session;
    end
    
    options_phase = regexprep(phase, '_\d+', ''); % in options, phases are not numbered, i.e. we have 'test' instead of 'test_1'
    
    %requested_volume = 10^(-options.attenuation_dB/20);
    %options.sound_volume = SoundVolume(requested_volume);
    %fprintf('Stimuli presented at %.2f%% of the volume (%.1f dB re. max).\n', options.sound_volume*100, 20*log10(options.sound_volume));

    starting = 1;
    simulate = strcmp(options.subject_name, 'test');
    if simulate
        fprintf('\nThis is a SIMULATION, no actual subject is tested.\n');
    end
    
    fprintf('\n%s\n\n', phase);

    while mean([expe.( phase ).conditions.done]) ~= 1
    % NOTE: this loop is interupted for kids at the end of one condition  
        
        % Find first condition not done
        i_condition = find([expe.( phase ).conditions.done] == 0, 1);
        
        starting = 0;
        
        if simulate
            %       simulResp = randi([0,1],151,1);
            % smaller number of correct answers
            %          simulResp = repmat([0 0 1], 1, 50);
            % higher number of correct answers
            simulResp = repmat([1 0 1], 1, 50);
            simulResp = simulResp(randperm(length(simulResp)));
            %         % more correct answers
            %         simulResp = repmat([0 1 1 1 1 1 1 1], 1, 25);
            %         simulResp = simulResp(randperm(length(simulResp)));
        end
        
        condition = expe.( phase ).conditions(i_condition);

        % Prepare unitary vector for this voice direction
        u_f0  = 12*log2(options.(options_phase).voices(condition.dir_voice).f0 / options.(options_phase).voices(condition.ref_voice).f0);
        u_ser = 12*log2(options.(options_phase).voices(condition.dir_voice).ser / options.(options_phase).voices(condition.ref_voice).ser);
        u = [u_f0, u_ser];
        u = u / sqrt(sum(u.^2));

        difference = options.(options_phase).starting_difference;
        step_size  = options.(options_phase).initial_step_size;

        decision_vector  = [];
        steps = [];
        differences = [difference];
        beginning_of_run = now();

        % Game initialisation
        friendsID = friendNames(options);
        friendsID = friendsID(randperm(length(friendsID))); % otherwise they are always in the same order
        targetSize = .5; % this is the size of the fish when it gets into the second arch
        %[G, gameElements.bkg, gameElements.bigFish, gameElements.bubbles, gameCommands, gameElements.hourglass] = ... % EG: 2017-10-06, want to make important game elements more easily accessible
         [G, gameElements, gameCommands] = ...
            setUpGame(options.(options_phase).terminate_on_nturns, length(friendsID), targetSize, options);
        
        G.onMouseRelease = @buttondownfcn;
        
        % Start the game
        if ~simulate
            while starting == 0
                uiwait();
            end
        else
            gameCommands.State = 'empty';
        end

        % Entrance, display all friends in second arc
        for ifriend = 1 : length(friendsID)
            speedSwim = 4;
            friendOn2Arch{ifriend} = friendInit(G.Size(1), G.Size(2), gameElements.bigFish, friendsID{ifriend}, ifriend, options);
            friendOn2Arch{ifriend} = swim(friendOn2Arch{ifriend}, speedSwim, 'in', G.Size(1));

        end
        
        % Show circles
        for iCircle = 1 : length(friendsID)
            % EG: We now have explicit reference to friendSlots
            %G.Children{6 + length(friendsID) - iCircle}.State = 'circle';
            gameElements.friendSlots(iCircle).State = 'circle';
            pause(.025);
        end
        
        friendsLoop = repelem([1 : length(gameElements.bigFish.availableLocArc1)], length(friendsID));
        countTrials = 0;
        friendOnArch = {};
        
        % Add the response to the results structure
        expe.( phase ).conditions(i_condition).attempts = expe.( phase ).conditions(i_condition).attempts + 1;
        n_attempt = expe.( phase ).conditions(i_condition).attempts;
        countCorrectResponses = 0;
        previousRespAcc = 1; % accuracy of the previous response, one for the beginning otherwise friends don't swim in
        
        while true

            pauseGame = false;
            countTrials = countTrials + 1;
            
            % Friend swim-in if previous answer was correct
            if previousRespAcc
                countCorrectResponses = countCorrectResponses + 1;

                tmpIdx = mod(countCorrectResponses, length(friendsLoop));
                if tmpIdx == 0
                    tmpIdx = length(friendsLoop);
                end
                friends = friendUpdate(G.Size(1), G.Size(2), friendsID{friendsLoop(tmpIdx)}, options);
                speedSwim = 40; % speed fish swim in. NOTE: it's inverted, high number = slow
                if simulate 
                    speedSwim = 4; % speed fish swim in. NOTE: it's inverted, high number = slow
                end
                for ifriends = 1 : length(friends)
                    friends{ifriends} = swim(friends{ifriends}, speedSwim, 'in', G.Size(1));
                end
                G.play(@()friendsEnter(friends));
            else
                % reset friend to neutral state
                pause(0.5);
                friends{response.button_clicked}.State = 'swim1';
            end 

            fprintf('\n-------- Phase %s - Condition %d - Trial %i\n', phase, i_condition, countTrials);
            % Prepare the stimulus: PT: if we need to replay the trial now new values should be created
            [response.button_correct, player, isi, response.trial] = fishy_make_stim(options, difference, u, condition);

            playSounds(player{1}, friends{1}, gameElements.bubbles)
            playSounds(isi)
            playSounds(player{2}, friends{2}, gameElements.bubbles)
            playSounds(isi)
            playSounds(player{3}, friends{3}, gameElements.bubbles)
            tic();
            
            % Show that friend are clickable
            for ifriend = 1 : 3
                friends{ifriend}.State = 'choice';
            end

            % Collect the response
            if ~simulate
                uiwait();
            else
                if simulResp(countTrials)
                    response.button_clicked = response.button_correct;
                else
                    availAnswers = 1:3;
                    availAnswers(response.button_correct) = [];
                    response.button_clicked = availAnswers(1);
                end
                [response.response_time, response.timestamp]= deal(1);
            end

            % Reset friends to previous state, besides from the clicked one
            availableResponses = 1:3;
            if response.button_clicked ~= response.button_correct
                friends{response.button_clicked}.State = 'error';
                availableResponses(response.button_clicked) = [];
                for ifriend = 1 : 2
                    friends{availableResponses(ifriend)}.State = 'swim1';
                end
            else
                availableResponses(response.button_clicked) = [];
                for ifriend = 1 : 2
                    friends{availableResponses(ifriend)}.State = 'swim1';
                end
            end

            response.correct = (response.button_clicked == response.button_correct);
            previousRespAcc = response.correct;
            decision_vector  = [decision_vector,  response.correct];
            response.condition = condition;
            response.condition.u = u; % Unitary direction vector for the difference

%             fprintf('Difference    : %.1f st (%.1f st GPR, %.1f st VTL)\n', ...
%                 difference, difference*u(1), difference*u(2));
%             fprintf('Correct button: %d\n', response.button_correct);
%             fprintf('Clicked button: %d\n', response.button_clicked);
%             fprintf('Response time : %d ms\n', round(response.response_time*1000));
%             fprintf('Time since beginning of run    : %s\n', datestr(...
%                 response.timestamp - beginning_of_run, 'HH:MM:SS.FFF'));
%             fprintf('Time since beginning of session: %s\n', datestr(...
%                 response.timestamp - beginning_of_session, 'HH:MM:SS.FFF'));
% 
            % add fields to the structure
            if ~isfield(results, phase) || ...
                    i_condition == length(results.( phase ).conditions)+1
                results.( phase ).conditions(i_condition) = struct('att', struct('responses', struct(), ...
                    'differences', [], 'steps', [], 'diff_i_tp', [], 'threshold', NaN, 'sd', []));
            end
            % there is a problem if you go for the second attempts when the ones before failed because the
            % structure should expand to accomodate the second attempt but it does not.
            if n_attempt > length(results.( phase ).conditions(i_condition).att)
                results.( phase ).conditions(i_condition).att(n_attempt).responses = orderfields( response );
            else
                if isempty(fieldnames(results.( phase ).conditions(i_condition).att(n_attempt).responses)) ...
                        || isempty(results.( phase ).conditions(i_condition).att(n_attempt).responses)
                    results.( phase ).conditions(i_condition).att(n_attempt).responses = orderfields( response );
                else
                    results.( phase ).conditions(i_condition).att(n_attempt).responses(end+1) = orderfields( response );
                end
            end
            [difference, differences, decision_vector, step_size, steps] = ...
                setNextTrial(options, difference, differences, decision_vector, step_size, steps, options_phase);

            if response.correct
                friendOnArch{end + 1} = friends{response.button_clicked};
                
                posOnArch = mod(countCorrectResponses, length(gameElements.bigFish.availableLocArc1));
                if posOnArch == 0
                    posOnArch = length(gameElements.bigFish.availableLocArc1);
                end
                friendOnArch{end} = getTrajectory(friendOnArch{end}, ...
                    gameElements.bigFish.arcAround1(:,gameElements.bigFish.availableLocArc1(posOnArch))'+gameElements.friendSlots(1).Scale*gameElements.friendSlots(1).Size/2, ...
                    [0,0], 4, targetSize, speedSwim);
                
                availableResponses = 1:3;
                availableResponses(response.button_clicked) = [];
                speedSwim = ceil(size(friends{response.button_clicked}.trajectory,1) / 2);
                % these guys start a bit later (i.e., half animation of the clicked friends)
                % This insures subjects knows what they clicked on!
                friends{availableResponses(1)} = swim(friends{availableResponses(1)}, speedSwim, 'out', G.Size(1));
                friends{availableResponses(2)} = swim(friends{availableResponses(2)}, speedSwim, 'out', G.Size(1));
                play(G, @()correctAnswer(friendOnArch{end}, friends{availableResponses(1)}, friends{availableResponses(2)}));
                % ajust friend in right location, not sure what's wrong with trajectory computation.
                friendOnArch{end}.Location = G.Children{6 + length(friendsID) - posOnArch}.Location; 
                % increase size of the friend
                for idx = 1 : length(friendOn2Arch)
                   if  strcmp(friendOn2Arch{idx}.filename, friendOnArch{end}.filename)
                       friendOn2Arch{idx}.Scale = friendOn2Arch{idx}.Scale + ...
                           (1 - .3) / (length(gameElements.bigFish.availableLocArc1) - 1);
                   end
                end
                gameElements.bigFish.countTurns = 1;
                play(G, @()celebrate(gameElements.bigFish));
                play(G, @()removeFriends(friends{availableResponses(1)}, friends{availableResponses(2)}));
                
                if posOnArch == length(gameElements.bigFish.availableLocArc1)
                    removeFriendsOnFirstArc(friendOnArch);
                    friendOnArch = {};
                end
            end % if response.correct
            
            if startswith(phase, 'training')
                terminate = false;
                if (countTrials == options.training.terminate_on_ntrials)
                    terminate = true;
                    expe.(phase).conditions(i_condition).done = 1;
                end
            else
                [results, expe, terminate, nturns] = ...
                    determineIfExit(results, expe, steps, differences, phase, options, ...
                    decision_vector, n_attempt, i_condition, u);
                gameElements.hourglass.State = sprintf('hourglass_%d', nturns);
            end
            
            % Save the responses
            results.( phase ).conditions(i_condition).att(n_attempt).duration = response.timestamp - beginning_of_run;
            
            save(options.res_filename, 'options', 'expe', 'results')
            
            if terminate
                gameCommands.State = 'finish';
                pause(2);
                close(G.FigureHandle)
%                 if strcmp(options.kidsOrAdults, 'kid')
%                     return;
%                 else
%                     break;
%                 end
                break
            end
            
        end %while true
        % Save the response (should already be saved... but just to be sure...)
        save(options.res_filename, 'options', 'expe', 'results');
    end % end of the 'conditions' while

%% nested functions for the game
    function friendsEnter(friends)
        
        gameElements.bkg.scroll('right', 1);
        for iFriend = 1 : length(friends)
            friends{iFriend}.Location = friends{iFriend}.trajectory(friends{iFriend}.iter, 1:2);
            
            friends{iFriend}.State = ['swim' sprintf('%i',  mod(floor(friends{iFriend}.iter/10), 4) + 1)];
            friends{iFriend}.Scale = friends{iFriend}.trajectory(friends{iFriend}.iter, 3);
            friends{iFriend}.iter = friends{iFriend}.iter + 1;
        end
        
        nIter = size(friends{1}.trajectory,1);
        if friends{1}.iter > nIter % stop processing
            G.stop();
            friends{1}.Angle = 0;
        end
    end

    function correctAnswer(s, friend1, friend2)
        gameElements.bkg.scroll('right', 1);
        s.Location = s.trajectory(s.iter,1:2);
        s.Scale = s.trajectory(s.iter,3);
        halfIter = floor(size(s.trajectory,1) / 2);
        
        if s.iter > halfIter
            friend1.Location = friend1.trajectory(friend1.iter, 1:2);
            friend2.Location = friend2.trajectory(friend2.iter, 1:2);
            friend1.iter = friend1.iter + 1;
            friend2.iter = friend2.iter + 1;
        end
        nIter = size(s.trajectory,1);
        if s.iter == nIter % stop processing
            G.stop();
            s.Angle = 0;
        end
        
%             if (mod(floor(iter/10), 4) == 0)
        s.State = ['swim' sprintf('%i',  mod(floor(s.iter/10), 4) + 1)];
        friend1.State = ['swim' sprintf('%i',  mod(floor(friend1.iter/10), 4) + 1)];
        friend2.State = ['swim' sprintf('%i',  mod(floor(friend2.iter/10), 4) + 1)];
        s.iter = s.iter + 1;
        
    end % end 'function' : correctAnswer

    function celebrate(s)
        gameElements.bkg.scroll('right', 1);
        if (mod(floor(s.iter/10), 4) == 0)
            s.cycleNext;
        end
        % iteration stop needs to be checked!
        if strcmp(s.State,'fish_1')
            if s.countTurns >= 1
                s.iter = 1;
                G.stop();
            end
            s.countTurns = s.countTurns + 1;
        end
    end % end 'function' : celebrate'


    function removeFriends(friend1, friend2)    
        % remove friend 1
        friendsOut = [];
        friendsStart = length(G.Children) - 2; % since the number of friends increases every time
        for friend2remove = friendsStart : length(G.Children)
            if strcmp(G.Children{friend2remove}.ID, friend1.ID)
                friendsOut = [friendsOut, friend2remove];
            end
        end
        % remove friend 2
        friendsStart = length(G.Children) - 2;
        for friend2remove = friendsStart : length(G.Children)
            if strcmp(G.Children{friend2remove}.ID, friend2.ID)
                friendsOut = [friendsOut, friend2remove];
            end
        end
        
        friendsDelete(friendsOut)
    end % end 'function' : removeFriends'

    function removeFriendsOnFirstArc(friendOnArch)
        friendsOut = [];
        for friend2remove = 1 : length(G.Children)
            for archFriend = 1 : length(friendOnArch)
                if strcmp(G.Children{friend2remove}.ID, friendOnArch{archFriend}.ID)
                    friendsOut = [friendsOut, friend2remove];
                end
            end
        end
        friendsDelete(friendsOut);
    end % end 'function' : removeFriendsOnFirstAr'

    function friendsDelete(friendsOut)
    % start deleting from the most outside friend, so that we don't
    % mess up the friends that are already there
        friendsOut = unique(friendsOut);
        for ifriend = 1 : length(friendsOut)
            delete(G.Children{friendsOut(length(friendsOut) - ifriend + 1)});
        end
        G.stop();
    end

    function buttondownfcn(hObject, callbackdata)
    
        locClick = get(hObject,'CurrentPoint');
        if starting == 1
            
            response.timestamp = now();
            response.response_time = toc();
            %response.button_clicked = 0; % default in case they click somewhere else
            resumeGame = false;
            for i=1:3
                if (locClick(1) >= friends{i}.clickL) && (locClick(1) <= friends{i}.clickR) && ...
                        (locClick(2) >= friends{i}.clickD) && (locClick(2) <= friends{i}.clickU)
                    response.button_clicked = i;
                    resumeGame = true;
                end
            end
            if (locClick(1) >= gameElements.hourglass.clickL) && (locClick(1) <= gameElements.hourglass.clickR) && ...
                    (locClick(2) >= gameElements.hourglass.clickD) && (locClick(2) <= gameElements.hourglass.clickU)
                if pauseGame
                    pauseGame = false;
                    %% replay the previous trial
                    % restore friends
                    for ifriend = 1 : 3
                        friends{ifriend}.State = 'swim1';
                    end
                    playSounds(player{1}, friends{1}, gameElements.bubbles)
                    playSounds(isi)
                    playSounds(player{2}, friends{2}, gameElements.bubbles)
                    playSounds(isi)
                    playSounds(player{3}, friends{3}, gameElements.bubbles)
                    tic();
                    % show that friend are clickable
                    for ifriend = 1 : 3
                        friends{ifriend}.State = 'choice';
                    end
                else
                    pauseGame = true;
                end
            end
            
            if resumeGame % (response.button_clicked >= 1 && response.button_clicked <= 3)
                uiresume();
            end
            
        else
%             'controls' is number 8
            for controlIndex = 1 : length(G.Children)
                if strcmp(G.Children{controlIndex}.ID, 'controls')
                    break
                end
            end
            
            if (locClick(1) >= G.Children{controlIndex}.clickL) && ...
                    (locClick(1) <= G.Children{controlIndex}.clickR) && ...
                    (locClick(2) >= G.Children{controlIndex}.clickD) && ...
                    (locClick(2) <= G.Children{controlIndex}.clickU)
                gameCommands.State = 'empty';
                gameElements.bigFish.State = 'fish_1';
                starting = 1;
                uiresume();
            end
        end
        
    end

end % end 'function : fishy_main(varargin)'