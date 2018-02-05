function options = fishy_options(options, participant)

options.result_path   ='./results'; 
if ~exist(options.result_path, 'dir')
    mkdir(options.result_path);
end
options.result_prefix = 'jvo_';
options.locationImages = '../../Resources/images/fishy/';

options.path.straight = '../../Resources/lib/STRAIGHTV40_006b';
options.path.tools    = '../../Resources/lib/MatlabCommonTools';
options.path.mksqlite = '../../Resources/lib/mksqlite';
options.path.spritekit = '../../Resources/lib/SpriteKit';

options.experiment_label = 'PICKA :: Fishy';

%options.extendStructures = false; % fishy_build_conditions, if the expe 
% structures or the results structures need to be extended with an 
% additional attempt

if nargin>1
    % The current status of the experiment, number of trial and phase, is
    % written in the log file. Ideally this file should be on the network so
    % that it can be checked remotely. If the file cannot be reached, the
    % program will just continue silently.
    options.log_file = fullfile(options.result_path, 'status.txt');
    options.subject_name = participant.name;
    options.language = participant.language;
    options.subject_age = participant.age;
    options.res_filename = fullfile(options.result_path, sprintf('%s%s.mat', options.result_prefix, options.subject_name));
end