function varargout = LeagueStatsGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LeagueStatsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LeagueStatsGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT_MENU

    
% --- Executes just before LeagueStatsGUI is made visible.
function LeagueStatsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
    
    handles.output = hObject;
    guidata(hObject, handles);

    global version % STRING variable that holds the version of the game
    global static_texts % VECTOR variable that holds the stats static text handles
    global items % STRUCTURE variable that holds all items
    global curr_runes % STRUCTURE variable that holds all runes
    
    % reads riot's API and places the most current game version in the version variable
    version_link = 'https://global.api.pvp.net/api/lol/static-data/na/v1.2/versions?api_key=f1153217-7b9e-4adc-9036-596a248cb50b';
    version = parse_json(urlread(version_link));
    version = version{1};

    items_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/item.json'];
    items = parse_json(urlread(items_link));
    
    curr_runes = [];
    
    % put all static text handles into static_text in the order of champion.stats
    static_texts = [handles.hp handles.hpperlevel handles.mp handles.mpperlevel handles.armor handles.armorperlevel ...
                    handles.spellblock handles.spellblockperlevel handles.hpregen handles.hpregenperlevel ...
                    handles.mpregen handles.mpregenperlevel handles.crit handles.critperlevel handles.attackdamage ...
                    handles.attackdamageperlevel handles.attackspeed handles.attackspeedperlevel handles.abilitypower ...
                    handles.abilitypowerperlevel handles.cooldown handles.cooldownperlevel handles.attackrange ...
                    handles.movespeed handles.armorpenetration handles.percentarmorpenetration handles.magicpenetration ...
                    handles.percentmagicpenetration handles.lifesteal handles.spellvamp];
    
    new_champion('Aatrox', handles) % open's the GUI with Aatrox loaded
    display_values(handles) % display's Aatrox's values in each text field
 

