function expe_run(participant, phase)

% expe_run(subject, phase)
%   phase can be: 'training', 'test'

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@mrc-cbu.cam.ac.uk> - 2010-03-16
% Medical Research Council, Cognition and Brain Sciences Unit, UK
%
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2017-08-06
% CNRS UMR 5292, FR | University of Groningen, UMCG, NL
%--------------------------------------------------------------------------

options = struct();
options = expe_options();

%-------------------------------------------------
addpath(options.path.straight);
addpath(options.path.tools);


% Adjust to which language you want as default
if ~isfield(participant, 'language')
    participant.language = 'nl_nl';
end

%-------------------------------------------------
subject = participant.name;
options.subject_name = participant.name;

language = normalize_language(participant.language);
switch language
    case 'nl'
        language = 'nl_nl';
    case 'en'
        language = 'en_gb';
end
options.language = language;

options.subject_age = participant.age;


%-------------------------------------------------

%options = struct();
% options = expe_options(options);

%-------------------------------------------------

% Create result dir if necessary
if ~exist(options.result_path, 'dir')
    mkdir(options.result_path);
end

res_filename = fullfile(options.result_path, sprintf('%s%s.mat', options.result_prefix, subject));
options.res_filename = res_filename;

if ~exist(res_filename, 'file')
    opt = char(questdlg(sprintf('The participant"%s" doesn''t exist. Create it?', subject), options.experiment_label,'OK','Cancel','OK'));
    switch lower(opt)
        case 'ok'
            [training, test, options] = expe_build_conditions(options);
        case 'cancel'
            return
        otherwise
            error('Unknown option: %s',opt)
    end
else
    opt = char(questdlg(sprintf('Found "%s". Use this file?', res_filename), options.experiment_label,'OK','Cancel','OK'));
    if strcmpi(opt, 'Cancel')
        return
    end
end

% If the phase wasn't provided, we determine which it should be
if isempty(phase)
    phases = {'training', 'test'};
    for i=1:length(phases)
       phase = phases{i};
       if any([expe.(phase).trials.done]~=1)    
           break
       end
    end
end
expe_main(options, phase);

%-------------------------------------------------

rmpath(options.path.straight);
rmpath(options.path.tools);