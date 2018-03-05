function [progress, phases, participant, res_filename] = emotion_progress(subject_name)

% Calculates progress for PICKA :: Emotion, returns:
%   - NaN means the file does not exist
%   - a number between 0 and 1 gives the proportion of trials performed

%------------------------------------------------------
% Etienne Gaudrain <e.p.c.gaudrain@rug.nl>,<etienne.gaudrain@cnrs.fr>
% RUG/UMCG, Groningen, NL; CNRS, CRNL, Lyon, FR
% 2017-12-14
%------------------------------------------------------

options = emotion_options();
res_filename = fullfile(options.result_path, sprintf('%s%s.mat', options.result_prefix, subject_name));

if ~exist(res_filename, 'file')
    progress = NaN;
    phases = {};
    participant = struct();
else
    dat = load(res_filename); % options, expe, results
    participant = struct('name', dat.options.subject_name, 'language', dat.options.language);
    if isfield(dat.options, 'subject_age')
        participant.age = dat.options.subject_age;
    end
    if isfield(dat.options, 'subject_sex')
        participant.sex = dat.options.subject_sex;
    end
    if ~isfield(dat, 'expe')
        progress = 0;
        phases   = {};
    else
        expe = dat.expe;
        p = [];
        expe.phases = fieldnames(expe);
        for iphase = 1 : length(expe.phases)
            if startswith(expe.phases{iphase}, 'test')
                p = [p, [expe.(expe.phases{iphase}).trials.done]];
            end
        end
        if isempty(p)
            progress = 0;
        else
            progress = mean(p);
        end
        phases = expe.phases;
    end
end