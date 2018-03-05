function [x, fs] = gender_make_stim(options, trial)


    warning('off', 'MATLAB:interp1:NaNinY');

    %x = [];
    [x, fs] = straight_process(trial.word, trial.f0, trial.vtl, NaN, options);
    
    if fs~=options.fs
        x = resample(y, options.fs, fs);
        fs = options.fs;
    end
    
%EG: 2017-11-07 We don't need to adjust the duration    
%     dl = round(options.word_duration*fs) - length(y);
%     if dl>0
%         npad_L = floor(dl/20);
%         npad_R = dl-npad_L;
%         nr = floor(1e-3*fs);
%         % PT: matrix error with dutch stimuli
%         y(1:nr) = y(1:nr) .* linspace(0, 1, nr)';
%         y(end-nr+1:end) = y(end-nr+1:end) .* linspace(1, 0, nr)';
%         y = [zeros(npad_L,1); y; zeros(npad_R,1)];
%         % PT: matrix error with english stimuli
% %         y(1:nr) = y(1:nr) .* linspace(0, 1, nr);
% %         y(end-nr+1:end) = y(end-nr+1:end) .* linspace(1, 0, nr);
% %         y = [zeros(npad_L,1); y; zeros(npad_R,1)];
%     elseif dl<0
%         y = y(1:end+dl);
%         nr = floor(1e-3*fs); % 1 ms linear ramp at the end
%         y(end-nr+1:end) = y(end-nr+1:end) .* linspace(1, 0, nr)'; 
% %         this gives a matrix dimensions must agree error
% %         y(end-nr+1:end) = y(end-nr+1:end) .* linspace(1, 0, nr);
%     else
%         nr = floor(1e-3*fs);
%         y(1:nr) = y(1:nr) .* linspace(0, 1, nr)';
%         y(end-nr+1:end) = y(end-nr+1:end) .* linspace(1, 0, nr)';
%     end 
    
    %x = [x; y];

    fprintf('%s -- F0: %.1f st, VTL: %.1f st\n', trial.word, trial.f0, trial.vtl);

    if ~isnan(options.lowpass)
        [b, a] = butter(4, options.lowpass*2/fs, 'low');
        x = filtfilt(b, a, x);
    end

    switch options.ear
        case 'right'
            x  = [zeros(size(x)), x];
        case 'left'
            x = [x, zeros(size(x))];
        case 'both'
            x = repmat(x, 1, 2);
        otherwise
            error('options.ear="%s" is not implemented', options.ear);
    end

    warning('on', 'MATLAB:interp1:NaNinY');
end
%--------------------------------------------------------------------------
function fname = make_fname(wav, f0, vtl, d, destPath)
    
    [~, name, ext] = fileparts(wav);
    if isnan(d)
        fname = sprintf('%s_GPR%.2f_VTL%.2f', name, floor(f0), vtl);
    else
        fname = sprintf('%s_GPR%.2f_VTL%.2f_D%d', name, floor(f0), vtl, floor(d*1e3));
    end
    fname = fullfile(destPath, [fname, ext]);
    
end
%--------------------------------------------------------------------------
function [y, fs] = straight_process(word, nb_st, vtl, d, options)

    wavIn = fullfile(options.sound_path_local, [word, '.wav']);
    wavOut = make_fname(wavIn, nb_st, vtl, d, options.tmp_path_local);
    if ~exist(options.tmp_path_local, 'dir')
        mkdir(options.tmp_path_local);
    end

%     disp(word)
%     if ~exist(wavOut, 'file') || options.force_rebuild_sylls % PT: forced
%     rebuilding?
    if ~exist(wavOut, 'file')

        addpath(options.path.straight);

        [folder, name, ~] = fileparts(wavIn);
        mat = fullfile(options.tmp_path_local, [name, '.straight.mat']);
        
%         disp(wavIn)
%         disp(mat)
         
        if exist(mat, 'file')
            load(mat);
        else
            [x, fs] = audioread(wavIn);
            % PT: remove the stereo channel if present the files for gender
            % are mono anyway, the second channel is empty
%             x(:, 2) = [];
            x = x(:, 1);
            % x = squeeze(x); % PT: just to make sure
            [f0, ap] = exstraightsource(x, fs);
            sp = exstraightspec(x, f0, fs);
            x_rms = rms(x);
            save(mat, 'fs', 'f0', 'sp', 'ap', 'x_rms');
        end

        f0(f0~=0) = f0(f0~=0) * 2^(nb_st/12);
        p.frequencyAxisMappingTable = 2^(-vtl/12);
        y = exstraightsynth(f0, sp, ap, fs, p);

        
        y = y/rms(y)*x_rms;
        if max(abs(y))>1
            fprintf(' !! Output was renormalized for "%s" with a factor %.3f.\n', wavOut, 0.98/max(abs(y)));
            y = 0.98*y/max(abs(y));
        end
        
        y = remove_silence(y, fs, 5e-3);
        
        audiowrite(wavOut, y, fs);

        rmpath(options.path.straight);
    else
        [y, fs] = audioread(wavOut);
    end

end