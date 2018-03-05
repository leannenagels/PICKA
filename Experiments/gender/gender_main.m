function gender_main(expe, options, phase, results)

    fprintf('\n\nPRESS Ctrl TO SKIP A TRIAL.\n\n');
    
    %EG: this is erasing results everytime we restart the experiment...
    % moved to gender_run before loading the file.
    %results = struct();
    
    % Calibration & sound level
    if ~isfield(options, 'gain') || ~exist('gender_gain.m', 'file')
        if ~exist('gender_gain.m', 'file')
            warndlg({'Calibration was not performed!',...
                'We are using a gain of 0.0 dB for now...'}, options.experiment_label, 'modal');
            uiwait();
            options.gain = 0;
        else
            options.gain = gender_gain();
        end
    elseif options.gain ~= gender_gain()
        b1 = sprintf('Keep the result file''s gain (%.1f dB)', options.gain);
        b2 = sprintf('Change to the GENDER_GAIN value (%.1f dB)', gender_gain());
        blb = questdlg(sprintf('The GAIN in the results file (%.1f dB) is different from the gain in GENDER_GAIN (%.1f dB).', options.gain, gender_gain()), ...
                options.experiment_label, b1, b2, b1);
        switch blb
            case b2
                if ~isfield(options, 'comments')
                    options.comments = {};
                end
                options.comments{end+1} = sprintf('Gain was updated from %.1f dB to %.1f dB on %s', options.gain, gender_gain(), datestr(now()));
                options.gain = gender_gain();
        end

    end
    check_sound_volume_warning(options.subject_name);
    
    
    starting = 0;

    autoplayer = false;
    if strcmp(options.subject_name, 'test');
        autoplayer = true;
    end

    %% ------------- Game
    if (mean([expe.(phase).trials.done])==1) && strcmp(options.subject_name, 'test') % EG: we only to this if this is 'test'
        resultsFiles = dir(fullfile(options.result_path, sprintf('_%s*_test*.mat', options.result_prefix)));
        nRep = length(resultsFiles) - sum(cellfun('isempty', regexp({resultsFiles.name}, options.subject_name)));
        nRep = nRep + 1;
        options.subject_name  = sprintf('_%s%s_%02d.mat', options.result_prefix, 'test', nRep);
        options.res_filename = fullfile(options.result_path, options.subject_name);
        [expe, options] = gender_buildingconditions(options);
    end
    [G, TVScreen, Buttonright, Buttonwrong, Speaker, gameCommands, Hands] = gender_game(options);
    G.onMouseRelease = @buttondownfcn;
    G.onKeyPress = @keypressfcn;

    %=============================================================== MAIN LOOP
    while mean([expe.(phase).trials.done])~=1 % Keep going while there are some trials to do
    
        % EG: this was a nice solution, but seeing how it does not work
        % cross platforms, we cannot use it.
        %{
        requested_volume = 10^(-options.attenuation_dB/20);
        options.sound_volume = SoundVolume(requested_volume);
        if starting==0
            fprintf('\nStimuli presented at %.2f%% of the volume (%.1f dB re. max).\n', options.sound_volume*100, 20*log10(options.sound_volume));
        end
        %}

        % Find first trial not done
        itrial = find([expe.( phase ).trials.done]==0, 1);
        trial = expe.( phase ).trials(itrial); 
        
        if starting==0
            fprintf('\n---> Starting at trial %d/%d\n\n', itrial, length(expe.( phase ).trials));
        end
        
        if autoplayer 
            starting = 1;
            gameCommands.State = 'empty';
        end
        
        TVScreen.State = 'off';
        Buttonright.State = 'off';
        Buttonwrong.State = 'off';
        TVScreen.State = 'noise_1';
        pause(.2);
        
        % If we start, we wait for the message to be clicked
        if starting == 0
            uiwait();
        end   
    
        [xOut, fs] = gender_make_stim(options, trial);
        
        %EG: Adding some silence at the beginning to have the noise
        %animation run longer.
        xOut = [zeros(round(options.fs*.5),size(xOut,2)); xOut];
        xOut = xOut * 10^(options.gain/20);

        player = audioplayer(xOut, fs, 24);
        pause(.5);
        iter = 1;
        
        play(player)
        while true
            TVScreen.State = sprintf('noise_%d', mod(iter-1, 5)+1); 
            Speaker.State = sprintf('TVSpeaker_%i', mod(iter-1, 2)+1);
            iter = iter + 1;
            pause(0.01);
            if ~isplaying(player)
                Speaker.State = 'off';
                break;
            end
        end

        % why is this here?
