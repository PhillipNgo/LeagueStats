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
% End initialization code - DO NOT EDIT

    
% --- Executes just before LeagueStatsGUI is made visible.
function LeagueStatsGUI_OpeningFcn(hObject, eventdata, handles, varargin)

    handles.output = hObject;
    guidata(hObject, handles);

    global version % STRING variable that holds the version of the game
    global static_texts % VECTOR variable that holds the stats static text handles
    
    % reads riot's API and places the most current game version in the version variable
    version_link = 'https://global.api.pvp.net/api/lol/static-data/na/v1.2/versions?api_key=f1153217-7b9e-4adc-9036-596a248cb50b';
    version = parse_json(urlread(version_link));
    version = version{1};

    % put all static text handles into static_text in the order of champion.stats
    static_texts = [handles.hp handles.hpperlevel handles.mp handles.mpperlevel handles.armor handles.armorperlevel ...
                    handles.spellblock handles.spellblockperlevel handles.hpregen handles.hpregenperlevel ...
                    handles.mpregen handles.mpregenperlevel handles.crit handles.critperlevel handles.attackdamage ...
                    handles.attackdamageperlevel handles.attackspeed handles.attackspeedperlevel handles.abilitypower ...
                    handles.abilitypowerperlevel handles.cooldown handles.cooldownperlevel handles.attackrange ...
                    handles.movespeed];
                
    imshow(imread('logo.png'))
    
    new_champion('Aatrox') % open's the GUI with Aatrox loaded
    display_values(handles) % display's Aatrox's values in each text field
   
    
% --- Function that updates all static text with current champion values
function display_values(handles)

    global version 
    global champion % STRUCTURE variable that holds the current champion's data
    global static_texts 
    
    % update champion image from riot's API
    axes(handles.axes1)
    imshow(imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/champion/' champion.id '.png']))
    set(handles.name,'String',champion.id) % set name text to current champion's name
    set(handles.title,'String',champion.title) % set champion's title under champion's name
    stats = struct2cell(champion.stats); % converts 1x1 champion.stats structure to cell in order to loop through
    for i = 1:length(static_texts) % loops through static_text and stats 
        set(static_texts(i), 'String' , num2str(str2double(sprintf('%.3f',stats{i}))))
    end
    
    images{1} = imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/passive/' champion.passive.image.full]);
    set(handles.desc1, 'String', champion.passive.description)
    
    % not done in one loop to stop staggering the description/image changes
    for i = 1:4
        set(handles.(['desc' num2str(i+1)]), 'String', champion.spells{i}.description)
        images{i+1} = imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/spell/' champion.spells{i}.image.full]);
    end
     
    for i = 1:5
        curr_axes = ['axes' num2str(i+3)];
        axes(handles.(curr_axes))
        imshow(images{i})
    end
    
    
% --- Function that updates champion variable with champion String 'champ_name'
function new_champion(champ_name)
    
    global version
    global champion
    global item_slots
    
    champion_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/champion/' champ_name '.json'];
    champion = parse_json(urlread(champion_link)); % parse champion link
    champion = struct2cell(champion.data); % convert champion.data to a cell to pull champion from
    champion = champion{1}; % sets champion variable
    champion.stats.attackspeedoffset = .625/(1+champion.stats.attackspeedoffset); % calculates base attack speed
    champion.stats.abilitypower = 0; % create ability power field
    champion.stats.abilitypowerperlevel = 0; % create ability power per level field
    champion.stats.cooldown = 0; % create cool down field
    champion.stats.cooldownperlevel = 0; % create cool down per level field
    champion.itemstats = struct;
    champion.runestats = struct;
    champion.masterystats = struct;
    champion.levelstats = struct;
    
    % reorders attackrange and movespeed to the bottom of champion.stats
    attackrange = champion.stats.attackrange;
    movespeed = champion.stats.movespeed;
    champion.stats = rmfield(champion.stats, 'attackrange');
    champion.stats = rmfield(champion.stats, 'movespeed');
    champion.stats.attackrange = attackrange;
    champion.stats.movespeed = movespeed;
   
    % create/reset item_slots
    item_slots = cell(1,7);
    
    
% --- Outputs from this function are returned to the command line.
function varargout = LeagueStatsGUI_OutputFcn(hObject, eventdata, handles) 
    
    varargout{1} = handles.output;
    

% --- Executes on selection change in champion_menu.
function champion_menu_Callback(hObject, eventdata, handles)
% Hints: champion_list = cellstr(get(hObject,'String')) returns champion_menu contents as cell array
%        selected_champion = contents{get(hObject,'Value')} returns selected champion from champion_menu

    champion_list = cellstr(get(hObject,'String'));
    selected_champion = champion_list{get(hObject,'Value')};
    
    new_champion(selected_champion) % set champion to selected champion from menu
    display_values(handles) % display new champion's values
    set(handles.levels_menu, 'Value', 1) % change level to 1


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
    fields = fieldnames(champion.stats); % get list of stat names
    new_champion(champion.id) % reset stats of champion

    % loop through champion.stats.statname and add perlevel stats to base
    for i  = 1:2:numel(fields)-3
        if i == 17 % 17 = attack speed stat which uses a percentage system rather than base
            champion.stats.(fields{i}) = champion.stats.(fields{i})*((.01*(level-1)*champion.stats.(fields{i+1}))+1);
        else % all other stats
            champion.stats.(fields{i}) = champion.stats.(fields{i}) + champion.stats.(fields{i+1})*(level-1);
        end
    end

    display_values(handles)


% --- Executes during object creation, after setting all properties.
function levels_menu_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    set(hObject, 'String', {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18}); % set pop up menu to 18 levels

    
function add_item(button, slot)

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
        set(button, 'String', item) % reset button to 'Item Slot'
    elseif length(item) == 1 % if there was a chosen item
        % change image to selected item and change button text to nothing
        set(button, 'CData', imresize(imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/item/' item.image.full]),1.3))
        set(button, 'String', '')
        
        item_slots{slot} = item; % put item into the specified item slot
        add_stats(item_slots{slot}) % add item stats to champion
    end
    
    
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
            if isfield(champion.itemstats, fields{j}) % if stat already exists in champion.itemstats, adds onto extisting value
                champion.(stat_type).(fields{j}) = champion.(stat_type).(fields{j}) + object.stats.(fields{j});
            else % else cretes the stat if it is not in champion.itemstats
                champion.(stat_type).(fields{j}) = object.stats.(fields{j});
            end
        end
    end

    
function update_stats()

    global champion
    
    fields = fieldnames(champion.itemstats);
    for i = 1:length(fields) 
    %     'FlatHPPoolMod')
    %     'rFlatHPModPerLevel')
    %     'FlatMPPoolMod')
    %     'rFlatMPModPerLevel')
    %     'PercentHPPoolMod')
    %     'PercentMPPoolMod')
    %     'FlatHPRegenMod')
    %     'rFlatHPRegenModPerLevel')
    %     'PercentHPRegenMod')
    %     'FlatMPRegenMod')
    %     'rFlatMPRegenModPerLevel')
    %     'PercentMPRegenMod')
    %     'FlatArmorMod')
    %     'rFlatArmorModPerLevel')
    %     'PercentArmorMod')
    %     'rFlatArmorPenetrationMod')
    %     'rFlatArmorPenetrationModPerLevel')
    %     'rPercentArmorPenetrationMod')
    %     'rPercentArmorPenetrationModPerLevel')
    %     'FlatPhysicalDamageMod')
    %     'rFlatPhysicalDamageModPerLevel')
    %     'PercentPhysicalDamageMod')
    %     'FlatMagicDamageMod')
    %     'rFlatMagicDamageModPerLevel')
    %     'PercentMagicDamageMod')
    %     'FlatMovementSpeedMod'
    %     'rFlatMovementSpeedModPerLevel')
    %     'PercentMovementSpeedMod')
    %     'rPercentMovementSpeedModPerLevel')
    %     'FlatAttackSpeedMod')
    %     'PercentAttackSpeedMod')
    %     'rPercentAttackSpeedModPerLevel')
    %     'FlatCritChanceMod')
    %     'rFlatCritChanceModPerLevel')
    %     'PercentCritChanceMod')
    %     'FlatCritDamageMod')
    %     'rFlatCritDamageModPerLevel')
    %     'PercentCritDamageMod')
    %     'FlatBlockMod')
    %     'PercentBlockMod')
    %     'FlatSpellBlockMod')
    %     'rFlatSpellBlockModPerLevel')
    %     'PercentSpellBlockMod')
    %     'rPercentCooldownMod')
    %     'rPercentCooldownModPerLevel')
    %     'rFlatGoldPer10Mod')
    %     'rFlatMagicPenetrationMod')
    %     'rFlatMagicPenetrationModPerLevel')
    %     'rPercentMagicPenetrationMod')
    %     'rPercentMagicPenetrationModPerLevel')
    %     'FlatEnergyRegenMod')
    %     'rFlatEnergyRegenModPerLevel')
    %     'FlatEnergyPoolMod')
    %     'rFlatEnergyModPerLevel')
    %     'PercentLifeStealMod')
    %     'PercentSpellVampMod')
    end


