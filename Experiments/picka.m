function picka(subject_name)

%TODO: what to do if subject_name is empty, check subject name validity
% subject name format: {nl|gb}_{NH|CI}{A|K}[000]

% We add MatlabCommonTools relatively first to get the GetFullPath
% function, and then we reinclude it with absolute path so it stays when we
% navigate with cd.
addpath('../Resources/lib/MatlabCommonTools');
lib_path_absolute = GetFullPath('../Resources/lib');
rmpath('../Resources/lib/MatlabCommonTools');
addpath(fullfile(lib_path_absolute, 'MatlabCommonTools'));

% Experiments: each experiment is defined by a folder and a prefix for
% function names

PICKA = struct();

i = 1;
PICKA(i).folder = 'fishy';
PICKA(i).prefix = 'fishy';

i = i+1;
PICKA(i).folder = 'CRM';
PICKA(i).prefix = 'expe';

i = i+1;
PICKA(i).folder = 'gender';
PICKA(i).prefix = 'gender';

i = i+1;
PICKA(i).folder = 'emotion';
PICKA(i).prefix = 'emotion';

%------------------------------
% If no subject name was provided, we prompt on the command line

if nargin<1
    subject_name = input('Enter the subject ID: ', 's');
end

%------------------------------
% We get the progress for each experiment

for i=1:length(PICKA)
    cd(PICKA(i).folder);
    try
        fprintf('Reading progress from %s... ', PICKA(i).folder);
        PICKA(i).fx_progress = str2func(sprintf('%s_progress', PICKA(i).prefix));
        [PICKA(i).progress, PICKA(i).phases, PICKA(i).participant] = PICKA(i).fx_progress(subject_name);
        fprintf('%f', PICKA(i).progress);
    catch err
        disp(err);
        disp(err.stack);
    end
    fprintf('\n');
    cd('..');
end


%------------------------------
% GUI

fh = findobj( 'Type', 'Figure', 'Name', 'PICKA');
if ~isempty(fh)
    close(fh);
end

h = figure('Visible', 'off', 'MenuBar', 'none', 'Name', 'PICKA', 'NumberTitle', 'off');

pw = 100; % Panel width
ph = 30; % Panel height

lm = 10; % Left margin
rm = lm; % Right margin
hm = lm; % Horizontal margin
bm = 10; % Bottom margin
tm = bm; % Top margin
vm = bm; % Vertical margin

ncols = 4;
nrows = length(PICKA)+2;

h.Position = [0,0,lm+rm+bm*(ncols-1)+pw*ncols, bm+tm+nrows*(vm+ph)];

h.UserData = struct();

h.UserData.PICKA = PICKA;
h.UserData.subject_name = subject_name;

% Controls
h.UserData.Controls = struct();
h.UserData.Controls.subject_id = uicontrol('Style', 'text', 'String', subject_name, 'FontSize', 14, 'Position', [lm, h.Position(4)-tm-ph, lm*(ncols-1)+pw*ncols, ph], 'HorizontalAlignment', 'center');
for i=1:length(PICKA)
    if ~isfield(PICKA(i), 'participant') || isempty(PICKA(i).participant)
        str = 'New subject';
    else
        str = {};
        if isfield(PICKA(i).participant, 'language')
            str{end+1} = sprintf('Language: %s', PICKA(i).participant.language);
        end
        if isfield(PICKA(i).participant, 'age')
            str{end+1} = sprintf('Age: %s', PICKA(i).participant.age);
        end
        if isempty(str)
            str = 'No information';
        else
            str = implode(', ', str);
        end
    end
end
h.UserData.Controls.subject_info = uicontrol('Style', 'text', 'String', str, 'FontSize', 10, 'Position', [lm, h.Position(4)-tm-ph*2-vm, lm*(ncols-1)+pw*ncols, ph], 'HorizontalAlignment', 'center');

