function [G, ButtonJoy, ButtonSad, ButtonAngry, gameCommands, Confetti, Parrot, ...
    Pool, Clownladder, Splash, ladder_jump11, clown_jump11, Drops, ExtraClown] = emotion_game

    fig = findobj; %get(groot,'CurrentFigure');
    for item = 1 : length(fig)
        if strcmp(class(fig(item)), 'matlab.ui.Figure') && ...
                ~strcmp(get(fig(item), 'Name'), 'testRunner')
            close(fig(item))
                
        end
                
    end
    clear fig
    
    
    [~, screen2] = getScreens();
    fprintf('Experiment will displayed on: [%s]\n', sprintf('%d ',screen2));

    G = SpriteKit.Game.instance('Title','Emotion Game', 'Size', screen2(3:4), 'Location', screen2(1:2), 'ShowFPS', false);
    
    options = emotion_options;
    addpath('../lib/MatlabCommonTools/');
    SpriteKit.Background(resizeBackgroundToScreenSize(screen2, [options.locationImages 'circusbackground_unscaled.png']));
    rmpath('../lib/MatlabCommonTools/');
    addBorders(G);
%     bkg.Depth = -1;
    
%     Clown = SpriteKit.Sprite('clown');
%     Clown.initState('angry', [options.locationImages 'clownemo_1' '.png'], true);
%     Clown.initState('sad', [options.locationImages 'clownemo_2' '.png'], true);
%     Clown.initState('joyful', [options.locationImages 'clownemo_3' '.png'], true);
%     Clown.initState('neutral', [options.locationImages 'clown_neutral' '.png'], true);
%     Clown.initState('off', ones(1,1,3), true);
%     % SpotLight
%     for iClown = 1:5
%         spritename = sprintf('clownSpotLight_%d',iClown);
%         pngFile = [options.locationImages '' spritename '.png'];
%         Clown.initState(spritename, pngFile, true);
%     end
% %   Clown.Location = [screen2(3)/5.5, screen2(4)/3.2]; 
%     [HeightClown, WidthClown, ~] = size(imread([options.locationImages 'clownSpotLight_1.png'])); 
%     Clown.Location = [round(G.Size(1) /25 + WidthClown/2), round(HeightClown/2) + G.Size(2)/35]; 
%     Clown.State = 'off';
%     Clown.Scale = 1.1;
%     Clown.Depth = 1;
%     %ratioscreenclown = 0.25 * screen2(4);
%     %[HeightClown, ~] = size(imread ([options.locationImages 'clownfish_1.png'));
%     %Clown.Scale = ratioscreenclown/HeightClown;
%     clickArea = size(imread([options.locationImages 'clownSpotLight_1.png']));
%     addprop(Clown, 'clickL');
%     addprop(Clown, 'clickR');
%     addprop(Clown, 'clickD');
%     addprop(Clown, 'clickU');
%     Clown.clickL = round(Clown.Location(1) - round(clickArea(1)/2));
%     Clown.clickR = round(Clown.Location(1) + round(clickArea(1)/2));
%     Clown.clickD = round(Clown.Location(2) - round(clickArea(2)/4));
%     Clown.clickU = round(Clown.Location(2) + round(clickArea(2)/4));
    
%       Parrot 
    Parrot = SpriteKit.Sprite ('parrot');
    Parrot.initState('neutral', [options.locationImages 'parrot_neutral' '.png'], true);
    Parrot.initState('off', ones(1,1,3), true);
    for iParrot = 1:2
        spritename = sprintf('parrot_%d',iParrot);
        pngFile = [options.locationImages '' spritename '.png'];
        Parrot.initState(spritename, pngFile, true);
    end
    for iparrotshake = 1:3
        spritename = sprintf('parrot_shake_%d', iparrotshake);
        pngFile = [options.locationImages '' spritename '.png'];
        Parrot.initState(spritename, pngFile, true);
    end
    % Parrot.Scale = 0.8;
    Parrot.Location = [screen2(3)/2.2, screen2(4)/1.8];
    Parrot.State = 'off'; 
    Parrot.Depth = 2;
    clickArea = size(imread([options.locationImages 'parrot_1.png']));
    addprop(Parrot, 'clickL');
    addprop(Parrot, 'clickR');
    addprop(Parrot, 'clickD');
    addprop(Parrot, 'clickU');
    Parrot.clickL = round(Parrot.Location(1) - round(clickArea(1)/2));
    Parrot.clickR = round(Parrot.Location(1) + round(clickArea(1)/2));
    Parrot.clickD = round(Parrot.Location(2) - round(clickArea(2)/4));
    Parrot.clickU = round(Parrot.Location(2) + round(clickArea(2)/4));

%   Buttons 
    ButtonJoy = SpriteKit.Sprite ('joyful'); 
    ButtonJoy.initState ('on', [options.locationImages 'clownemo_3.png'], true);
    ButtonJoy.initState('press', [options.locationImages 'clownemo_3b.png'], true)
    ButtonJoy.initState ('off', ones(1,1,3), true); 
    ButtonJoy.Location = [screen2(3)/8.33, screen2(4)/6];
    ButtonJoy.State = 'off';
    [HeightButtonHappy, WidthButtonHappy] = size(imread ([options.locationImages 'clownemo_3.png']));
    % ratioscreenbuttons = 0.2 * screen2(4);
    % [HeightButtons, ~] = size(imread ([options.locationImages 'buttons_1.png'));
    % Buttonup.Scale = 0.5;
    
    addprop(ButtonJoy, 'clickL');
    addprop(ButtonJoy, 'clickR');
    addprop(ButtonJoy, 'clickD');
    addprop(ButtonJoy, 'clickU');
    ButtonJoy.clickL = round(ButtonJoy.Location(1) - round(HeightButtonHappy/2));
    ButtonJoy.clickR = round(ButtonJoy.Location(1) + round(HeightButtonHappy/2));
    ButtonJoy.clickD = round(ButtonJoy.Location(2) - round(WidthButtonHappy/2));
    ButtonJoy.clickU = round(ButtonJoy.Location(2) + round(WidthButtonHappy/2));
    ButtonJoy.Depth = 2;
    
    ButtonSad = SpriteKit.Sprite ('sad'); 
    ButtonSad.initState ('on', [options.locationImages 'clownemo_2.png'], true);
    ButtonSad.initState ('press', [options.locationImages 'clownemo_2b.png'], true);
    ButtonSad.initState ('off', ones(1,1,3), true);
    ButtonSad.Location = [screen2(3)/2.85, screen2(4)/6];
    ButtonSad.State = 'off';
    [HeightButtonSad, WidthButtonSad] = size(imread ([options.locationImages 'clownemo_2.png']));
    % ratioscreenbuttons = 0.2 * screen2(4);
    % [HeightButtons, ~] = size(imread ([options.locationImages 'buttons_1.png'));
    % Buttondown.Scale = 0.5;
    
    addprop(ButtonSad, 'clickL');
    addprop(ButtonSad, 'clickR');
    addprop(ButtonSad, 'clickD');
    addprop(ButtonSad, 'clickU');
    ButtonSad.clickL = round(ButtonSad.Location(1) - round(HeightButtonSad/2));
    ButtonSad.clickR = round(ButtonSad.Location(1) + round(HeightButtonSad/2));
    ButtonSad.clickD = round(ButtonSad.Location(2) - round(WidthButtonSad/2));
    ButtonSad.clickU = round(ButtonSad.Location(2) + round(WidthButtonSad/2));
    ButtonSad.Depth = 2;

    ButtonAngry = SpriteKit.Sprite ('angry'); 
    ButtonAngry.initState ('on', [options.locationImages 'clownemo_1.png'], true);
    ButtonAngry.initState ('press', [options.locationImages 'clownemo_1b.png'], true);
    ButtonAngry.initState ('off', ones(1,1,3), true);
    ButtonAngry.Location = [screen2(3)/1.7, screen2(4)/6];
    ButtonAngry.State = 'off';
    [HeightButtonAngry, WidthButtonAngry] = size(imread ([options.locationImages 'clownemo_1.png']));
    % ratioscreenbuttons = 0.2 * screen2(4);
    % [HeightButtons, ~] = size(imread ([options.locationImages 'buttons_1.png'));
    % Buttondown.Scale = 0.5;
    
    addprop(ButtonAngry, 'clickL');
    addprop(ButtonAngry, 'clickR');
    addprop(ButtonAngry, 'clickD');
    addprop(ButtonAngry, 'clickU');
    ButtonAngry.clickL = round(ButtonAngry.Location(1) - round(HeightButtonAngry/2));
    ButtonAngry.clickR = round(ButtonAngry.Location(1) + round(HeightButtonAngry/2));
    ButtonAngry.clickD = round(ButtonAngry.Location(2) - round(WidthButtonAngry/2));
    ButtonAngry.clickU = round(ButtonAngry.Location(2) + round(WidthButtonAngry/2));
    ButtonAngry.Depth = 2;
    
    %      Confetti/Feedback
    Confetti = SpriteKit.Sprite ('confetti');
    Confetti.initState ('off', ones(1,1,3), true);
    for iConfetti = 1:7
        spritename = sprintf('confetti_%d',iConfetti);
        pngFile = [options.locationImages '' spritename '.png'];
        Confetti.initState(spritename, pngFile, true);
    end
    Confetti.Location = [screen2(3)/2.5, screen2(4)-350];
    Confetti.State = 'off';
    Confetti.Scale = 1.4; 
    Confetti.Depth = 5;
    
%      Start and finish     
    gameCommands = SpriteKit.Sprite('controls');
    initState(gameCommands, 'begin',[options.locationImages 'start1.png'] , true);
    initState(gameCommands, 'finish',[options.locationImages 'finish1.png'] , true);
    initState(gameCommands, 'empty', ones(1,1,3), true); % to replace the images, 'none' will give an annoying warning
    gameCommands.State = 'begin';
    gameCommands.Location = [screen2(3)/2, screen2(4)/2];
    gameCommands.Scale = 1.3; % make it bigger to cover fishy
    % define clicking areas
    clickArea = size(imread([options.locationImages 'start.png']));
    addprop(gameCommands, 'clickL');
    addprop(gameCommands, 'clickR');
    addprop(gameCommands, 'clickD');
    addprop(gameCommands, 'clickU');
    gameCommands.clickL = round(gameCommands.Location(1) - round(clickArea(1)/2));
    gameCommands.clickR = round(gameCommands.Location(1) + round(clickArea(1)/2));
    gameCommands.clickD = round(gameCommands.Location(2) - round(clickArea(2)/4));
    gameCommands.clickU = round(gameCommands.Location(2) + round(clickArea(2)/4));
    clear clickArea 
    gameCommands.Depth = 10;   

%      Pool 
    Pool = SpriteKit.Sprite ('pool');
    Pool.initState('pool',[options.locationImages 'pool.png'], true);
    Pool.initState('empty', ones(1,1,3), true);
    Pool.Location = [screen2(3)/1.11, screen2(4)/3.7];
    Pool.State = 'empty';
    Pool.Depth = 1;
    clickArea = size(imread([options.locationImages 'pool.png']));
    addprop(Pool, 'clickL');
    addprop(Pool, 'clickR');
    addprop(Pool, 'clickD');
    addprop(Pool, 'clickU');
    Pool.clickL = round(Pool.Location(1) - round(clickArea(1)/2));
    Pool.clickR = round(Pool.Location(1) + round(clickArea(1)/2));
    Pool.clickD = round(Pool.Location(2) - round(clickArea(2)/4));
    Pool.clickU = round(Pool.Location(2) + round(clickArea(2)/4));
    %%      Splash 
    Splash = SpriteKit.Sprite ('splash');
    Splash.initState ('empty', ones(1,1,3), true);
    for isplash = 1:3
        spritename = sprintf('sssplash_%d', isplash);
        pngFile = [options.locationImages '' spritename '.png']; 
        Splash.initState (spritename, pngFile,true);
    end
    Splash.State = 'empty';
    Splash.Location = [screen2(3)/1.2 screen2(4)/2.5];
    Splash.Depth = 6;
    
    %%       Drops 
    Drops = SpriteKit.Sprite ('splashdrops');
    Drops.initState ('empty', ones(1,1,3), true);
    for idrop = 1:2
        spritename = sprintf('sssplashdrops_%d', idrop);
        pngFile = [options.locationImages '' spritename '.png'];
        Drops.initState (spritename, pngFile, true);
    end
    Drops.State = 'empty';
    Drops.Location = [screen2(3)/2.2 screen2(4)/1.9];
    Drops.Depth = 8;
      
    %%  Clownladder 
    Clownladder = SpriteKit.Sprite ('clownladder');
    Clownladder.initState ('empty', ones(1,1,3), true);
    Clownladder.initState ('ground', [options.locationImages 'clownladder_0a.png'], true);
    Clownladder.State = 'empty';
    Clownladder.Location = [screen2(3)/1.26, screen2(4)/1.40];% screen2(3)/1.26 for sony 1.28 for maclaptop
    Clownladder.Depth = 5;
    let = {'a','b'};
    for iladder = 0:7
        for ilett=1:2
            spritename = sprintf('clownladder_%d%c',iladder,let{ilett});
            pngFile = [options.locationImages '' spritename '.png'];
            Clownladder.initState(spritename, pngFile, true);
        end
    end
    Clownladder.initState ('end', [options.locationImages 'clownladder_jump_12.png'], true);
    for ijump = 1:11
        spritename = sprintf('clownladder_jump_%d',ijump);
        pngFile = [options.locationImages '' spritename '.png'];
        Clownladder.initState (spritename, pngFile, true);
    end
    
    ExtraClown = SpriteKit.Sprite ('extraclown');
    ExtraClown.initState ('empty', ones(1,1,3), true);
    ExtraClown.initState ('on', [options.locationImages 'clown_back.png'], true);
    ExtraClown.State = 'empty';
    ExtraClown.Location = [screen2(3)/1.6, screen2(4)/1.7];
    ExtraClown.Scale = 0.8;
    ExtraClown.Depth = 2;
    
    %% last splash
    spritename = sprintf('ladder_jump_11');
    pngFile = [options.locationImages '' spritename '.png'];
    ladder_jump11 = SpriteKit.Sprite ('ladder_jump11');
    ladder_jump11.initState ('empty', ones(1,1,3), true);
    ladder_jump11.initState (spritename, pngFile, true);
    ladder_jump11.Location = [screen2(3)/1.26, screen2(4)/1.40];
    ladder_jump11.Depth = 5;
    spritename = sprintf('clown_jump_11');
    pngFile = [options.locationImages '' spritename '.png'];
    clown_jump11 = SpriteKit.Sprite ('clown_jump11');
    clown_jump11.initState ('empty', ones(1,1,3), true);
    clown_jump11.initState (spritename, pngFile, true);
    clown_jump11.Location = [screen2(3)/1.26, screen2(4)/1.40];
    clown_jump11.Depth = 7;
end