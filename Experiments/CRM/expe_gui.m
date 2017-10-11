function h = expe_gui(options, phase)

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@mrc-cbu.cam.ac.uk> - 2010-03-16
% Medical Research Council, Cognition and Brain Sciences Unit, UK
%
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2017-08-06
% CNRS UMR 5292, FR | University of Groningen, UMCG, NL
%--------------------------------------------------------------------------

% The actual colours and labels are defined in init_colours.m
COLOURS = init_colours();

close all hidden

fntsz = 20;

scrsz = get(0,'ScreenSize');
W = struct();
W.l=scrsz(1); W.b=scrsz(2); W.w=scrsz(3); W.h=scrsz(4);

h = struct();
h.f = figure('Visible', 'off', 'Position', scrsz, 'Menubar', 'none', 'Resize', 'off', 'Color', COLOURS.background_.rgb);

% Progress bar
h.waitbar = axes('Units', 'pixel', 'Position', [W.w*.1, W.h-50, W.w*.8, 25], 'Box', 'on', 'Xtick', [], 'YTick', []);
h.waitbar_legend = uicontrol('Style', 'text', 'Units', 'pixel', 'Position', [W.w*.1, W.h-101, W.w*.8, 50], ...
    'HorizontalAlignment', 'center', 'FontSize', fntsz, 'ForegroundColor', [1 1 1]*.5, 'BackgroundColor', COLOURS.background_.rgb);

% Image
pos = round([W.w*0.05, W.h/2-0.20*W.w/2, 0.20*W.w, 0.20*W.w]);
h.image = axes('Units', 'pixel', 'Position', pos);
image(image_resize(imread(fullfile(options.image_path, options.images{1})), pos(3:4)*2), 'Parent', h.image);
set(h.image, 'Visible', 'off');

% Response grid
hm =100;
h.grid = axes('Units', 'pixel', 'Position', [W.w*.27+hm, W.h*.15, W.w*.70-2*hm, W.h*.70], 'Box', 'on');

for i=1:options.n_colours
    
    colour = COLOURS.(options.target_corpus.colours{i});
    fill([0, 1, 1, 0]*options.n_numbers, [0, 0, 1, 1]+i-1, 'r', 'FaceColor', colour.rgb);
    hold on
    
    for j=1:options.n_numbers
        
        plot([1 1]*j, [0, options.n_colours], '-k');
        h.t(i, j) = text(j-.5, i-.5, int2str(options.target_corpus.numbers(j)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', fntsz+5, 'Color', colour.label.colour);
        
    end
    
    text(options.n_numbers+.2, i-.5, colour.label.(options.language), 'HorizontalAlignment', 'left',  'VerticalAlignment', 'middle', 'FontSize', fntsz, 'Color', colour.rgb*.5+.5);
    text(-.2,                  i-.5, colour.label.(options.language), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', 'FontSize', fntsz, 'Color', colour.rgb*.5+.5);
    
end
hold off
set(h.grid, 'Xtick', [], 'YTick', []);

set(h.f, 'Visible', 'on');
drawnow();

h.fntsz = fntsz+5;

