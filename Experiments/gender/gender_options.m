function options = gender_options(options)

    options.path.tools    = '../../Resources/lib/MatlabCommonTools';
    options.path.mksqlite = '../../Resources/lib/mksqlite';
    options.path.straight = '../../Resources/lib/STRAIGHTV40_006b';
    options.path.spritekit = '../../Resources/lib/SpriteKit';
    
    % EG: This should not be set here, but in the main
    %volume = SoundVolume(.36);
    
    options.locationImages = '../../Resources/images/gender/';
    
    options.result_path   ='./results'; 
    if ~exist(options.result_path, 'dir')
        mkdir(options.result_path);
    end
    options.result_prefix = 'gen_';
    
    options.sound_path = '../../Resources/sounds/gender/';
    options.tmp_path   = '../../Resources/tmp/gender/';
    
    options.experiment_label = 'PICKA :: Gender';

    % EG: isempty does not work here
    %if isempty(dir(options.sound_path))
    %    error('options.sound_path cannot be empty');
    %end
    
    if ~exist(options.tmp_path, 'dir')
        mkdir(options.tmp_path);
    end
    
%     if isempty(dir(options.tmp_path)) && ~strcmp(options.stage, 'generation')
%         opt = char(questdlg('Running experiment without preprocessing sounds?','CRM','yes','no','no'));
%         switch opt
%             case 'yes'
%                 warning('This will slow down your experiment substantially, press ctrl+c if unhappy')
%             case 'no'
%                 warning('call gender_run(''gen'') to generate the stimuli before running the exp')
%                 return
%         end
%         
%     end
    
    % The current status of the experiment, number of trial and phase, is
    % written in the log file. Ideally this file should be on the network so
    % that it can be checked remotely. If the file cannot be reached, the
    % program will just continue silently.
    options.log_file = fullfile('results', 'status.txt');
   
end
