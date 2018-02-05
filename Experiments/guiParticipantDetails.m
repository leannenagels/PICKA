function [participant] = guiParticipantDetails(participant)

if nargin<1
    participant = default_participant();
else
    participant = struct_merge(default_participant(), participant);
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
    sexBg.SelectedObject = [];
    switch participant.sex
        case 'f'
            sexBg.SelectedObject = [rbFemale];
        case 'm'
            sexBg.SelectedObject = [rbMale];
    end
    
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
    langBg.SelectedObject = [];
    switch participant.language
        case {'nl', 'nl_nl'}
            langBg.SelectedObject = [rbDutch];
        case {'en', 'en_gb'}
            langBg.SelectedObject = [rbEnglish];
    end

%% continue
    continueButton = uicontrol(f,'Style','pushbutton',...
                'String','OK',...
                'Value',0,...
                'Position', [(widthGUI-itemsDistance-sizeWindow(1))...
                    itemsDistance, sizeWindow], ...
                 'Callback',{@updateParticipant}   );
    
    f.Visible = 'on';
    
    uiwait();
    
    function updateParticipant(~, ~)
        participant.name = subTxtBox.String;
        participant.age = ageTxtBox.String;
        participant.sex = '';
        if rbMale.Value == 1
            participant.sex = 'm';
        elseif rbFemale.Value == 1
            participant.sex = 'f';
        end
        participant.language = ''; % English or Dutch
        if rbEnglish.Value == 1
            participant.language = 'en_gb';
        elseif rbDutch.Value == 1
            participant.language = 'nl_nl';
        end
        %{
        participant.kidsOrAdults = 'kid'; % we leave empty for kids because I am not sure whether we'd fuck up some file names/if statements
        if participant.age > 18
            participant.kidsOrAdults = 'adult';
        end
        %}
        uiresume();
    end
    %
%     close this figure
    close(gcf)
end

function participant = default_participant()

    participant = struct();
    participant.name = '';
    participant.age = 0;
    participant.sex = ''; % 'm' or 'f'
    participant.language = 'nl'; % 'nl or 'en'

end

function C = struct_merge(A, B)

    % C = struct_merge(A, B)
    %   Merge struct A and B. If a key is present in both structs, then the
    %   value from B is used. Struct arrays are not supported.

    % E. Gaudrain <egaudrain@gmail.com> 2010-06-02

    C = A;

    keys = fieldnames(B);
    for k = 1:length(keys)
        key = keys{k};
        C.(key) = B.(key);
    end

end