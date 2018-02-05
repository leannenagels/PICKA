function [G, TVScreen, Buttonright, Buttonwrong, Speaker, gameCommands, Hands] = gender_game(options)

    %EG: We don't seem to need straight here...
    %addpath(options.path.straight);
    
    paths2Add = {options.path.spritekit, options.path.tools}; 
    for ipath = 1 : length(paths2Add)
        if ~exist(paths2Add{ipath}, 'dir')
            error([paths2Add{ipath} ' does not exists, check the ../']);
        else
            addpath(paths2Add{ipath});
        end
    end

    
    [~, screen2] = getScreens();
    fprintf('Experiment will be displayed on: [%s]\n', sprintf('%d ', screen2));

    G = SpriteKit.Game.instance('Title','PICKA::Gender', ...
        'Size', [screen2(3), screen2(4)], 'Location', screen2(1:2), ...
        'ShowFPS', false);
    
    % EG: Make sure the figure is fullscreen on Windows
    set(G.FigureHandle, 'Unit', 'normalized', 'outerPosition', [0,0,1,1]);
    set(G.FigureHandle, 'Unit', 'pixel');
    
   % EG: Automatically rescale background (see Fishy)
    %SpriteKit.Background(resizeBackgroundToScreenSize(screen2, fullfile(options.locationImages, 'genderbackgroundleanne_scaled.png')));
    img_background = resizeBackgroundToScreenSize(screen2, fullfile(options.locationImages, 'genderbackground_unscaled.png'), 'fill');
    SpriteKit.Background(img_background);
    addBorders(G);
     
    TVScreen = SpriteKit.Sprite('tvscreen');
    TVScreen.initState('off',  fullfile(options.locationImages, 'TVScreen_black.png'), true); % whole screen green
    for i_noise=1:5
        TVScreen.initState(sprintf('noise_%d', i_noise), fullfile(options.locationImages, sprintf('TVScreen_noise_%d.png', i_noise)), true);
    end
    for iwoman=1:options.test.number_faces
         spritename = sprintf('woman_%d',iwoman);
         pngFile = fullfile(options.locationImages, [spritename '.png']);
         TVScreen.initState(spritename , pngFile, true);
    end
    for iman = 1:options.test.number_faces
        spritename = sprintf('man_%d', iman);
        pngFile = fullfile(options.locationImages, [spritename '.png']);
        TVScreen.initState (spritename, pngFile, true);
    end
    %TVScreen.Location = [screen2(3)/2.015, screen2(4)/1.918]; % KNO
    TVScreen.Location = [screen2(3)/2, screen2(4)/2]; % KNO
    TVScreen.Scale = 1.1;
