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
    
    % reads riot's API and places the most current game version in the version variable
    version_link = 'https://global.api.pvp.net/api/lol/static-data/na/v1.2/versions?api_key=f1153217-7b9e-4adc-9036-596a248cb50b';
    version = parse_json(urlread(version_link));
    version = version{1};

    items_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/item.json'];
    items = parse_json(urlread(items_link));
    
    % put all static text handles into static_text in the order of champion.stats
    static_texts = [handles.hp handles.hpperlevel handles.mp handles.mpperlevel handles.armor handles.armorperlevel ...
                    handles.spellblock handles.spellblockperlevel handles.hpregen handles.hpregenperlevel ...
                    handles.mpregen handles.mpregenperlevel handles.crit handles.critperlevel handles.attackdamage ...
                    handles.attackdamageperlevel handles.attackspeed handles.attackspeedperlevel handles.abilitypower ...
                    handles.abilitypowerperlevel handles.cooldown handles.cooldownperlevel handles.attackrange ...
                    handles.movespeed];
               
    imshow(imread('logo.png'))
    
    new_champion('Aatrox', handles) % open's the GUI with Aatrox loaded
    display_values(handles) % display's Aatrox's values in each text field
 

% --- Function that takes an item description (text), removes all special formatting, and adds line breaks where necessary
function text = readable(text, spell)
    
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
            i = i - 1;
        end
%         if strcmp(text(i), '{{ e')
%             index = regexp(text, '{{ e');
%             num = str2double(text(index+3))+1;
%             text(index) = spell.effect{num}.
%             
%         end
        i = i + 1;
    end
    
    
% --- Function that updates all static text with current champion values
function display_values(handles)

    global champion % STRUCTURE variable that holds the current champion's data
    global static_texts 
       
    fields = {'FlatHPPoolMod' 'rFlatHPModPerLevel' 'FlatMPPoolMod' 'rFlatMPModPerLevel' 'FlatArmorMod' 'rFlatArmorModPerLevel' ...
              'FlatSpellBlockMod' 'rFlatSpellBlockModPerLevel' 'FlatHPRegenMod' 'rFlatHPRegenModPerLevel' ...
              'FlatMPRegenMod' 'rFlatMPRegenModPerLevel' 'FlatCritChanceMod' 'rFlatCritDamageModPerLevel' 'FlatPhysicalDamageMod' ...
              'rFlatPhysicalDamageModPerLevel' 'PercentAttackSpeedMod' 'rPercentAttackSpeedModPerLevel' 'FlatMagicDamageMod' ...
              'rFlatMagicDamageModPerLevel' 'rPercentCooldownMod' 'rPercentCooldownModPerLevel' 'FlatMovementSpeedMod' 'rFlatArmorPenetrationMod' ...
              'rPercentArmorPenetrationMod' 'rFlatMagicPenetrationMod' 'rPercentMagicPenetrationMod' 'PercentLifeStealMod' ...
              'PercentSpellVampMod'};
          
    stats = struct2cell(champion.stats); % converts 1x1 champion.stats structure to cell in order to loop through
    
    j = 1;
    for i = 1:length(stats)
        if i ~= 23
            if i ~= 17
                stats{i} = stats{i} + champion.itemstats.(fields{j}) + champion.runestats.(fields{j}) ...
                         + champion.masterystats.(fields{j}) + champion.levelstats.(fields{j});
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
    
    set(handles.desc1, 'String', readable(champion.passive.description))
    % not done in one loop to stop staggering the description/image changes
    for i = 2:5
        set(handles.(['desc' num2str(i)]), 'String', readable(champion.spells{i-1}.tooltip, champion.spells{i-1}))
        set(handles.(['desc' num2str(i) num2str(i)]), 'String', ['Cooldown: ' champion.spells{i-1}.cooldownBurn])
        set(handles.(['desc' num2str(i) num2str(i) num2str(i)]), 'String', ['Cost: ' readable(champion.spells{i-1}.resource)])
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
   
    champion.stats.armorpenetration = 0;
    champion.stats.percentarmorpenetration = 0;
    champion.stats.magicpenetration = 0;
    champion.stats.percentmagicpenetration = 0;
    champion.stats.lifesteal = 0;
    champion.stats.spellvamp = 0;
    champion.itemstats = items.basic.stats;
    champion.runestats = champion.itemstats;
    champion.masterystats = champion.itemstats;
    champion.levelstats = champion.itemstats;
    
    % create/reset item_slots
    item_slots = cell(1,7);
    
    % update champion image from riot's API
    axes(handles.axes1)
    imshow(imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/champion/' champion.id '.png']))
    set(handles.name,'String',champion.id) % set name text to current champion's name
    set(handles.title,'String',champion.title) % set champion's title under champion's name
    
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


% --- Executes on button press in pushbutton38.
function pushbutton38_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function set_level_menus(handles)
    
    global champion
    
    if strcmp(champion.id, 'Jayce')
       list = {0 1 2 3 4 5 6};
       set(handles.rlevels, 'String', {0})
    else
       list = {0 1 2 3 4 5};
    end
    
    set(handles.qlevels, 'String', list)
    set(handles.wlevels, 'String', list)
    set(handles.elevels, 'String', list)
    
    if strcmp(champion.id, 'Udyr')
        set(handles.rlevels, 'String', list)
    elseif strcmp(champion.id, 'Jayce')
        set(handles.rlevels, 'String', 0)
    else
        set(handles.rlevels, 'String', list(1:4))
    end
    
    
% --- Executes on selection change in qlevels.
function qlevels_Callback(hObject, eventdata, handles)
% hObject    handle to qlevels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns qlevels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from qlevels


% --- Executes during object creation, after setting all properties.
function qlevels_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in wlevels.
function wlevels_Callback(hObject, eventdata, handles)
% hObject    handle to wlevels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns wlevels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from wlevels


% --- Executes during object creation, after setting all properties.
function wlevels_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in elevels.
function elevels_Callback(hObject, eventdata, handles)
% hObject    handle to elevels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns elevels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from elevels


% --- Executes during object creation, after setting all properties.
function elevels_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in rlevels.
function rlevels_Callback(hObject, eventdata, handles)
% hObject    handle to rlevels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns rlevels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from rlevels


% --- Executes during object creation, after setting all properties.
function rlevels_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)


    function loadbuild_Callback(hObject, eventdata, handles)


    function new_build_Callback(hObject, eventdata, handles)


    function save_Callback(hObject, eventdata, handles)


    function save_as_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function edit_menu_Callback(hObject, eventdata, handles)


    function clearall_Callback(hObject, eventdata, handles)

    
    function spell_font_Callback(hObject, eventdata, handles)

    
        function font_8_Callback(hObject, eventdata, handles)


        function font_85_Callback(hObject, eventdata, handles)


        function font_9_Callback(hObject, eventdata, handles)

        
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


    function spell_ratios_Callback(hObject, eventdata, handles)


    function level_stats_Callback(hObject, eventdata, handles)


    function item_stats_Callback(hObject, eventdata, handles)


    function rune_stats_Callback(hObject, eventdata, handles)


    function mastery_stats_Callback(hObject, eventdata, handles)










    