% --- Function that takes an item description (text), removes all special formatting, and adds line breaks where necessary
function text = readable(text, spell, handles)
    
    global champion
    
    while strfind(text, '<br><br>') % if there are double linebreaks
        index = regexp(text, '<br><br>'); % find the starting index
        text(index:index+3) = ''; % remove one line break
    end
    
    i = 1; % the position within the string
    while i < length(text) % loop through the string
        if strcmp(text(i), '<') % '<' notes the beginning of special formatting
            while ~strcmp(text(i), '>') % '>' notes the end of special formatting
                if strcmp(text(i), 'b') % <br> is notation for linebreak
                    text(i) = char(10); % char(10) adds linebreak
                    i = i + 1; 
                end
                text(i) = ''; % remove letter at current position
            end
            text(i) = '';
            if i > 1
               i = i - 1; 
            end
        end
        
        
        if i < length(text) - 3 && strcmp(text(i:i+2), '{{ ') 
            
            num = str2double(text(i+4)) + 1;
            level = get(handles.(['levels' num2str(spell)]), 'Value') - 1;
            
            if strcmp(text(i+3), 'e') && num <= length(champion.spells{spell}.effect)
                field = champion.spells{spell}.effect{num};
            elseif strcmp(text(i+3), 'c')
                field = champion.spells{spell}.cost;
            elseif strcmp(text(i+3), 'a')
                num = num - 1;
                if num > length(champion.spells{spell}.vars)
                    num = num - 1;
                end
                field = champion.spells{spell}.vars{num};
            end
            
            if strcmp(text(i+3), 'a') && length(champion.spells{spell}.vars{num}.coeff) > 1
                coefficient = champion.spells{spell}.vars{num}.coeff{level};
            elseif strcmp(text(i+3), 'a')
                coefficient = champion.spells{spell}.vars{num}.coeff;
            end
            
            if level > 0 && ~strcmp(text(i+3), 'f')
                
                
                if num <= length(champion.spells{spell}.effect)
                    values = field;
                    
                    if strcmp(text(i+3), 'c') || strcmp(text(i+3), 'e')
                        value = num2str(values{level});
                    elseif strcmp(champion.spells{spell}.vars{num}.link, 'bonusattackdamage')
                        value = sprintf('%.1f', champion.bonusstats.FlatPhysicalDamageMod*coefficient);
                    elseif strcmp(champion.spells{spell}.vars{num}.link, 'spelldamage')
                        value = num2str((champion.bonusstats.FlatMagicDamageMod + champion.stats.abilitypower)*coefficient);
                    elseif strcmp(champion.spells{spell}.vars{num}.link, 'attackdamage')
                        value = num2str((champion.bonusstats.FlatPhysicalDamageMod + champion.stats.attackdamage)*coefficient);
                    elseif strcmp(champion.spells{spell}.vars{num}.link, 'bonusarmor')
                        value = sprintf('%.1f', champion.bonusstats.FlatArmorMod*coefficient);
                    elseif strcmp(champion.spells{spell}.vars{num}.link, 'bonusspellblock')
                        value = sprintf('%.1f', champion.bonusstats.FlatSpellBlockMod*coefficient);
                    elseif strcmp(champion.spells{spell}.vars{num}.link, 'armor')
                        value = num2str((champion.bonusstats.FlatPhysicalDamageMod + champion.stats.armor)*coefficient);
                    elseif strcmp(champion.spells{spell}.vars{num}.link, 'bonushealth')
                        value = sprintf('%.1f', champion.bonusstats.FlatHPPoolMod*coefficient);
                    elseif strcmp(champion.spells{spell}.vars{num}.link, 'health')
                        value = num2str((champion.bonusstats.FlatHPPoolMod + champion.stats.hp)*coefficient);
                    end                    
                    
                    for j = 1:length(value)
                        text(i) = value(j);
                        i = i + 1;
                    end
                end
            elseif level == 0 && ~strcmp(text(i+3), 'f')
                s1 = text(1:i-1);
                s3 = text(i:length(text));
                if strcmp(text(i+3), 'a')
                    switch champion.spells{spell}.vars{num}.link
                        case 'bonusattackdamage'
                            link = 'BONUS AD';
                        case 'spelldamage'
                            link = 'AP';
                        case 'attackdamage'
                            link = 'AD';
                        case 'bonusarmor'
                            link = 'BONUS ARMOR';
                        case 'bonusspellblock'
                            link = 'BONUS MR';
                        case 'armor'
                            link = 'ARMOR';
                        case 'bonushealth'
                            link = 'BONUS HP';
                        case 'health'
                            link = 'HP';
                    end
                    s2 = [num2str(coefficient*100) '% ' link];
                elseif strcmp(text(i+3), 'c')
                    s2 = champion.spells{spell}.costBurn;
                elseif strcmp(text(i+3), 'e') && num <= length(champion.spells{spell}.effect)
                    s2 = champion.spells{spell}.effectBurn{num};
                end
                if i ~= 1 && ~strcmp(s1(length(s1)), '(') && ~strcmp(s1(length(s1)-1), '(')
                    s1 = [s1 '('];
                    i = i + 1;
                end
                if i ~= 1 && ~strcmp(s3(9), ')')
                    s3 = [s3(1:8) ')' s3(9:length(s3))];
                end
                text = [s1 s2 s3];
                i = i + length(s2);
            end
            while ~strcmp(text(i), '}') % '>' notes the end of special formatting
                text(i) = ''; % remove letter at current position
            end
            text(i) = '';
            text(i) = '';
            i = i - 1;
        end
        i = i + 1;
    end
    
    