h.UserData.Controls.experiments = struct();
for i=1:length(PICKA)
    h.UserData.Controls.experiments(i).label = uicontrol('Style', 'text', 'String', [upper(PICKA(i).folder(1)), PICKA(i).folder(2:end)], ...
        'FontSize', 12, 'Position', [0, h.Position(4)-tm-ph-(i+1)*(ph+vm), pw, ph], 'HorizontalAlignment', 'right');
    
    if PICKA(i).progress>0
        str = 'Continue';
    else
        str = 'Start';
    end
    h.UserData.Controls.experiments(i).start = uicontrol('Style', 'pushbutton', 'String', str, ...
        'FontSize', 12, 'Position', [pw+hm, h.Position(4)-tm-ph-(i+1)*(ph+vm)+7, pw, ph], 'HorizontalAlignment', 'right', 'Callback', {@start_experiment, i});
    
    h.UserData.Controls.experiments(i).progress = axes('Units', 'pixels', 'Position', [(pw+hm)*2, h.Position(4)-tm-ph-(i+1)*(ph+vm)+7, pw, ph]);
    if isnan(PICKA(i).progress)
        fill([0,1,1,0]*0, [0,0,1,1], [.6, .6, .9]);
        text(.5, .5, 'Not created yet', 'Parent', h.UserData.Controls.experiments(i).progress, 'HorizontalAlignment', 'center');
    else
        fill([0,1,1,0]*PICKA(i).progress, [0,0,1,1], [.6, .6, .9]);
        text(.5, .5, sprintf('%d%%', round(PICKA(i).progress*100)), 'Parent', h.UserData.Controls.experiments(i).progress, 'HorizontalAlignment', 'center');
    end
    h.UserData.Controls.experiments(i).progress.XLim = [0,1];
    h.UserData.Controls.experiments(i).progress.YLim = [0,1];
    h.UserData.Controls.experiments(i).progress.XTick = [];
    h.UserData.Controls.experiments(i).progress.YTick = [];
    h.UserData.Controls.experiments(i).progress.Box = 'on';
    
    h.UserData.Controls.experiments(i).training = [];
    
    for k=1:length(PICKA(i).phases)
        phase = PICKA(i).phases{k};
        if startswith(phase, 'training')
            h.UserData.Controls.experiments(i).training = uicontrol('Style', 'pushbutton', 'String', phase, ...
                'FontSize', 12, 'Position', [(pw+hm)*3, h.Position(4)-tm-ph-(i+1)*(ph+vm)+7, pw, ph], 'HorizontalAlignment', 'right', 'Callback', {@start_experiment, i, phase});
            break
        end
    end
    
    
end

center_figure(h);
h.Visible = 'on';

%======================================================
function start_experiment(src, event, i, phase)

h = src.Parent; % the figure
fprintf('\nRunning %s_run in %s.\n', h.UserData.PICKA(i).prefix, h.UserData.PICKA(i).folder);

if nargin<4
    phase = [];
end

% If phase starts with training and training has been done, then we have to
% reset it.

try
    cd( h.UserData.PICKA(i).folder );
    fx_run = str2func([h.UserData.PICKA(i).prefix, '_run']);
    
    % We try to collect participant information from other experiments
    participant = struct();
    for i=1:length(h.UserData.PICKA)
        participant.name = h.UserData.subject_name;
        if ~isempty(h.UserData.PICKA(i).participant)
            if isfield(h.UserData.PICKA(i).participant, 'language')
                participant.language = h.UserData.PICKA(i).participant.language;
            end
            if isfield(h.UserData.PICKA(i).participant, 'age')
                participant.age = h.UserData.PICKA(i).participant.age;
            end
        end
    end
    
    % If the participant information is incomplete, we start the participant GUI
    addpath('..');
    while ~isfield(participant, 'language') || ~isfield(participant, 'age') || isempty(participant.language) || isempty(participant.age)
        participant = guiParticipantDetails(participant);
    end
    rmpath('..');
    
    % We start the experiment    
    fx_run(participant, phase);
    
catch err
    cd('..');
    err.rethrow();
end
    
cd('..');

%======================================================
function center_figure(h)

p = get(h, 'Position');
s = get(groot, 'ScreenSize');

set(h, 'Position', [s(1)+(s(3)-p(3))/2, s(2)+(s(4)-p(4))/2, p(3:4)]);


