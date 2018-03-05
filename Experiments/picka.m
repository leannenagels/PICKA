function picka(subject_name)

%PICKA(SUBJECT_NAME)
%   Starts the experiment runner for PICKA.
%
%   If no argument is given, the user will be prompted to enter a subject
%   ID on the command line. If the subject name is empty (from the function
%   call or from the command line), the participant's details GUI is
%   started to create a new participant.
%
%   To continue testing an existing participant, their exact ID must be
%   entered.

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2018-05-02
% CNRS UMR 5292, FR | University of Groningen, UMCG, NL
%--------------------------------------------------------------------------

% We add MatlabCommonTools relatively first to get the GetFullPath
% function, and then we reinclude it with absolute path so it stays when we
% navigate with cd.
addpath('../Resources/lib/MatlabCommonTools');
lib_path_absolute = GetFullPath('../Resources/lib');
rmpath('../Resources/lib/MatlabCommonTools');
addpath(fullfile(lib_path_absolute, 'MatlabCommonTools'));

% Experiments: each experiment is defined by a folder and a prefix for
% function names

PICKA = picka_definition();

%------------------------------
% If no subject name was provided, we prompt on the command line

if nargin<1
    subject_name = input('Enter the subject ID: ', 's');
end

%------------------------------
% If the subject name is empty, we create a new subject

if isempty(subject_name)
    fprintf('Creating new participant...\n');
    participant = guiParticipantDetails();
    if isempty(participant.name)
        error('Aborted (participant name is empty).');
    end
    subject_name = participant.name;
    %for k=1:length(PICKA)
    %    PICKA(k).participant = participant;
    %end
else
    participant = struct();
end

%------------------------------
% We get the progress for each experiment

for i=1:length(PICKA)
    cd(PICKA(i).folder);
    try
        fprintf('Reading progress from %s... ', PICKA(i).folder);
        PICKA(i).fx_progress = str2func(sprintf('%s_progress', PICKA(i).prefix));
        [PICKA(i).progress, PICKA(i).phases, PICKA(i).participant, PICKA(i).result_file] = PICKA(i).fx_progress(subject_name);
        fprintf('%f', PICKA(i).progress);
    catch err
        disp(err);
        disp(err.stack);
    end
    fprintf('\n');
    cd('..');
    
    PICKA(i).participant = struct_merge(PICKA(i).participant, participant);
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
            str{end+1} = sprintf('Age: %d', floor(PICKA(i).participant.age));
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
h.UserData.PICKA = PICKA;

%======================================================
function start_experiment(src, event, i, phase)

h = src.Parent; % the figure
fprintf('\nRunning %s_run in %s.\n', h.UserData.PICKA(i).prefix, h.UserData.PICKA(i).folder);

if nargin<4
    phase = [];
end
    
% We try to collect participant information from other experiments
participant = struct();
for k=1:length(h.UserData.PICKA)
    participant.name = h.UserData.subject_name;
    if ~isempty(h.UserData.PICKA(k).participant)
        if isfield(h.UserData.PICKA(k).participant, 'language')
            participant.language = h.UserData.PICKA(k).participant.language;
        end
        if isfield(h.UserData.PICKA(k).participant, 'age')
            participant.age = h.UserData.PICKA(k).participant.age;
        end
        if isfield(h.UserData.PICKA(k).participant, 'sex')
            participant.sex = h.UserData.PICKA(k).participant.sex;
        end
    end
end

% If the participant information is incomplete, we start the participant GUI
while ~isfield(participant, 'language') || ~isfield(participant, 'age') || ~isfield(participant, 'sex') || isempty(participant.language) || isempty(participant.age) || isempty(participant.sex)
    participant = guiParticipantDetails(participant);
end

% If phase starts with training and training has been done, then we have to
% reset it.
if ~isempty(phase)
    
    res_file = fullfile(h.UserData.PICKA(i).folder, h.UserData.PICKA(i).result_file);
    dat = load(res_file);
    r = questdlg(sprintf('Are you sure you want to reset phase "%s" for subject "%s"? This cannot be undone.', phase, participant.name), 'PICKA :: Reset phase', 'yes', 'no', 'no');
    switch r
        case 'no'
            return
        case 'yes'
            if isfield(dat.expe.(phase), 'trials')
                for k=1:length(dat.expe.(phase).trials)
                    dat.expe.(phase).trials(k).done = 0;
                end
            elseif isfield(dat.expe.(phase), 'conditions')
                for k=1:length(dat.expe.(phase).conditions)
                    dat.expe.(phase).conditions(k).done = 0;
                end
            end
            save(res_file, '-struct', 'dat');
            fprintf('Phase "%s" was reset to undone in file "%s".\n', phase, res_file);
    end
end

try
    cd( h.UserData.PICKA(i).folder );
    fx_run = str2func([h.UserData.PICKA(i).prefix, '_run']);
    
    % We start the experiment    
    fx_run(participant, phase);
    
catch err
    cd('..');
    err.rethrow();
    close(h);
end
    
cd('..');

%close(h);
picka(participant.name);

%======================================================
function center_figure(h)

p = get(h, 'Position');
s = get(groot, 'ScreenSize');

set(h, 'Position', [s(1)+(s(3)-p(3))/2, s(2)+(s(4)-p(4))/2, p(3:4)]);