%     groningen
%     TVScreen.Location = [screen2(3)/2.42, screen2(4)/2.02]; % Debi's
    TVScreen.State = 'off';
    %  TVScreen.Scale = 1.2
    %  ratioscreentvscreen = 0.81 * screen2(3);
    %  [~, WidthTVScreen] = size(imread ([options.locationImages 'TVwoman_1.png'));
    %  [HeightBackground, WidthBackground] = size (imread ([options.locationImages 'genderbackground1_unscaled.png'));
    %  TVScreen.Scale = ratioscreentvscreen/WidthTVScreen;
    
    Speaker = SpriteKit.Sprite('speaker');
    Speaker.initState('off', ones(1,1,3), true);
    Speaker.initState('TVSpeaker_1', fullfile(options.locationImages, ['TVSpeaker_1' '.png']), true);
    Speaker.initState('TVSpeaker_2', fullfile(options.locationImages, ['TVSpeaker_2' '.png']), true);
    %Speaker.Location = [screen2(3)/1.73, screen2(4)/1.91];
    Speaker.Location = [screen2(3)/1.56, screen2(4)/2.3];
    Speaker.Scale = 1.1;
    Speaker.State = 'off';
    
    Buttonright = SpriteKit.Sprite('buttonright');
    Buttonright.initState('on', fullfile(options.locationImages, 'button_right.png'), true);
    Buttonright.initState('press', fullfile(options.locationImages, 'button_right_pressed.png'), true);
    Buttonright.initState('off', ones(1,1,3), true);
    Buttonright.Location = [screen2(3)/1.65, screen2(4)/5.5];
    Buttonright.State = 'off';
    addprop(Buttonright, 'Label');
    Buttonright.Label = 'right';
    %{
    [HeightButtonright, WidthButtonright] = size(imread(fullfile(options.locationImages, 'button_right.png')));
    
    addprop(Buttonright, 'clickL');
    addprop(Buttonright, 'clickR');
    addprop(Buttonright, 'clickD');
    addprop(Buttonright, 'clickU');
    Buttonright.clickL = round(Buttonright.Location(1) - round(WidthButtonright/2));
    Buttonright.clickR = round(Buttonright.Location(1) + round(WidthButtonright/2));
    Buttonright.clickD = round(Buttonright.Location(2) - round(HeightButtonright/2));
    Buttonright.clickU = round(Buttonright.Location(2) + round(HeightButtonright/2));
    %}
    Buttonright.Depth = 2;
    
    Buttonwrong = SpriteKit.Sprite('buttonwrong');
    Buttonwrong.initState('on', fullfile(options.locationImages, 'button_wrong.png'), true);
    Buttonwrong.initState('press', fullfile(options.locationImages, 'button_wrong_pressed.png'), true);
    Buttonwrong.initState('off', ones(1,1,3), true);
    Buttonwrong.Location = [screen2(3)/1.40, screen2(4)/5.5];
    Buttonwrong.State = 'off';
    addprop(Buttonwrong, 'Label');
    Buttonwrong.Label = 'wrong';
    %{
    [HeightButtonwrong, WidthButtonwrong] = size(imread(fullfile(options.locationImages, 'button_wrong.png')));
    addprop(Buttonwrong, 'clickL');
    addprop(Buttonwrong, 'clickR');
    addprop(Buttonwrong, 'clickD');
    addprop(Buttonwrong, 'clickU');
    Buttonwrong.clickL = round(Buttonwrong.Location(1) - round(WidthButtonwrong/2));
    Buttonwrong.clickR = round(Buttonwrong.Location(1) + round(WidthButtonwrong/2));
    Buttonwrong.clickD = round(Buttonwrong.Location(2) - round(HeightButtonwrong/2));
    Buttonwrong.clickU = round(Buttonwrong.Location(2) + round(HeightButtonwrong/2));
    %}
    Buttonwrong.Depth = 2;
    
    gameCommands = SpriteKit.Sprite('controls');
    initState(gameCommands, 'begin', fullfile(options.locationImages, 'start.png'), true);
    initState(gameCommands, 'finish', fullfile(options.locationImages, 'finish.png'), true);
    initState(gameCommands, 'empty', ones(1,1,3), true); % to replace the images, 
    % 'none' will give an annoying warning
    gameCommands.State = 'begin';
    gameCommands.Location = [screen2(3)/2.2, screen2(4)/1.8];
    gameCommands.Scale = 1; % make it bigger to cover fishy
    % define clicking areas
    %{
    clickArea = size(imread(fullfile(options.locationImages, 'start.png')));
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
    
    %     Hands
    Hands = SpriteKit.Sprite('hands');
    Hands.initState('off', ones (1,1,3), true);
    addprop(Hands, 'locHands');
    Hands.locHands{1}  = [screen2(3)/1.6, screen2(4)/1.4];
    for ihandremote = 1:2
        spritename = sprintf('handremote_%d', ihandremote);
        pngFile = fullfile(options.locationImages, [spritename '.png']);
        Hands.initState(spritename, pngFile, true);
    end
    Hands.locHands{2} = [screen2(3)/6.8, screen2(4)/6.8]; % for handremote
    Hands.State = 'off';
    % Hands.Location = [screen2(3)/6.5, screen2(4)/4.5]; % for handremote

end
