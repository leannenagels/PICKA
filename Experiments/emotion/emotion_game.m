function [G, Buttons, gameCommands, Confetti, Parrot, ...
    Pool, Clownladder, Splash, ladder_jump11, clown_jump11, Drops, ExtraClown] = emotion_game(options)

%EMOTION_GAME(OPTIONS)
%   Sets up the video game for the PICKA Emotion experiment.

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

    if nargin<1
        options = emotion_options();
    end

    fig = findobj; %get(groot,'CurrentFigure');
    for item = 1 : length(fig)
        if isa(fig(item), 'matlab.ui.Figure') && ~strcmp(get(fig(item), 'Name'), 'testRunner')
            close(fig(item))
        end
    end
    clear fig
    
    [~, screen2] = getScreens();
    fprintf('Experiment will be displayed on: [%s]\n', sprintf('%d ',screen2));

    G = SpriteKit.Game.instance('Title','Emotion Game', 'Size', screen2(3:4), 'Location', screen2(1:2), 'ShowFPS', false);
    
    % EG: Make sure the figure is fullscreen on Windows
    set(G.FigureHandle, 'Unit', 'normalized', 'outerPosition', [0,0,1,1]);
    set(G.FigureHandle, 'Unit', 'pixel');
    
    img_background = resizeBackgroundToScreenSize(screen2, fullfile(options.locationImages, 'circusbackground_unscaled.png'), 'fill');
    SpriteKit.Background(img_background);
    addBorders(G);
    
%%   Parrot 
    Parrot = SpriteKit.Sprite('parrot');
    Parrot.initState('neutral', fullfile(options.locationImages, 'parrot_neutral.png'), true);
    Parrot.initState('off', ones(1,1,3), true);
    for iParrot = 1:2
        spritename = sprintf('parrot_%d',iParrot);
        pngFile = fullfile(options.locationImages, [spritename '.png']);
        Parrot.initState(spritename, pngFile, true);
    end
    for iparrotshake = 1:3
        spritename = sprintf('parrot_shake_%d', iparrotshake);
        pngFile = fullfile(options.locationImages, [spritename '.png']);
        Parrot.initState(spritename, pngFile, true);
    end

    Parrot.Location = [screen2(3)/2.2, screen2(4)/1.8];
    Parrot.State = 'off'; 
    Parrot.Depth = 2;
    %{
    clickArea = size(imread(fullfile(options.locationImages, 'parrot_1.png')));
    addprop(Parrot, 'clickL');
    addprop(Parrot, 'clickR');
    addprop(Parrot, 'clickD');
    addprop(Parrot, 'clickU');
    Parrot.clickL = round(Parrot.Location(1) - round(clickArea(1)/2));
    Parrot.clickR = round(Parrot.Location(1) + round(clickArea(1)/2));
    Parrot.clickD = round(Parrot.Location(2) - round(clickArea(2)/4));
    Parrot.clickU = round(Parrot.Location(2) + round(clickArea(2)/4));
    %}

