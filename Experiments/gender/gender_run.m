function gender_run

    rng('shuffle')
    run('../defineParticipantDetails.m')

    options.subject_name = participant.name;
    options.language = lower(participant.language);
    % options.stage = 'generation'; uncomment o generate sounds stimuli
    phase = 'test';
    options.stage = phase;
    options.Bert = false;
    options = gender_options(options);
    
    % Check if results directory exists otherwise make one.
    if ~exist(options.result_path, 'dir')
        mkdir(options.result_path);
    end
    
    % Print results file 'exp_subjectname'
    res_filename = fullfile(options.result_path, sprintf('%s%s.mat', options.result_prefix, options.subject_name));
    options.res_filename = res_filename;
    
    addpath(options.straight_path);
    addpath(options.spriteKitPath);

    
    if strcmp(options.stage, 'generation')
        generateStimuli(options, phase);
    else    
        if ~exist(res_filename, 'file')
            [expe, options] = gender_buildingconditions(options);
        else
            load(options.res_filename); % options, expe, results
        end
        gender_main(expe, options, phase);
    end % end if generate

    rmpath(options.straight_path);
    rmpath(options.spriteKitPath);    
end