function calibration(language)

%CALIBRATION(LANGUAGE)
%   Prepares calibration material for PICKA. Once the gains for each
%   experiment adjusted, they are saved in each experiment's folder.
    
%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2018-05-02
% CNRS UMR 5292, FR | University of Groningen, UMCG, NL
%--------------------------------------------------------------------------

    warning('off');

    if nargin<1
        participant = default_participant();
        language = participant.language;
    end

    % ask to make sure that system volume is at max
    % change to 24 bits

    % We add MatlabCommonTools relatively first to get the GetFullPath
    % function, and then we reinclude it with absolute path so it stays when we
    % navigate with cd.
    addpath('../Resources/lib/MatlabCommonTools');
    lib_path_absolute = GetFullPath('../Resources/lib');
    rmpath('../Resources/lib/MatlabCommonTools');
    addpath(fullfile(lib_path_absolute, 'MatlabCommonTools'));

    %---- Prepare calibration noises

    cprintf('_[.2, .7, .5]', [upper('Preparing calibration noise'), '\n']);
    
    scripts = {};
    PICKA = picka_definition();
    for i=1:length(PICKA)
        scripts{i} = fullfile(PICKA(i).folder, PICKA(i).prefix);
    end
    
    %scripts = { ...
    %    'gender/gender', ...
    %    'fishy/fishy', ...
    %    'emotion/emotion'};
    %    'CRM/expe', ...

    length_sample = 10;
    spectrum_max  = -Inf;

    experiments = struct();

    try
        close(101);
        close(102);
    catch err
        % Do nothing
    end

    for i=1:length(scripts)
        script = scripts{i};
        fprintf('Getting stimuli from ');
        cprintf('[.4, .4, 1]', '%s\n', script);
        [folder, fx_prefix] = fileparts(script);
        experiments(i).folder = folder;
        experiments(i).fx_prefix = fx_prefix;

        cd(folder);
        try

            fh_options = str2func([fx_prefix, '_options']);
            fh_build   = str2func([fx_prefix, '_build_conditions']);
            if ~exist([fx_prefix, '_gain.m'], 'file')
                make_gain_function([fx_prefix, '_gain.m'], 0);
            end
            fh_gain = str2func([fx_prefix, '_gain']);
            
            experiments(i).fh_options = fh_options;
            experiments(i).fh_build = fh_build;

            options = fh_options();

            experiments(i).options = options;

            options.language = language;
            [~, options] = fh_build(options);
            if ~isfield(options, 'sounds_for_calibration')
                error('The options structure does not contain "sounds_for_calibration"');
            end
            if isempty(options.sounds_for_calibration)
                error('There are not sounds for calibration. Perhaps you need to pre-process first...');
            end
            fprintf('   Checking if RMS of calibration sounds are equal...\n');
            x = [];
            RMSs = zeros(length(options.sounds_for_calibration),1);
            previous_fs = [];
            for k=1:length(options.sounds_for_calibration)
                [y, fs] = audioread(options.sounds_for_calibration{k});
                if ~isempty(previous_fs) && previous_fs~=fs
                    error('File %s does not have the same sampling frequency (%d Hz) as the previous one (%d Hz).', options.sounds_for_calibration{k}, fs, previous_fs);
                end
                previous_fs = fs;

                if size(y,2)>1
                    y = mean(y,2);
                end
                RMSs(k) = rms(y);
                x = [x; y];
            end
            mRMS = mean(RMSs);
            fprintf('   RMS: min=%.3f, avg=%.3f, max=%.3f\n', min(RMSs), mean(RMSs), max(RMSs));
            if any(abs(RMSs-mRMS)/mRMS>.1)
                error('RMSs are not equalized. Equalize the stimuli first!');
            end
            experiments(i).rms = rms(x);
            fprintf('   The RMS for the stimuli of this experiment is %.3f.\n', experiments(i).rms);
            fprintf('   Converting to noise...');
            noisy_x = to_noise(x, fs);
            if length(noisy_x) < fs*length_sample
                noisy_x = repmat(noisy_x, ceil(fs*length_sample/length(noisy_x)), 1);
            end
            noisy_x = noisy_x(1:min(length(noisy_x), round(fs*length_sample)));

            figure(101)
            subplot(2, 1, 1)
            plot((1:length(noisy_x))/fs+(i-1)*length_sample, noisy_x);
            hold on
            text(((i-1)+1/2)*length_sample, .8, folder);

            subplot(2, 1, 2)
            NOISY_X = 20*log10(abs(fft(noisy_x))/sqrt(length(noisy_x)));
            w = hann(256)';
            w = w/sum(w);
            NOISY_X = conv(NOISY_X, w, 'same');
            f = (0:length(noisy_x)-1)/(length(noisy_x)-1)*fs;
            plot(f, NOISY_X);
            spectrum_max = max(spectrum_max, max(NOISY_X));
            hold on
            
            experiments(i).fs = fs;
            experiments(i).noise = cosgate(noisy_x, fs, 50e-3);
            experiments(i).gain  = fh_gain();

            fprintf(' Done.\n');
            drawnow()

        catch er
            cd('..');
            er.rethrow();
        end
        cd('..');
    end

    figure(101)
    subplot(2, 1, 1)
    hold off
    xlabel('Time (s)');

    subplot(2, 1, 2)
    hold off
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    xlim([10, 16000]);
    ylim([-70, 0]+spectrum_max);


    %---- Preparing GUI
    
    cprintf('_[.2, .7, .5]', [upper('Calibration'), '\n']);
    fprintf('Play each sound and measure the sound level with your sound level meter (65 dB-A).\n');
    fprintf('Adjust the gain for each experiment to reach the desired level. Once this is done,\n');
    fprintf('click the "Save gains to files" button.\n\n');

    figure(102)
    screen1 = getScreens();
    rh = 50;
    wh = length(experiments)*rh+100;
    ww = 500;
    set(gcf, 'Position', [screen1(3)/2-ww/2, screen1(4)/2-wh/2, ww, wh]);

    for i=1:length(experiments)
        uicontrol('Style', 'text', 'String', experiments(i).folder, 'Position', [10, (i-.5)*rh+32+10, ww/4-10, 32], 'FontSize', 13);
        experiments(i).gain_edit = uicontrol('Style', 'edit', 'String', experiments(i).gain, 'Position', [ww/4, (i-.5)*rh+10+32+10, ww/4-10, 32]);
        experiments(i).play_button = uicontrol('Style', 'pushbutton', 'String', 'play', 'Position', [ww/4*2, (i-.5)*rh+10+32+10, ww/4-10, 32]);
        experiments(i).play_button.Callback = {@button_click, i};
        experiments(i).pgax = axes('Unit', 'pixel', 'Position', [3*(ww/4), (i-.5)*rh+10+8+32+10, ww/4-10, 16]);
        fill([0, 1, 1, 0], [0, 0, 1, 1], 'w', 'Parent', experiments(i).pgax);
        set(experiments(i).pgax, 'XLim', [0,1], 'YLim', [0,1], 'XTick', [], 'YTick', []);
    end
    uicontrol('Style', 'text', 'String', 'gain (dB)', 'Position', [ww/4, (i-.5)*rh+10+32+10+32+10, ww/4-10, 16]);
    uicontrol('Style', 'pushbutton', 'String', 'Save gains to files', 'Position', [10, 10, 150, 32], 'Callback', @save_gains_to_files);

    check_sound_volume_warning('Calibration');
    
    rmpath(fullfile(lib_path_absolute, 'MatlabCommonTools'));

    warning('on');
    
    %------------------------------------------------
    function button_click(src, event, exp_index)
        
        experiments(exp_index).gain = str2double(experiments(exp_index).gain_edit.String);
        
        if strcmp(experiments(exp_index).play_button.String, 'play')
            % We start playing the sound
            experiments(exp_index).player = audioplayer(experiments(exp_index).noise * 10^(experiments(exp_index).gain/20), experiments(exp_index).fs);
            experiments(exp_index).player.TimerFcn = {@play_progress, experiments(exp_index).pgax};
            experiments(exp_index).player.play();
            experiments(exp_index).play_button.String = 'stop';
        else
            % We stop the sound
            stop(experiments(exp_index).player);
            fill([0, 1, 1, 0], [0, 0, 1, 1], 'w', 'Parent', experiments(exp_index).pgax);
            set(experiments(exp_index).pgax, 'XLim', [0,1], 'YLim', [0,1], 'XTick', [], 'YTick', []);
            experiments(exp_index).play_button.String = 'play';
        end
        
    end

    %------------------------------------------------
    function play_progress(src, event, pgax)
        p = src.CurrentSample/src.TotalSamples;
        fill([0, p, p, 0], [0, 0, 1, 1], [.5, .5, .8], 'Parent', pgax);
        set(pgax, 'XLim', [0,1], 'YLim', [0,1], 'XTick', [], 'YTick', []);
    end

    %------------------------------------------------
    function save_gains_to_files(src, event)
        
        for i=1:length(experiments)
            gain = str2double(experiments(i).gain_edit.String);
            make_gain_function(fullfile(experiments(i).folder, [experiments(i).fx_prefix, '_gain.m']), gain);
        end
        
    end

end

%===============================================================
function make_gain_function(filename, gain, caller)

if nargin<3
    [st, i] = dbstack();
    if length(st)>=i+1
        caller = ['the ' st(i+1).name ' script'];
    else
        caller = 'a direct call of the console';
    end
else
    caller = ['the ' caller ' script'];
end

fd = fopen(filename, 'wb');

[~, fname] = fileparts(filename);

fprintf(fd, 'function gain = %s()\n\n', fname);
fprintf(fd, '%% This file was generated on %s by %s\n\n', datestr(datetime('now')), caller);
fprintf(fd, 'gain = %f;\n', gain);
fclose(fd);

fprintf('   Gain %f written to %s.\n', gain, filename);

end