%%   Buttons
    
    % Where the response clowns are located
    button_locations = 1./[8.33, 2.85, 1.7];
    
    if isfield(options, 'order_button_emotions')
        button_locations = button_locations(options.order_button_emotions);
    else
        warning('The field "order_response_clowns" is not defined in options. Keeping the clowns in default order');
    end

    %% Joy button
    ButtonJoy = SpriteKit.Sprite('happy'); 
    ButtonJoy.initState ('on', fullfile(options.locationImages, 'clownemo_happy.png'), true);
    ButtonJoy.initState('press', fullfile(options.locationImages, 'clownemo_happy_press.png'), true)
    ButtonJoy.initState ('off', ones(1,1,3), true); 
    ButtonJoy.Location = [screen2(3)*button_locations(1), screen2(4)/6];
    ButtonJoy.State = 'off';
    ButtonJoy.Depth = 2;
    %{
    [HeightButtonHappy, WidthButtonHappy] = size(imread(fullfile(options.locationImages, 'clownemo_3.png')));
    addprop(ButtonJoy, 'clickL');
    addprop(ButtonJoy, 'clickR');
    addprop(ButtonJoy, 'clickD');
    addprop(ButtonJoy, 'clickU');
    ButtonJoy.clickL = round(ButtonJoy.Location(1) - round(HeightButtonHappy/2));
    ButtonJoy.clickR = round(ButtonJoy.Location(1) + round(HeightButtonHappy/2));
    ButtonJoy.clickD = round(ButtonJoy.Location(2) - round(WidthButtonHappy/2));
    ButtonJoy.clickU = round(ButtonJoy.Location(2) + round(WidthButtonHappy/2));
    %}
    
    %% Sad button 
    ButtonSad = SpriteKit.Sprite('sad'); 
    ButtonSad.initState ('on', fullfile(options.locationImages, 'clownemo_sad.png'), true);
    ButtonSad.initState ('press', fullfile(options.locationImages, 'clownemo_sad_press.png'), true);
    ButtonSad.initState ('off', ones(1,1,3), true);
    ButtonSad.Location = [screen2(3)*button_locations(2), screen2(4)/6];
    ButtonSad.State = 'off';
    %{
    [HeightButtonSad, WidthButtonSad] = size(imread ([options.locationImages 'clownemo_2.png']));
    addprop(ButtonSad, 'clickL');
    addprop(ButtonSad, 'clickR');
    addprop(ButtonSad, 'clickD');
    addprop(ButtonSad, 'clickU');
    ButtonSad.clickL = round(ButtonSad.Location(1) - round(HeightButtonSad/2));
    ButtonSad.clickR = round(ButtonSad.Location(1) + round(HeightButtonSad/2));
    ButtonSad.clickD = round(ButtonSad.Location(2) - round(WidthButtonSad/2));
    ButtonSad.clickU = round(ButtonSad.Location(2) + round(WidthButtonSad/2));
    %}
    ButtonSad.Depth = 2;

    %% Angry button
    ButtonAngry = SpriteKit.Sprite('angry'); 
    ButtonAngry.initState ('on', fullfile(options.locationImages, 'clownemo_angry.png'), true);
    ButtonAngry.initState ('press', fullfile(options.locationImages, 'clownemo_angry_press.png'), true);
    ButtonAngry.initState ('off', ones(1,1,3), true);
    ButtonAngry.Location = [screen2(3)*button_locations(3), screen2(4)/6];
    ButtonAngry.State = 'off';
    %{
    [HeightButtonAngry, WidthButtonAngry] = size(imread ([options.locationImages 'clownemo_1.png']));
    addprop(ButtonAngry, 'clickL');
    addprop(ButtonAngry, 'clickR');
    addprop(ButtonAngry, 'clickD');
    addprop(ButtonAngry, 'clickU');
    ButtonAngry.clickL = round(ButtonAngry.Location(1) - round(HeightButtonAngry/2));
    ButtonAngry.clickR = round(ButtonAngry.Location(1) + round(HeightButtonAngry/2));
    ButtonAngry.clickD = round(ButtonAngry.Location(2) - round(WidthButtonAngry/2));
    ButtonAngry.clickU = round(ButtonAngry.Location(2) + round(WidthButtonAngry/2));
    %}
    ButtonAngry.Depth = 2;
    
    Buttons = {ButtonAngry, ButtonJoy, ButtonSad}; % Order does not matter: the emotion is identified through the ID property
    
    % confetti/feedback
    Confetti = SpriteKit.Sprite('confetti');
    Confetti.initState('off', ones(1,1,3), true);
    for iConfetti = 1:7
        spritename = sprintf('confetti_%d',iConfetti);
        pngFile = fullfile(options.locationImages, [spritename, '.png']);
        Confetti.initState(spritename, pngFile, true);
    end
    Confetti.Location = [screen2(3)/2.5, screen2(4)-350];
    Confetti.State = 'off';
    Confetti.Scale = 1.4; 
    Confetti.Depth = 5;
    
%   start and finish button    
    gameCommands = SpriteKit.Sprite('controls');
    initState(gameCommands, 'begin', fullfile(options.locationImages, 'start1.png'), true);
    initState(gameCommands, 'finish', fullfile(options.locationImages, 'finish1.png') , true);
    initState(gameCommands, 'empty', ones(1,1,3), true); % to replace the images, 'none' will give an annoying warning
    gameCommands.State = 'begin';
    gameCommands.Location = [screen2(3)/2, screen2(4)/2];
    gameCommands.Scale = .9;
    
    % define clicking areas
    %{
    clickArea = size(imread([options.locationImages 'start1.png']));
    addprop(gameCommands, 'clickL');
    addprop(gameCommands, 'clickR');
    addprop(gameCommands, 'clickD');
    addprop(gameCommands, 'clickU');
    gameCommands.clickL = round(gameCommands.Location(1) - round(clickArea(1)/2));
    gameCommands.clickR = round(gameCommands.Location(1) + round(clickArea(1)/2));
    gameCommands.clickD = round(gameCommands.Location(2) - round(clickArea(2)/4));
    gameCommands.clickU = round(gameCommands.Location(2) + round(clickArea(2)/4));
    clear clickArea
    %}
    gameCommands.Depth = 10;   

