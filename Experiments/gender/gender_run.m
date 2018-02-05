function gender_run(participant, phase)

    if nargin<2
        phase = [];
    end

    rng('shuffle')
    % EG: we want to pass in the participant manually to make sure we have
    % the right one...
    %run('../defineParticipantDetails.m')

    options.subject_name = participant.name;
    options.language     = participant.language;
    options.subject_age  = participant.age;
    % options.stage = 'generation'; uncomment o generate sounds stimuli
    %phase = 'test';
    %options.stage = phase;
    options = gender_options(options);
    
    addpath(options.path.straight);
    addpath(options.path.spritekit);
    addpath(options.path.tools);
    
    options.language = normalize_language(options.language);
    
    % Check if results directory exists otherwise make one.
    if ~exist(options.result_path, 'dir')
        mkdir(options.result_path);
    end
    
    % Print results file 'exp_subjectname'
    res_filename = fullfile(options.result_path, sprintf('%s%s.mat', options.result_prefix, options.subject_name));
    options.res_filename = res_filename;

    if strcmp(participant.name, 'generation')
        generateStimuli(options);
        delete(options.res_filename);
    else    
        results = struct();
        if ~exist(res_filename, 'file')
            [expe, options] = gender_build_conditions(options);
        else
            load(options.res_filename); % options, expe, results
        end
        if isempty(phase)
            phases = {'training', 'test'};
            for i=1:length(phases)
               phase = phases{i};
               if any([expe.(phase).trials.done]~=1)    
                   break
               end
            end
        end
        gender_main(expe, options, phase, results);
    end % end if generate

    rmpath(options.path.straight);
    rmpath(options.path.spritekit);
    rmpath(options.path.tools);
end