%         if ~autoplayer
%             uiwait
%         end

        locHand = 1;
        if (strncmp(expe.(phase).trials(itrial).hands, 'handremote',10))
            locHand = 2;
        end
        for handstate = 1:2
            Hands.State = sprintf('%s%d', expe.(phase).trials(itrial).hands, handstate);
            Hands.Location = [Hands.locHands{locHand}];
            if ~autoplayer
                pause(0.15)
            end
        end
        if ~autoplayer
            pause(0.2)
        end
        Hands.State = 'off';
        if ~autoplayer
            pause(0.1)
        end
        TVScreen.State = expe.(phase).trials(itrial).face;
        if ~autoplayer
            pause(0.2)
        end
        Buttonright.State = 'on';
        Buttonwrong.State = 'on';
        
        if autoplayer
            response.button_clicked = randi([0, 1], 1, 1); % default in case they click somewhere else
            response.response_time = 0; 
            response.timestamp = now;
        else
            tic();
            uiwait();
            response.response_time = toc;
            response.timestamp = now;
        end
        response.trial = trial;
        if ~isfield(results, phase)
            results.( phase ).responses = orderfields( response );
        else
            results.( phase ).responses(end+1) = orderfields( response );
        end
        
        expe.( phase ).trials(itrial).done = 1;
        
        save(options.res_filename, 'options', 'expe', 'results')
    
        if itrial == options.(phase).total_ntrials
                gameCommands.Scale = 2; 
                gameCommands.State = 'finish';
        end
    end

%%     
    function buttondownfcn(hObject, callbackdata)
        
        locClick = get(hObject,'CurrentPoint');
        
        if starting == 1
            
            response.timestamp = now();
            response.response_time = toc();
            response.button_clicked = 0; % default in case they click somewhere else
            
            %EG: 2017-11-10 replace with a call to is_click_on_sprite()
            %if (locClick(1) >= Buttonright.clickL) && (locClick(1) <= Buttonright.clickR) && ...
            %        (locClick(2) >= Buttonright.clickD) && (locClick(2) <= Buttonright.clickU)
            if is_click_on_sprite(Buttonright, locClick, 2, 'fast')
                Buttonright.State = 'press';
                response.button_clicked = 1; % Same
                response.button_clicked_label = Buttonright.ID;
            %elseif (locClick(1) >= Buttonwrong.clickL) && (locClick(1) <= Buttonwrong.clickR) && ...
            %        (locClick(2) >= Buttonwrong.clickD) && (locClick(2) <= Buttonwrong.clickU)
            elseif is_click_on_sprite(Buttonwrong, locClick, 2, 'fast')
                Buttonwrong.State = 'press'; 
                response.button_clicked = 2; % Different
                response.button_clicked_label = Buttonwrong.ID;
            end
            
            % continue if only one of the two buttons is clicked upon
            % otherwise not
            if response.button_clicked ~= 0
                pause(0.1)
                Buttonright.State = 'off';
                Buttonwrong.State = 'off';
                TVScreen.State = 'off';
                fprintf('Clicked button: %d (%s)\n', response.button_clicked, response.button_clicked_label);
                fprintf('Trials: %d\n', itrial);
                fprintf('Response time : %d ms\n\n', round(response.response_time*1000));
                pause(0.3)
                uiresume();
            end
            
        else
             %if (locClick(1) >= gameCommands.clickL) && (locClick(1) <= gameCommands.clickR) && ...
             %   (locClick(2) >= gameCommands.clickD) && (locClick(2) <= gameCommands.clickU)
             if is_click_on_sprite(gameCommands, locClick, 2, 'fast')
                 starting = 1;
                 gameCommands.State = 'empty';
                 pause(1);
                 uiresume();
             end
        end
    end % end buttondown fcn

    function keypressfcn(~,e)
        if strcmp(e.Key, 'control') % OR 'space'
            uiresume;
            tic();
        end
    end
   
    % close current figure
    close(gcf);
end

