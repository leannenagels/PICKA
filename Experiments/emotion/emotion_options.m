function options = emotion_options(options, participant)

%EMOTION_OPTIONS(OPTIONS, PARTICIPANT)
%   Sets basic options for the PICKA Emotion experiment.
%
%   OPTIONS can be an empty structure.
%
%   If PARTICIPANT is provided, then the details of structure are added to
%   OPTIONS.

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
    
% set result path or make dir
options.result_path   ='./results'; 
if ~exist(options.result_path, 'dir')
    mkdir(options.result_path);
end
% result prefix
options.result_prefix = 'emo_';

% image directory
options.locationImages = '../../Resources/images/emotion/';

% relevant pathways
options.path.straight  = '../../Resources/lib/STRAIGHTV40_006b';
options.path.tools     = '../../Resources/lib/MatlabCommonTools';
options.path.mksqlite  = '../../Resources/lib/mksqlite';
options.path.spritekit = '../../Resources/lib/SpriteKit';

options.experiment_label = 'PICKA :: Emotion';

% if gui has input
 if nargin>1
    options.subject_name = participant.name;
    options.language = participant.language;
    options.subject_age = participant.age;
    options.subject_sex = participant.sex;
    options.res_filename = fullfile(options.result_path, sprintf('%s%s.mat', options.result_prefix, options.subject_name));
end