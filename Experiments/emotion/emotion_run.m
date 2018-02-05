function emotion_run(participant, phase)

% EMOTION_RUN(PARTICIPANT, PHASE)
%   Call to run the PICKA emotion experiment.
%   PARTICIPANT is a structure with fields 'name', 'kidsOrAdults' and 'language'.
%   PHASE is 'training' or 'test'.

%-------------------------------------------------------------------------
% Initial version by:
% Paolo Toffanin <p.toffanin@umcg.nl>, RuG, UMCG, Groningen, NL
%-----------------------
% Other contributors:
%   Jacqueline Libert
%   Leanne Nagels <leanne.nagels@rug.nl>
%-----------------------
% This version modified by:
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2017-12-05
% CNRS, CRNL, Lyon, FR | RuG, UMCG, Groningen, NL
%-------------------------------------------------------------------------

%rng('shuffle')
% participant gui
%run('../guiParticipantDetails.m')
%participant=ans;

if nargin<2
    phase = [];
end

% load emotion_options
options = emotion_options(struct(), participant);

% add paths
paths2Add = {options.path.tools}; 
for ipath = 1 : length(paths2Add)
    if ~exist(paths2Add{ipath}, 'dir')
        error([paths2Add{ipath} ' does not exist, check the ../']);
    else
        addpath(paths2Add{ipath});
    end
end

if ~exist(options.res_filename, 'file')
    opt = char(questdlg(sprintf('The subject "%s" doesn''t exist. Create it?', options.subject_name), options.experiment_label,'OK','Cancel','OK'));
    switch lower(opt)
        case 'ok',
            [expe, options] = emotion_build_conditions(options);
        case 'cancel'
            return
        otherwise
            error('Unknown option: %s',opt)
    end
else
    opt = char(questdlg(sprintf('Found "%s". Use this file?', options.res_filename), options.experiment_label,'OK','Cancel','OK'));
    if strcmpi(opt, 'Cancel')
        return
    end
end

load(options.res_filename); % options, expe, results

if isempty(phase)
    phases = {'training', 'test'};
    for i=1:length(phases)
       phase = phases{i};
       if any([expe.(phase).trials.done]~=1)    
           break
       end
    end
end

emotion_main(options, phase);

%{
% EG: We don't have cues in this new version.

% cue is normalized and phase is training + test
cue = {'normalized'};
phase = {'training', 'test'};

if strcmp(participant.name, 'test')
    for icue = 1 : length(cue)
        for iphase = 1 : length(phase)
            fprintf('I am running %s %s %s\n', participant.name, phase{iphase}, cue{icue})
            emotion_main(participant.name, phase{iphase}, cue{icue});
        end
    end
else
    switch participant.kidsOrAdults
        case 'adult'
            for icue = 1 : length(cue)
                for iphase = 1 : length(phase)
                    fprintf('I am running %s %s %s\n', participant.name, phase{iphase}, cue{icue})
                    emotion_main(participant.name, phase{iphase}, cue{icue});
                end
            end
        case 'kid'
            for iphase = 1 : length(phase)
                fprintf('I am running %s %s %s\n', participant.name, phase{iphase}, cue{1})
                emotion_main(participant.name, phase{iphase}, cue{1});
            end
        otherwise
            fprintf('I do not recognize the option %s for participant.kidsOrAdults', participant.kidsOrAdults)
            return
    end
end
%}




% remove paths
for ipath = 1 : length(paths2Add)
    rmpath(paths2Add{ipath});
end
    
    
end % end of the function emotion_run