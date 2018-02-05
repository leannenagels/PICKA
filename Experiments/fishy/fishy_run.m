function progress = fishy_run(participant)

% note: with kids we want to split the experiment in two and so there
% should be training test training test rather than training training test
% test. 

rng('shuffle')
%run('../defineParticipantDetails.m')

options = fishy_options(struct(), participant);

paths2Add = {options.path.spritekit, options.path.tools}; 
for ipath = 1 : length(paths2Add)
    if ~exist(paths2Add{ipath}, 'dir')
        error([paths2Add{ipath} ' does not exists, check the ../']);
    else
        addpath(paths2Add{ipath});
    end
end

if ~exist(options.res_filename, 'file')
    fprintf('New subject. Creating conditions for file %s...\n', options.res_filename);
    [expe, options] = fishy_build_conditions(options);
    iphase = 1;
else
    % Add message that the participant has already been tested...
    fprintf('!! Subject "%s" has been tested before. Loading the result file...', options.subject_name);
    
    tmp = load(options.res_filename); % options, expe, results
    options = tmp.options;
    expe = tmp.expe;
    % check which phase should be started with
    for iphase = 1 : length(expe.phases)
        if any([expe.(expe.phases{iphase}).conditions.done] == 0)
            break
            % which of the conditions will have to be done will be figured out in fishy_main
        end
    end
end

phase = expe.phases{iphase};

% EG: Let's not call fishy_build_conditions again because if the file's
% been modified between two sessions, we will be erasing properties of the
% experiment for the 1st session.

% % if it is a repetition make everything new
% if sum([expe.training.conditions.done, expe.test.conditions.done]) >= 4
%     [expe, options] = fishy_build_conditions(options);
%     phase = 'training';
% end

fishy_main(options.res_filename, phase);
% if a training phase has just been done, we do the next phase right away
if startswith(phase, 'training')
    fprintf('\nWe were doing training, let''s move to the next phase directly.\n');
    iphase = iphase+1;
    phase = expe.phases{iphase};
    fprintf('The new phase is %s.\n', phase);
    fishy_main(options.res_filename, phase);
end


%------------------------------------------
% Calculate progress
expe = load(options.res_filename, 'expe'); % options, expe, results
if is_empty(expe)
    progress = 0;
else
    p = [];
    for iphase = 1 : length(expe.expe.phases)
        p = [p, [expe.expe.(expe.expe.phases{iphase}).conditions.done]];
    end
    progress = mean(p);
end


%------------------------------------------
% Clean up the path
for ipath = 1 : length(paths2Add)
    rmpath(paths2Add{ipath});
end