function [participant] = guiParticipantDetails(participant)

if nargin<1
    participant = struct();
    participant.name = '';
    participant.age = 0;
    participant.sex = 'f'; % 'm' or 'f'
    participant.language = 'nl'; % 'nl or 'en'

    % participant.expDir = {'NVA', 'fishy', 'emotion', 'MCI', 'gender', 'sos'};
    participant.expDir = {'fishy', 'emotion', 'gender', 'sos'};

    participant.kidsOrAdults = 'kid';

    % IS THIS A BIT OF A PROBLEM FOR THE ENGLISH VERSION?
    participant.sentencesCourpus = 'VU_zinnen'; 
end

screenSize = get(0, 'ScreenSize');

% sanityChecks
%     close all
    heightGUI = 300;
    widthGUI = 325;
    itemsDistance = 10;
    
    
    f = figure('Visible','off',...
        'MenuBar','None', ...
        'ToolBar', 'none', ...
        'NumberTitle', 'off', ...
        'Position', [round((screenSize(3)-widthGUI)/2), round((screenSize(4)-heightGUI)/2), widthGUI, heightGUI], ...
        'Name', 'PICKA - Participant details');

    sizeWindow = [130 30];
%% name    
    posTextX = 30;
    posTextY = heightGUI-60;
    subText = uicontrol(f, 'Style','text', 'Unit', 'pixel');
    set(subText, 'String', 'Participant ID');
    textW = get(subText, 'Extent');
    textW = textW(3);
    set(subText, 'Position', [posTextX, posTextY, textW, sizeWindow(2)], 'HorizontalAlignment', 'right');
    
    posBoxX = posTextX+textW+itemsDistance;
    posBoxY = heightGUI-50;
    subTxtBox = uicontrol(f,'Style','edit',...
        'String', participant.name,...
        'Position', [posBoxX posBoxY sizeWindow]);
%% age
    posTextY = posTextY - itemsDistance - sizeWindow(2);
    ageText = uicontrol(f,'Style','text',...
                'String','Age',...
                'Position', [posTextX, posTextY, textW, sizeWindow(2)], ...
                'HorizontalAlignment', 'right');
    posBoxY = posBoxY - itemsDistance - sizeWindow(2);
    ageTxtBox = uicontrol(f,'Style','edit',...
        'String', participant.age,...
        'Position', [posBoxX posBoxY sizeWindow]);
%% sex
    buttonWindow = [sizeWindow(1) 100];
    posTextY = posTextY - itemsDistance - sizeWindow(2);
    sexBg = uibuttongroup(f,'Title','Sex', 'Unit', 'pixel',...
            'Position', [30, 75, ...
            buttonWindow(1), buttonWindow(2)]);
    posBoxY = posBoxY - itemsDistance - sizeWindow(2);
    rbMale = uicontrol(sexBg,'Style','radiobutton','String','Male',...
                'Units','normalized',...
                'Position',[.1 .6 .8 .2]);
    rbFemale = uicontrol(sexBg,'Style','radiobutton','String','Female',...
                'Units','normalized',...
                'Position',[.1 .2 .8 .2]);

%% language
    posTextY = posTextY - itemsDistance - sizeWindow(2);
    langBg = uibuttongroup(f,'Title','Language', 'Unit', 'pixel',...
            'Position', [30+buttonWindow(1)+itemsDistance, 75, ...
            buttonWindow(1), buttonWindow(2)]);
    posBoxY = posBoxY - itemsDistance - sizeWindow(2);
    rbDutch = uicontrol(langBg,'Style','radiobutton','String','Dutch (nl-nl)',...
                'Units','normalized',...
                'Position',[.1 .6 .8 .2]);
    rbEnglish = uicontrol(langBg,'Style','radiobutton','String','English (en-gb)',...
                'Units','normalized',...
                'Position',[.1 .2 .8 .2]);

%% continue
    continueButton = uicontrol(f,'Style','pushbutton',...
                'String','OK',...
                'Value',0,...
                'Position', [(widthGUI-itemsDistance-sizeWindow(1))...
                    itemsDistance, sizeWindow], ...
                 'Callback',{@updateParticipant}   );
    
    f.Visible = 'on';
    
    uiwait
    
    function updateParticipant(~, ~)
        participant.name = subTxtBox.String;
        participant.age = str2num(ageTxtBox.String);
        participant.sex = 'f';
        if rbMale.Value == 1
            participant.language = 'm';
        end
        participant.language = 'nl_nl'; % English or Dutch
        if rbEnglish.Value == 1
            participant.language = 'en_gb';
        end
        participant.kidsOrAdults = 'kid'; % we leave empty for kids because I am not sure whether we'd fuck up some file names/if statements
        if participant.age > 18
            participant.kidsOrAdults = 'adult';
        end
        uiresume
    end
    %
%     close this figure
    close(gcf)
end