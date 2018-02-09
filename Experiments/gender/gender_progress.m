function [p, diagnostic, participant] = gender_progress(subject)

% Returns the progress in the PICKA :: Gender experiment for this subject:
%   - NaN means the file does not exist
%   - a number between 0 and 1 gives the proportion of trials performed
%

%------------------------------------------------------
% Etienne Gaudrain <e.p.c.gaudrain@rug.nl>,<etienne.gaudrain@cnrs.fr>
% RUG/UMCG, Groningen, NL; CNRS, CRNL, Lyon, FR
% 2017-11-10
%------------------------------------------------------


options = gender_options();
options.subject_name = subject;
res_filename = fullfile(options.result_path, sprintf('%s%s.mat', options.result_prefix, options.subject_name));

if exist(res_filename, 'file')
    dat = load(res_filename);
    participant = struct('name', dat.options.subject_name, 'language', dat.options.language);
    if isfield(dat.options, 'subject_age')
        participant.age = dat.options.subject_age;
    end
    if isfield(dat.options, 'subject_sex')
        participant.sex = dat.options.subject_sex;
    end
    if isfield(dat, 'expe') && isfield(dat.expe, 'test')
        p = mean([dat.expe.test.trials.done]);
        diagnostic = fieldnames(dat.expe);
    else
        p = 0;
        diagnostic = {};
    end
else
    p = NaN;
    diagnostic = {};
    participant = struct();
end

