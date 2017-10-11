function [G, gameElements, gameCommands] = setUpGame(maxTurns, friendsTypes, targetScale, options)
%function [G, bkg, bigFish, bubbles, screen2, gameCommands, hourglass] = setUpGame(maxTurns)

    % if there are games other windows than the guy already opened, close them
    fig = findobj;
    for item = 1 : length(fig)
        %if strcmp(class(fig(item)), 'matlab.ui.Figure') && ... 
        % EG: 2017-10-05
        if isa(fig(item), 'matlab.ui.Figure') && ~strcmp(get(fig(item), 'Name'), 'testRunner')
            close(fig(item))
        end
                
    end
    clear fig
    
    gameElements = struct();
    
    %% introduce the animation bit
        
    [~, screen2] = getScreens();
    fprintf('Experiment will displayed on: [%s]\n', sprintf('%d ',screen2));
    % Start a new Game on screen 2
    G = SpriteKit.Game.instance('Title','Fishy Game', 'Size', screen2(3:4), 'Location', screen2(1:2), 'ShowFPS', false);
    %EG: 2017-10-10, make sure it is fullscreen on Windows
    set(G.FigureHandle, 'Unit', 'normalized', 'outerPosition', [0,0,1,1]);
    bkg = SpriteKit.Background(resizeBackgroundToScreenSize(screen2, fullfile(options.locationImages, 'BACKGROUND_unscaled.png')));
    addBorders(G);
    
    %---- Setup the Sprites
    %% Big Fish
    bigFish = SpriteKit.Sprite('fish_1');
    initState(bigFish,'fish_1', fullfile(options.locationImages, 'FISHY_TURN_1.png'), true);
    for k=2:10
        spritename = sprintf('FISHY_TURN_%d',k);
        pngFile = fullfile(options.locationImages, [spritename '.png']);
        initState(bigFish, ['fish_' int2str(k)] , pngFile, true);
    end
    bigFish.Location = [screen2(3)/2, screen2(4)-450];
    
    %% Arches around the big fish
    addprop(bigFish, 'arcAround1'); % arc one contains all same friends
    nFriends = 7;
    [x, y] = getArc(0, pi, bigFish.Location(1), bigFish.Location(2), 220, nFriends);
    bigFish.arcAround1 = round([x;y]);
    addprop(bigFish, 'availableLocArc1');
    bigFish.availableLocArc1 = nFriends : -1 : 1; % ordinatelly set friends from left to right
    % there must be as many sprites of the circles as many circles we want
    circleImageFilename = fullfile(options.locationImages, 'circle.png');
    circleImageInfo = imfinfo(circleImageFilename);
    for iCircle = 1 : nFriends
        friendSlots(iCircle) =  SpriteKit.Sprite('circle');
        friendSlots(iCircle).initState('circle', circleImageFilename, true);
        % EG: 2017-10-06, the friends don't fly to the middle of the arch
        % circles.
        %friendSlots(iCircle).Location = bigFish.arcAround1(:,iCircle)';
        friendSlots(iCircle).Scale = targetScale; % this is to make sure that the circle and the friends on the first arc have equal dimensions
        friendSlots(iCircle).Location = bigFish.arcAround1(:,iCircle)';
        addprop(friendSlots(iCircle), 'Size');
        friendSlots(iCircle).Size = [circleImageInfo.Width, circleImageInfo.Height];
    end
    clear iCircle
    
    %% second arc
    addprop(bigFish, 'arcAround2'); % arc 2 contains the collection of other friends
    nFriends = friendsTypes;
    [x, y] = getArc(pi, 0, bigFish.Location(1), bigFish.Location(2), 350, nFriends);
    bigFish.arcAround2 = [x;y];
    addprop(bigFish, 'availableLocArc2');
    %  bigFish.availableLocArc2 = randperm(nFriends);
    bigFish.availableLocArc2 = 1:nFriends; %nFriends : -1 : 1; % ordinatelly set friends from left to right
    addprop(bigFish, 'iter');
    bigFish.iter = 1;
    addprop(bigFish, 'countTurns');
    bigFish.countTurns = 0;
    
    %% Bubbles
    bubbles = SpriteKit.Sprite('noBubbles');
    bubbles.initState('noBubbles', fullfile(options.locationImages, ['bubbles_none', '.png']), true);
    for k=1:4
        spritename = sprintf('bubbles_%d',k);
        pngFile = fullfile(options.locationImages, [spritename, '.png']);
        bubbles.initState(spritename, pngFile, true);
        bubbles.Depth = 5;
    end
    
    %% Hourglass
    hourglass = SpriteKit.Sprite ('hourglass');
    hourglass.Location = [screen2(3)/1.10, screen2(4)/1.5];
    ratioscreen = 0.3 * screen2(4);
    [HeightHourglass, WidthHourglass] = size(imread (fullfile(options.locationImages, 'hourglass_min_0.png')));
    hourglass.Scale = ratioscreen/HeightHourglass;
    counter = 0;
    nHourGlasses = 18;
    nturns = floor(nHourGlasses / maxTurns);
    for k = 0:nturns:17 
        hourglassname = sprintf('hourglass_%d', counter); 
        pngFile = fullfile(options.locationImages, sprintf('hourglass_min_%d.png', k));
        hourglass.initState(hourglassname, pngFile, true);
        counter = counter + 1;
    end 
    hourglass.State = 'hourglass_0';
    
    addprop(hourglass, 'clickL');
    addprop(hourglass, 'clickR');
    addprop(hourglass, 'clickD');
    addprop(hourglass, 'clickU');
    hourglass.clickL = round(hourglass.Location(1) - round(HeightHourglass/2));
    hourglass.clickR = round(hourglass.Location(1) + round(HeightHourglass/2));
    hourglass.clickD = round(hourglass.Location(2) - round(WidthHourglass/2));
    hourglass.clickU = round(hourglass.Location(2) + round(WidthHourglass/2));

    %% Game commands
    gameCommands = SpriteKit.Sprite('controls');