%%  swimming pool 
    Pool = SpriteKit.Sprite('pool');
    Pool.initState('pool', fullfile(options.locationImages, 'pool.png'), true);
    Pool.initState('empty', ones(1,1,3), true);
    Pool.Location = [screen2(3)/1.11, screen2(4)/3.7];
    Pool.State = 'empty';
    Pool.Depth = 1;
    %{
    clickArea = size(imread([options.locationImages 'pool.png']));
    addprop(Pool, 'clickL');
    addprop(Pool, 'clickR');
    addprop(Pool, 'clickD');
    addprop(Pool, 'clickU');
    Pool.clickL = round(Pool.Location(1) - round(clickArea(1)/2));
    Pool.clickR = round(Pool.Location(1) + round(clickArea(1)/2));
    Pool.clickD = round(Pool.Location(2) - round(clickArea(2)/4));
    Pool.clickU = round(Pool.Location(2) + round(clickArea(2)/4));
    %}
    
    %%      Splash 
    Splash = SpriteKit.Sprite('splash');
    Splash.initState ('empty', ones(1,1,3), true);
    for isplash = 1:3
        spritename = sprintf('sssplash_%d', isplash);
        pngFile = fullfile(options.locationImages, [spritename '.png']); 
        Splash.initState (spritename, pngFile,true);
    end
    Splash.State = 'empty';
    Splash.Location = [screen2(3)/1.2 screen2(4)/2.5];
    Splash.Depth = 6;
    
    %%       Drops 
    Drops = SpriteKit.Sprite('splashdrops');
    Drops.initState ('empty', ones(1,1,3), true);
    for idrop = 1:2
        spritename = sprintf('sssplashdrops_%d', idrop);
        pngFile = fullfile(options.locationImages, [spritename '.png']);
        Drops.initState (spritename, pngFile, true);
    end
    Drops.State = 'empty';
    Drops.Location = [screen2(3)/2.2 screen2(4)/1.9];
    Drops.Depth = 8;
      
    %%  Clownladder 
    Clownladder = SpriteKit.Sprite('clownladder');
    Clownladder.initState('empty', ones(1,1,3), true);
    Clownladder.initState('ground', fullfile(options.locationImages, 'clownladder_0a.png'), true);
    Clownladder.State = 'empty';
    Clownladder.Location = [screen2(3)/1.26, screen2(4)/1.40];% screen2(3)/1.26 for sony 1.28 for maclaptop
    Clownladder.Depth = 5;
    let = {'a','b'};
    for iladder = 0:7
        for ilett=1:2
            spritename = sprintf('clownladder_%d%c',iladder,let{ilett});
            pngFile = fullfile(options.locationImages, [spritename '.png']);
            Clownladder.initState(spritename, pngFile, true);
        end
    end
    Clownladder.initState('end', fullfile(options.locationImages, 'clownladder_jump_12.png'), true);
    for ijump = 1:11
        spritename = sprintf('clownladder_jump_%d',ijump);
        pngFile = fullfile(options.locationImages, [spritename '.png']);
        Clownladder.initState(spritename, pngFile, true);
    end
    
    ExtraClown = SpriteKit.Sprite('extraclown');
    ExtraClown.initState('empty', ones(1,1,3), true);
    ExtraClown.initState('on', fullfile(options.locationImages, 'clown_back.png'), true);
    ExtraClown.State = 'empty';
    ExtraClown.Location = [screen2(3)/1.6, screen2(4)/1.7];
    ExtraClown.Scale = 0.8;
    ExtraClown.Depth = 2;
    
    %% last splash
    spritename = sprintf('ladder_jump_11');
    pngFile = fullfile(options.locationImages, [spritename '.png']);
    ladder_jump11 = SpriteKit.Sprite('ladder_jump11');
    ladder_jump11.initState('empty', ones(1,1,3), true);
    ladder_jump11.initState(spritename, pngFile, true);
    ladder_jump11.Location = [screen2(3)/1.26, screen2(4)/1.40];
    ladder_jump11.Depth = 5;
    
    spritename = sprintf('clown_jump_11');
    pngFile = fullfile(options.locationImages, [spritename '.png']);
    clown_jump11 = SpriteKit.Sprite('clown_jump11');
    clown_jump11.initState('empty', ones(1,1,3), true);
    clown_jump11.initState(spritename, pngFile, true);
    clown_jump11.Location = [screen2(3)/1.26, screen2(4)/1.40];
    clown_jump11.Depth = 7;
end