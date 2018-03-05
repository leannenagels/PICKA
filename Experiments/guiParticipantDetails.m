function [participant] = guiParticipantDetails(participant)

% Creates a GUI to create a new participant, or update the information of
% an existing participant.

%--------------------------------------------------------------------------
% Paolo Toffanin <p.toffanin@umcg.nl> - 2015
% University of Groningen, UMCG, NL
%
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2018-05-02
% CNRS UMR 5292, FR | University of Groningen, UMCG, NL
%--------------------------------------------------------------------------

    if ~exist('struct_merge', 'file')
        addpath('../Resources/lib/MatlabCommonTools');
        commontools_added = true;
    else
        commontools_added = false;
    end

    if nargin<1
        participant = default_participant();
    else
        participant = struct_merge(default_participant(), participant);
    end

    screenSize = get(0, 'ScreenSize');


    heightGUI = 300;
    widthGUI = 325;
    itemsDistance = 10;
    
    
    f = figure('Visible','off',...
        'MenuBar','None', ...
        'ToolBar', 'none', ...
        'NumberTitle', 'off', ...
        'Position', [round((screenSize(3)-widthGUI)/2), round((screenSize(4)-heightGUI)/2), widthGUI, heightGUI], ...
        'Name', 'PICKA - Participant details', ...
        'WindowStyle', 'modal');

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
        'Position', [posBoxX posBoxY sizeWindow], ...
        'Callback', @check_language_from_ID);
    
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
            buttonWindow(1), buttonWindow(2)], ...
            'SelectionChangedFcn', @check_ID_from_language);
    posBoxY = posBoxY - itemsDistance - sizeWindow(2);
    rbDutch = uicontrol(langBg,'Style','radiobutton','String','Dutch (nl-nl)',...
                'Units','normalized',...
                'Position',[.1 .6 .8 .2], ...
                'UserData', 'nl_nl');
    rbEnglish = uicontrol(langBg,'Style','radiobutton','String','English (en-gb)',...
                'Units','normalized',...
                'Position',[.1 .2 .8 .2], ...
                'UserData', 'en_gb');
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
    drawnow();
    uicontrol(subTxtBox);
    
    uiwait();
    
    function updateParticipant(~, ~)
        
        if ~ participant_name_is_valid(subTxtBox.String)
            return;
        end
        
        participant.name = subTxtBox.String;
        participant.age = str2num(ageTxtBox.String);
        participant.sex = '';
        if rbMale.Value == 1
            participant.sex = 'm';
        elseif rbFemale.Value == 1
            participant.sex = 'f';
        end
        participant.language = ''; % English or Dutch
        if length(langBg.SelectedObject)~=0
            participant.language = langBg.SelectedObject.UserData;
        end
        %{
        participant.kidsOrAdults = 'kid'; % we leave empty for kids because I am not sure whether we'd fuck up some file names/if statements
        if participant.age > 18
            participant.kidsOrAdults = 'adult';
        end
        %}
        
        uiresume();
    end

    function check_language_from_ID(~, ~)
        
        if startswith(subTxtBox.String, 'nl')
            rbDutch.Value = 1;
            rbEnglish.Value = 0;
        elseif startswith(subTxtBox.String, 'gb')
            rbDutch.Value = 0;
            rbEnglish.Value = 1;
        else
            rbDutch.Value = 0;
            rbEnglish.Value = 0;
        end
        

    end

    function check_ID_from_language(~, dat)
        if ~isempty(dat.NewValue)
            lang = dat.NewValue.UserData;
            lang = explode('_', lang);
            region = lang{2};
            
            if ~startswith(subTxtBox.String, [region, '_'])
                if ~isempty(regexp(subTxtBox.String, '^.{2}_'))
                    subTxtBox.String(1:3) = [region, '_'];
                else
                    subTxtBox.String = [region, '_', subTxtBox.String];
                end
            end
        end
    end

    function b = participant_name_is_valid(name)

        % Subject format: {nl|gb}_{NH|CI}{A|K}[000]
        b = ~ isempty(regexp(name, '^(?:nl|gb)_(?:NH|CI)(?:A|K)\d{3}$', 'once'));

        if ~b
            % The format is not valid
            msgbox(sprintf('The participant''s ID "%s" is not valid.\nThe correct format has the following format:\nnl_NHA002\nor\ngb_CIK075', name), 'Invalid participant ID', 'error');
            return;
        else
            % The format is valid
            
            % We check consistency of language
            lang = explode('_', langBg.SelectedObject.UserData);
            if ~startswith(name, [lang{2}, '_'])
                b = false;
                msgbox(sprintf('The participant''s ID "%s" has to match the selected language/region (%s).', name, langBg.SelectedObject.UserData), 'Invalid participant ID', 'error');
                return;
            end
            
            % We check the consistency of age
            c = name(6);
            age = str2num(ageTxtBox.String);
            b = (age<18 & c=='K') | (age>=18 & c=='A');
            if ~b
                msgbox(sprintf('The participant''s ID "%s" has to match the entered age (%s).', name, ageTxtBox.String), 'Invalid participant ID', 'error');
                uicontrol(ageTxtBox);
                return
            end
        end

    end

    % close this figure
    close(gcf)
    
    if commontools_added
        rmpath('../Resources/lib/MatlabCommonTools');
    end
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