% --- Executes on button press in item1.
function item1_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSL>
    
    add_item(handles.item1, 1)
    
% --- Executes on button press in item2.
function item2_Callback(hObject, eventdata, handles)

    add_item(handles.item2, 2)
    
% --- Executes on button press in item3.
function item3_Callback(hObject, eventdata, handles)

    add_item(handles.item3, 3)
    
% --- Executes on button press in item4.
function item4_Callback(hObject, eventdata, handles)

    add_item(handles.item4, 4)

% --- Executes on button press in item5.
function item5_Callback(hObject, eventdata, handles)

    add_item(handles.item5, 5)

% --- Executes on button press in item6.
function item6_Callback(hObject, eventdata, handles)

    add_item(handles.item6, 6)

% --- Executes on button press in item7.
function item7_Callback(hObject, eventdata, handles)

    add_item(handles.item7, 7)


% --- Executes on button press in edit_runes.
function edit_runes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_runes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clear_runes.
function clear_runes_Callback(hObject, eventdata, handles)
% hObject    handle to clear_runes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clear_masteries.
function clear_masteries_Callback(hObject, eventdata, handles)
% hObject    handle to clear_masteries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in edit_masteries.
function edit_masteries_Callback(hObject, eventdata, handles)
% hObject    handle to edit_masteries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clear_items.
function clear_items_Callback(hObject, eventdata, handles)
% hObject    handle to clear_items (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in load_build.
function load_build_Callback(hObject, eventdata, handles)
% hObject    handle to load_build (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton38.
function pushbutton38_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clear_all.
function clear_all_Callback(hObject, eventdata, handles)
% hObject    handle to clear_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