% --- Function that updates all static text with current champion values
function display_values(handles)

    global champion % STRUCTURE variable that holds the current champion's data
    global static_texts 
       
    fields = {'FlatHPPoolMod' 'rFlatHPModPerLevel' 'FlatMPPoolMod' 'rFlatMPModPerLevel' 'FlatArmorMod' 'rFlatArmorModPerLevel' ...
              'FlatSpellBlockMod' 'rFlatSpellBlockModPerLevel' 'FlatHPRegenMod' 'rFlatHPRegenModPerLevel' ...
              'FlatMPRegenMod' 'rFlatMPRegenModPerLevel' 'FlatCritChanceMod' 'rFlatCritChanceModPerLevel' 'FlatPhysicalDamageMod' ...
              'rFlatPhysicalDamageModPerLevel' 'PercentAttackSpeedMod' 'rPercentAttackSpeedModPerLevel' 'FlatMagicDamageMod' ...
              'rFlatMagicDamageModPerLevel' 'rPercentCooldownMod' 'rPercentCooldownModPerLevel' 'FlatMovementSpeedMod' 'rFlatArmorPenetrationMod' ...
              'rPercentArmorPenetrationMod' 'rFlatMagicPenetrationMod' 'rPercentMagicPenetrationMod' 'PercentLifeStealMod' ...
              'PercentSpellVampMod'};
          
    stats = struct2cell(champion.stats); % converts 1x1 champion.stats structure to cell in order to loop through
    
    j = 1;
    for i = 1:length(stats)
        if i ~= 23
            if i ~= 17
                champion.bonusstats.(fields{j}) = champion.itemstats.(fields{j}) + champion.runestats.(fields{j}) ...
                    + champion.masterystats.(fields{j}) + champion.levelstats.(fields{j});
                stats{i} = stats{i} + champion.bonusstats.(fields{j});
            else
                stats{i} = stats{i}*(1 + champion.itemstats.(fields{j}) + champion.runestats.(fields{j}) ...
                    + champion.masterystats.(fields{j}) + (champion.levelstats.(fields{j})*.01));
            end
            j = j + 1;
        end
    end
    for i = 1:length(static_texts) % loops through static_text and stats 
        set(static_texts(i), 'String' , num2str(str2double(sprintf('%.3f', stats{i}))))
    end
    
    set(handles.desc1, 'String', readable(champion.passive.description, 0, handles))
    % not done in one loop to stop staggering the description/image changes
    for i = 2:5
        set(handles.(['desc' num2str(i)]), 'String', readable(champion.spells{i-1}.tooltip, i-1, handles))
        if get(handles.(['levels' num2str(i-1)]), 'Value') - 1 ~= 0
            set(handles.(['desc' num2str(i) num2str(i)]), 'String', ['Cooldown: ' num2str(champion.spells{i-1}.cooldown{get(handles.(['levels' num2str(i-1)]), 'Value')-1})])
        else
            set(handles.(['desc' num2str(i) num2str(i)]), 'String', ['Cooldown: ' champion.spells{i-1}.cooldownBurn])
        end
        set(handles.(['desc' num2str(i) num2str(i) num2str(i)]), 'String', ['Cost: ' readable(champion.spells{i-1}.resource, i-1, handles)])
    end
    
function reset_levels(handles)
    
    set(handles.levels_menu, 'Value', 1)
    for i = 1:7
        if i < 5
            set(handles.(['levels' num2str(i)]), 'Value', 1)
        end
        set(handles.(['item' num2str(i)]), 'CData', []) % reset button image
        set(handles.(['item' num2str(i)]), 'String', 'Item Slot') % reset button to 'Item Slot'
    end
    
