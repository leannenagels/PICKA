function generateStimuli(options)
    
    % remove all the generated files:
    % sound files, wav files
    
    %delete(options.res_filename);
    
    [expe, options] = gender_build_conditions(options);
    
    opt = char(questdlg('Delete previously processed sound files?','Remove old sound files','yes','no','no'));
    switch opt
        case 'yes',
            delete(fullfile(options.tmp_path_local, '*.mat'));
            delete(fullfile(options.tmp_path_local, '*.wav'));
        %case 'no'
        %    return
    end
            
    
    phases = fieldnames(expe);
    for i_phase = 1:length(phases)
        phase = phases{i_phase};
        while mean([expe.(phase).trials.done])~=1 % Keep going while there are some trials to do
            itrial = find([expe.(phase).trials.done]==0, 1);
            trial = expe.(phase).trials(itrial);
            gender_make_stim(options, trial);
            expe.(phase).trials(itrial).done = 1;
        end
    end
    
    lst = dir(fullfile(options.tmp_path_local, '*.wav'));
    for i=1:length(lst)
        x = audioread(fullfile(options.tmp_path_local, lst(i).name));
        % Note, files are already normalized
        lst(i).rms = rms(x);
    end
    rms_ref = min([lst(:).rms]);
    for i=1:length(lst)
        [x, fs] = audioread(fullfile(options.tmp_path_local, lst(i).name));
        x = x / lst(i).rms * rms_ref;
        audiowrite(fullfile(options.tmp_path_local, lst(i).name), x, fs);
    end
end



