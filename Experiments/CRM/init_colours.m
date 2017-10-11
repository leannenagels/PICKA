function COLOURS = init_colours()

COLOURS = struct();

c = 'pink';
COLOURS.(c).rgb = [240, 110, 170]/255;
COLOURS.(c).label.en_gb = c;
COLOURS.(c).label.nl_nl = 'roze';

c = 'black';
COLOURS.(c).rgb = [0, 0, 0]+.1;
COLOURS.(c).label.en_gb = c;
COLOURS.(c).label.nl_nl = 'zwart';

c = 'blue';
COLOURS.(c).rgb = [0, 62, 218]/255;
COLOURS.(c).label.en_gb = c;
COLOURS.(c).label.nl_nl = 'blauw';

c = 'brown';
COLOURS.(c).rgb = [189, 98, 48]/255;
COLOURS.(c).label.en_gb = c;
COLOURS.(c).label.nl_nl = 'bruin';

c = 'green';
COLOURS.(c).rgb = [0, 166, 35]/255;
COLOURS.(c).label.en_gb = c;
COLOURS.(c).label.nl_nl = 'groen';

c = 'red';
COLOURS.(c).rgb = [227, 16, 0]/255;
COLOURS.(c).label.en_gb = c;
COLOURS.(c).label.nl_nl = 'rood';

c = 'white';
COLOURS.(c).rgb = [1, 1, 1];
COLOURS.(c).label.en_gb = c;
COLOURS.(c).label.nl_nl = 'wit';

c = 'yellow';
COLOURS.(c).rgb = [255, 228, 48]/255;
COLOURS.(c).label.en_gb = c;
COLOURS.(c).label.nl_nl = 'geel';

% Determine if text should be black or white
for k=fieldnames(COLOURS)'
    if mean(COLOURS.(k{1}).rgb)>.5
        COLOURS.(k{1}).label.colour = [0,0,0];
    else
        COLOURS.(k{1}).label.colour = [1,1,1];
    end
end

% Other colours for the GUI
COLOURS.background_.rgb = [1, 1, 1]*.2;
% COLOURS.feedback_right_.rgb = [0, .5, 0];
% COLOURS.feedback_wrong_.rgb = [.5, 0, 0];