% --- Function that updates champion variable with champion String 'champ_name'
function new_champion(champ_name, handles)
    
    global version
    global champion
    global item_slots
    global items
    
    champion_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/champion/' champ_name '.json'];
    champion = parse_json(urlread(champion_link)); % parse champion link
    champion = struct2cell(champion.data); % convert champion.data to a cell to pull champion from
    champion = champion{1}; % sets champion variable
    champion.stats.attackspeedoffset = .625/(1+champion.stats.attackspeedoffset); % calculates base attack speed
    champion.stats.abilitypower = 0; % create ability power field
    champion.stats.abilitypowerperlevel = 0; % create ability power per level field
    champion.stats.cooldown = 0; % create cool down field
    champion.stats.cooldownperlevel = 0; % create cool down per level field 
    
    % reorders attackrange and movespeed to the bottom of champion.stats
    attackrange = champion.stats.attackrange;
    movespeed = champion.stats.movespeed;
    champion.stats = rmfield(champion.stats, 'attackrange');
    champion.stats = rmfield(champion.stats, 'movespeed');
    champion.stats.attackrange = attackrange;
    champion.stats.movespeed = movespeed;
   
    champion.stats.armorpenetration = 15;
    champion.stats.percentarmorpenetration = 0;
    champion.stats.magicpenetration = 0;
    champion.stats.percentmagicpenetration = 0;
    champion.stats.lifesteal = 0;
    champion.stats.spellvamp = 15;
    champion.itemstats = items.basic.stats;
    champion.runestats = champion.itemstats;
    champion.masterystats = champion.itemstats;
    champion.levelstats = champion.itemstats;
    champion.bonusstats = champion.itemstats;
    
    % create/reset item_slots
    item_slots = cell(1,7);
    
    % update champion image from riot's API
    axes(handles.axes1)
    imshow(imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/champion/' champion.id '.png']))
    set(handles.name,'String',champion.id) % set name text to current champion's name
    set(handles.title,'String',champion.title) % set champion's title under champion's name
    
    reset_levels(handles)
    set_level_menus(handles)
    
    images{1} = imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/passive/' champion.passive.image.full]);
    for i = 1:4
        images{i+1} = imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/spell/' champion.spells{i}.image.full]);
    end
    for i = 1:5
        curr_axes = ['axes' num2str(i+3)];
        axes(handles.(curr_axes)) %#ok<LAXES>
        imshow(images{i})
    end
    
    
% --- Outputs from this function are returned to the command line.
function varargout = LeagueStatsGUI_OutputFcn(hObject, eventdata, handles) 
    
    varargout{1} = handles.output;
    

% --- Executes on selection change in champion_menu.
function champion_menu_Callback(hObject, eventdata, handles)
% Hints: champion_list = cellstr(get(hObject,'String')) returns champion_menu contents as cell array
%        selected_champion = contents{get(hObject,'Value')} returns selected champion from champion_menu

    champion_list = cellstr(get(hObject,'String'));
    selected_champion = champion_list{get(hObject,'Value')};
    
    new_champion(selected_champion, handles) % set champion to selected champion from menu
    display_values(handles) % display new champion's values


% --- Executes during object creation, after setting all properties.
function champion_menu_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    global version
    
    % load all champions list
    all_champions_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/champion.json'];
    champions = parse_json(urlread(all_champions_link));

    set(hObject, 'String', fieldnames(champions.data)); % set champions to dropdown menu


% --- Executes on selection change in levels_menu.
function levels_menu_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns levels_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from levels_menu

    global champion
    
    level = get(hObject, 'Value'); % get selected level from popupmenu
    
    champion.levelstats.FlatHPPoolMod = (champion.stats.hpperlevel ...
                                      + champion.itemstats.rFlatHPModPerLevel ...
                                      + champion.runestats.rFlatHPModPerLevel ...
                                      + champion.masterystats.rFlatHPModPerLevel)*(level-1);
    champion.levelstats.FlatMPPoolMod = (champion.stats.mpperlevel ...
                                      + champion.itemstats.rFlatMPModPerLevel ...
                                      + champion.runestats.rFlatMPModPerLevel ...
                                      + champion.masterystats.rFlatMPModPerLevel)*(level-1);
    champion.levelstats.FlatHPRegenMod = (champion.stats.hpregenperlevel ...
                                       + champion.itemstats.rFlatHPRegenModPerLevel ...
                                       + champion.runestats.rFlatHPRegenModPerLevel ...
                                       + champion.masterystats.rFlatHPRegenModPerLevel)*(level-1);
    champion.levelstats.FlatMPRegenMod = (champion.stats.mpregenperlevel ...
                                       + champion.itemstats.rFlatMPRegenModPerLevel ...
                                       + champion.runestats.rFlatMPRegenModPerLevel ...
                                       + champion.masterystats.rFlatMPRegenModPerLevel)*(level-1);
    champion.levelstats.FlatArmorMod = (champion.stats.armorperlevel ...
                                     + champion.itemstats.rFlatArmorModPerLevel ...
                                     + champion.runestats.rFlatArmorModPerLevel ...
                                     + champion.masterystats.rFlatArmorModPerLevel)*(level-1);
    champion.levelstats.FlatPhysicalDamageMod = (champion.stats.attackdamageperlevel ...
                                              + champion.itemstats.rFlatPhysicalDamageModPerLevel ...
                                              + champion.runestats.rFlatPhysicalDamageModPerLevel ...
                                              + champion.masterystats.rFlatPhysicalDamageModPerLevel)*(level-1);                        
    champion.levelstats.FlatMagicDamageMod = (champion.stats.abilitypowerperlevel ...
                                           + champion.itemstats.rFlatMagicDamageModPerLevel ...
                                           + champion.runestats.rFlatMagicDamageModPerLevel ...
                                           + champion.masterystats.rFlatMagicDamageModPerLevel)*(level-1);  
    champion.levelstats.PercentAttackSpeedMod = (champion.stats.attackspeedperlevel ...
                                              + champion.itemstats.rPercentAttackSpeedModPerLevel ...
                                              + champion.runestats.rPercentAttackSpeedModPerLevel ...
                                              + champion.masterystats.rPercentAttackSpeedModPerLevel)*(level-1); 
    champion.levelstats.FlatSpellBlockMod = (champion.stats.spellblockperlevel ...
                                          + champion.itemstats.rFlatSpellBlockModPerLevel ...
                                          + champion.runestats.rFlatSpellBlockModPerLevel ...
                                          + champion.masterystats.rFlatSpellBlockModPerLevel)*(level-1);
    champion.levelstats.rPercentCooldownMod = (champion.stats.cooldownperlevel ...
                                            + champion.itemstats.rPercentCooldownModPerLevel ...
                                            + champion.runestats.rPercentCooldownModPerLevel ...
                                            + champion.masterystats.rPercentCooldownModPerLevel)*(level-1);

    display_values(handles)


% --- Executes during object creation, after setting all properties.
function levels_menu_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    set(hObject, 'String', {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18}); % set pop up menu to 18 levels

    
function add_item(button, slot, handles)

    global version
    setappdata(0, 'item', 'null') % set appdata to a null state
    
    % run and wait for itemsGUI to finish
    run_gui = itemsGUI;
    waitfor(run_gui);
    
    global item_slots % create item_slots which holds all items in inventory
    item = getappdata(0,'item'); % retrieves item from appdata which itemGUI stored the selected item
    
    if ~isempty(item_slots{slot}) % checks if there was an item is already in selected slot
        remove_stats(item_slots{slot}); % if there is an item, removes it stats from champion
        item_slots{slot} = [];
    end
    
    if length(item) > 1 && strcmp(item, 'clear') % if no item is selected
        set(button, 'CData', []) % reset button image
        set(button, 'String', 'Item Slot') % reset button to 'Item Slot'
    elseif length(item) == 1 % if there was a chosen item
        % change image to selected item and change button text to nothing
        set(button, 'CData', imresize(imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/item/' item.image.full]),1.3))
        set(button, 'String', '')
        
        item_slots{slot} = item; % put item into the specified item slot
        add_stats(item_slots{slot}) % add item stats to champion
    end
    
    display_values(handles)
    
    
function remove_stats(object)
    
    global champion
    
    if strfind(object.image.sprite, 'rune')
        stat_type = 'runestats';
    elseif strfind(object.image.sprite, 'mastery')
        stat_type = 'masterystats';
    elseif strfind(object.image.sprite, 'item')
        stat_type = 'itemstats';
    end
    
    fields = fieldnames(object.stats); % get obect stat names and put into fields
    for j = 1:length(fields) % loop through the stat names
        champion.(stat_type).(fields{j}) = champion.(stat_type).(fields{j}) - object.stats.(fields{j});
    end
    
    
function add_stats(object)
    
    global champion
    
    if strfind(object.image.sprite, 'rune')
        stat_type = 'runestats';
    elseif strfind(object.image.sprite, 'mastery')
        stat_type = 'masterystats';
    elseif strfind(object.image.sprite, 'item')
        stat_type = 'itemstats';
    end
     
    if ~isempty(object.stats) % only continue if the object has stats
        fields = fieldnames(object.stats); % get stat names and put into fields
        for j = 1:length(fields) % loop through the stat names
            champion.(stat_type).(fields{j}) = champion.(stat_type).(fields{j}) + object.stats.(fields{j});
        end
    end
    

% --- Executes on button press in item1.
function item1_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSL>
    
    add_item(handles.item1, 1, handles)
    
% --- Executes on button press in item2.
function item2_Callback(hObject, eventdata, handles)

    add_item(handles.item2, 2, handles)
    
% --- Executes on button press in item3.
function item3_Callback(hObject, eventdata, handles)

    add_item(handles.item3, 3, handles)
    
% --- Executes on button press in item4.
function item4_Callback(hObject, eventdata, handles)

    add_item(handles.item4, 4, handles)

% --- Executes on button press in item5.
function item5_Callback(hObject, eventdata, handles)

    add_item(handles.item5, 5, handles)

% --- Executes on button press in item6.
function item6_Callback(hObject, eventdata, handles)

    add_item(handles.item6, 6, handles)

% --- Executes on button press in item7.
function item7_Callback(hObject, eventdata, handles)

    add_item(handles.item7, 7, handles)


% --- Executes on button press in edit_runes.
function edit_runes_Callback(hObject, eventdata, handles)
    
    global champion
    global curr_runes
    
    setappdata(0, 'rune', curr_runes) % set appdata to a null state
    
    % run and wait for itemsGUI to finish
    run_gui = runesGUI;
    waitfor(run_gui);
    
    curr_runes = getappdata(0,'rune'); % retrieves runes from appdata which runesGUI stored the selected item'
    if ~isempty(curr_runes)
        str = {};
        for i = 1:length(curr_runes.names)
            str = [str [num2str(curr_runes.num{i}) 'x ' curr_runes.names{i} char(10)]];
        end
        set(handles.runedesc, 'String', str)
        
        champion.runestats = curr_runes.stats;
        display_values(handles)
    end
    
    
% --- Executes on button press in clear_runes.
function clear_runes_Callback(hObject, eventdata, handles)

    global curr_runes
    global champion
    global items
    
    curr_runes = [];
    champion.runestats = items.basic.stats;
    
    set(handles.runedesc, 'String', '')
    display_values(handles)
    
    
% --- Executes on button press in clear_masteries.
function clear_masteries_Callback(hObject, eventdata, handles)


% --- Executes on button press in edit_masteries.
function edit_masteries_Callback(hObject, eventdata, handles)


% --- Executes on button press in clear_items.
function clear_items_Callback(hObject, eventdata, handles)


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)


function set_level_menus(handles)
    
    global champion
    
    if strcmp(champion.id, 'Jayce')
       list = {0 1 2 3 4 5 6};
       set(handles.levels4, 'String', {0})
    else
       list = {0 1 2 3 4 5};
    end
    
    set(handles.levels1, 'String', list)
    set(handles.levels2, 'String', list)
    set(handles.levels3, 'String', list)
    
    if strcmp(champion.id, 'Udyr')
        set(handles.levels4, 'String', list)
    elseif strcmp(champion.id, 'Jayce')
        set(handles.levels4, 'String', 0)
    else
        set(handles.levels4, 'String', list(1:4))
    end
    
    
% --- Executes on selection change in levels1.
function levels1_Callback(hObject, eventdata, handles)

    display_values(handles)


% --- Executes during object creation, after setting all properties.
function levels1_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in levels2.
function levels2_Callback(hObject, eventdata, handles)

    display_values(handles)

% --- Executes during object creation, after setting all properties.
function levels2_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in levels3.
function levels3_Callback(hObject, eventdata, handles)

    display_values(handles)


% --- Executes during object creation, after setting all properties.
function levels3_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in levels4.
function levels4_Callback(hObject, eventdata, handles)

    display_values(handles)


% --- Executes during object creation, after setting all properties.
function levels4_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)


    function load_build_Callback(hObject, eventdata, handles)


    function new_build_Callback(hObject, eventdata, handles)


    function save_Callback(hObject, eventdata, handles)


    function save_as_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function edit_menu_Callback(hObject, eventdata, handles)


    function clear_all_Callback(hObject, eventdata, handles)
        
        global champion

        new_champion(champion.id, handles) % open's the GUI with Aatrox loaded
        display_values(handles) % display's Aatrox's values in each text field

        
    function spell_font_Callback(hObject, eventdata, handles)

        
        function font_7_Callback(hObject, eventdata, handles)
            
            set(handles.font_7, 'Checked', 'on')
            set(handles.font_9, 'Checked', 'off')
            set(handles.font_8, 'Checked', 'off')
            for i = 1:5
                set(handles.(['desc' num2str(i)]), 'FontSize', 7);
            end
        
        function font_8_Callback(hObject, eventdata, handles)
            
            set(handles.font_7, 'Checked', 'off')
            set(handles.font_9, 'Checked', 'off')
            set(handles.font_8, 'Checked', 'on')
            for i = 1:5
                set(handles.(['desc' num2str(i)]), 'FontSize', 8);
            end
            
        function font_9_Callback(hObject, eventdata, handles)
            
            set(handles.font_7, 'Checked', 'off')
            set(handles.font_9, 'Checked', 'on')
            set(handles.font_8, 'Checked', 'off')
            for i = 1:5
                set(handles.(['desc' num2str(i)]), 'FontSize', 9);
            end
        
% --------------------------------------------------------------------
function help_menu_Callback(hObject, eventdata, handles)


    function read_me_Callback(hObject, eventdata, handles)

        eval(['!notepad ' cd '/Read Me.txt'])


    function github_homepage_Callback(hObject, eventdata, handles)

        web('https://github.com/phllpng/LeagueStats', '-browser')

    
% --------------------------------------------------------------------   
function themes_menu_Callback(hObject, eventdata, handles)


    function default_theme_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function view_menu_Callback(hObject, eventdata, handles)
    
    function show_stats(type)
        
        global champion
        msg = {upper([type ' stats:' char(10)])};
        fields = fieldnames(champion.([type 'stats']));
        list = 1;
        for i = 1:length(fields)
            if champion.([type 'stats']).(fields{i}) ~= 0
                msg = [msg ['        ' num2str(list) '. ' fields{i} ': ' num2str(champion.([type 'stats']).(fields{i})) char(10)]];
                list = list + 1;
            end
        end
        msgbox(msg, [type ' stats'])

    function spell_ratios_Callback(hObject, eventdata, handles)



    function level_stats_Callback(hObject, eventdata, handles)

        show_stats('level')
        
    function item_stats_Callback(hObject, eventdata, handles)

        show_stats('item')
        
    function rune_stats_Callback(hObject, eventdata, handles)

        show_stats('rune')
        
    function mastery_stats_Callback(hObject, eventdata, handles)

        show_stats('mastery')