%     initState(gameCommands, 'none', zeros(2,2,3), true);
    initState(gameCommands, 'begin', fullfile(options.locationImages, 'start.png') , true);
    initState(gameCommands, 'finish',fullfile(options.locationImages, 'finish.png') , true);
    initState(gameCommands, 'empty', ones(1,1,3), true); % to replace the images, 'none' will give an annoying warning
    gameCommands.State = 'begin';
    gameCommands.Location = [screen2(3)/2, screen2(4)/2 + 40];
    gameCommands.Scale = .8; % make it bigger to cover fishy
    % define clicking areas
    clickArea = size(imread(fullfile(options.locationImages, 'start.png')));
    addprop(gameCommands, 'clickL');
    addprop(gameCommands, 'clickR');
    addprop(gameCommands, 'clickD');
    addprop(gameCommands, 'clickU');
    gameCommands.clickL = round(gameCommands.Location(1) - round(clickArea(1)/2));
    gameCommands.clickR = round(gameCommands.Location(1) + round(clickArea(1)/2));
    gameCommands.clickD = round(gameCommands.Location(2) - round(clickArea(2)/2));
    gameCommands.clickU = round(gameCommands.Location(2) + round(clickArea(2)/2));
    clear clickArea 
    
    % EG: We keep explicit reference to friend slots (circles) by returning it as well to access
    % them more easily late.
    % Which sprites we want to make available:
    gameElements.bigFish = bigFish;
    gameElements.bubbles = bubbles;
    gameElements.hourglass = hourglass;
    gameElements.bkg = bkg;
    gameElements.friendSlots = friendSlots;
    
    %% ------   start the GAME
%     iter = 0;
%     G.play(@()action(argin));
%     G.play(@action);
%     pause(1);

    
end % end of the setUpGame function 