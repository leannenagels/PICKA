function drawBubbles()

%% Setup the Sprite
[nBubbles, posBubbles, figSize] = makeBubbles_abs(0, 0);
nStatuses = length(nBubbles);

%% Run it!

% the good ratio is 85*225

    % added 10 because otherwise it will cut one of the bubbles up
    figure('PaperUnits','inches','Position', [0, 0, figSize.width, figSize.heigth + 10], 'color','none');
    for statusCounter =  1 : nStatuses
        bubbles = {};

        for iBubbles = 1 : nBubbles(statusCounter)
            bubbles{iBubbles} = rectangle('Curvature', [1 1], 'Position', [posBubbles(statusCounter).b{iBubbles}], 'FaceColor', [0 115 255]./255, ...
                'EdgeColor', [198 241 255]./255, 'LineWidth', 2);
        end
        
        axis([0 figSize.width 0 figSize.heigth + 10]);
        axis off
        daspect([1,1,1]);

        imwrite(print('-RGBImage'), ['bubbles_' num2str(statusCounter) '.png'], 'png', 'transparency', [1 1 1])
        for iBubbles = 1 : nBubbles(statusCounter)
            bubbles{iBubbles}.delete
        end

    end
    
    close all
end