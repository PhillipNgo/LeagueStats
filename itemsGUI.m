function varargout = itemsGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @itemsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @itemsGUI_OutputFcn, ...
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

% --- Function that display filter/search results in the second listbox
function load_filters(handles, filter)

    global items % STRUCTURE variable that contains all items
    global items_data % CELL variable that holds all items that are part of the results
    item = struct2cell(items.data); % converts items.data into a CELL to loop through
    items_list = {'None'}; % CELL variable that adds all the names of the resultant items
    p = 2; % position in the items_list/items_data cells

    % loop through CELL item
    % if item matches filter/search, add it it items_data and add its name to item_list. increase position p.
    for i = 1:length(item) 
        if strcmp(filter, 'All')
            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;
        elseif strcmp(filter, 'Health') && (isfield(item{i}.stats, 'FlatHPPoolMod') || ...
           isfield(item{i}.stats, 'rFlatHPModPerLevel') || isfield(item{i}.stats, 'PercentHPPoolMod'))

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;

        elseif strcmp(filter, 'Mana') && (isfield(item{i}.stats, 'FlatMPPoolMod') || ...
               isfield(item{i}.stats, 'rFlatMPModPerLevel') || isfield(item{i}.stats, 'PercentMPPoolMod'))

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;

        elseif strcmp(filter, 'Health Regen') && (isfield(item{i}.stats, 'FlatHPRegenMod') || ...
               isfield(item{i}.stats, 'rFlatHPRegenModPerLevel') || isfield(item{i}.stats, 'PercentHPRegenMod') ...
               || sum(ismember(item{i}.tags, 'HealthRegen')) > 0)

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;

        elseif strcmp(filter, 'Mana Regen') && (isfield(item{i}.stats, 'FlatMPRegenMod') || ...
               isfield(item{i}.stats, 'rFlatMPRegenModPerLevel') || isfield(item{i}.stats, 'PercentMPRegenMod') ...
               || sum(ismember(item{i}.tags, 'ManaRegen')) > 0)

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;

        elseif strcmp(filter, 'Armor') && (isfield(item{i}.stats, 'FlatArmorMod') || ...
               isfield(item{i}.stats, 'rFlatArmorPerLevel') || isfield(item{i}.stats, 'PercentArmorMod'))

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;

        elseif strcmp(filter, 'Damage') && (isfield(item{i}.stats, 'FlatPhysicalDamageMod') || ...
               isfield(item{i}.stats, 'rFlatPhysicalDamagePerLevel') || isfield(item{i}.stats, 'PercentPhysicalDamageMod'))

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;

        elseif strcmp(filter, 'Ability Power') && (isfield(item{i}.stats, 'FlatMagicDamageMod') || ...
               isfield(item{i}.stats, 'rFlatMagicDamagePerLevel') || isfield(item{i}.stats, 'PercentMagicDamageMod'))

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;

        elseif strcmp(filter, 'Movement Speed') && (isfield(item{i}.stats, 'FlatMovementSpeedMod') || ...
               isfield(item{i}.stats, 'rFlatMovementSpeedPerLevel') || isfield(item{i}.stats, 'PercentMovementSpeedMod') ...
               || isfield(item{i}.stats, 'rPercentMovementSpeedModPerLevel'))

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;

        elseif strcmp(filter, 'Attack Speed') && (isfield(item{i}.stats, 'FlatAttackSpeedMod') || ...
               isfield(item{i}.stats, 'rPercentAttackSpeedModPerLevel') || isfield(item{i}.stats, 'PercentAttackSpeedMod'))

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;

        elseif strcmp(filter, 'Critical Strike') && (isfield(item{i}.stats, 'FlatCritChanceMod') || ...
               isfield(item{i}.stats, 'rFlatCritChanceModPerLevel') || isfield(item{i}.stats, 'PercentCritChanceMod') ...
               || isfield(item{i}.stats, 'FlatCritDamageMod') || isfield(item{i}.stats, 'rFlatCritDamageModPerLevel') ...
               || isfield(item{i}.stats, 'PercentCritDamageMod'))

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;

        elseif strcmp(filter, 'Magic Resist') && (isfield(item{i}.stats, 'FlatSpellBlockMod') || ...
               isfield(item{i}.stats, 'rFlatSpellBlockPerLevel') || isfield(item{i}.stats, 'PercentSpellBlockMod'))

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;

        elseif strcmp(filter, 'Cooldown Reduction') && (isfield(item{i}.stats, 'rPercentCooldownMod') || ...
               isfield(item{i}.stats, 'rPercentCooldownModPerLevel')|| sum(ismember(item{i}.tags, 'CooldownReduction')) > 0)

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;

        elseif strcmp(filter, 'Life Steal') && isfield(item{i}.stats, 'PercentLifeStealMod')

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;

        elseif strcmp(filter, 'Spell Vamp') && (isfield(item{i}.stats, 'PercentSpellVampMod') || sum(ismember(item{i}.tags, 'SpellVamp')) > 0)

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;

        elseif strcmp(filter, 'Tenacity') && sum(ismember(item{i}.tags, 'Tenacity')) > 0

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;
        elseif ~isempty(strfind(lower(item{i}.name), lower(filter))) > 0

            items_list{p} = item{i}.name;
            items_data{p-1} = item{i};
            p = p + 1;
        end
    end
    
    % sets resultant items_list to the values in the second listbox
    set(handles.item_list, 'String', items_list);
    
% --- Function that takes an item description (text), removes all special formatting, and adds line breaks where necessary
function text = readable(text)
    
    i = 1; % the position within the string
    while i < length(text) % loop through the string
        if strcmp(text(i), '<') % '>' notes the beginning of special formatting
            while ~strcmp(text(i), '>') % '<' notes the end of special formatting
                if strcmp(text(i), 'b') % <br> is notation for linebreak
                    text(i) = char(10); % char(10) adds linebreak
                    i = i + 1; 
                end
                text(i) = ''; % remove letter at current position
            end
            text(i) = ''; 
            i = i - 1;
        end
        i = i + 1;
    end

% --- Executes just before itemsGUI is made visible.
function itemsGUI_OpeningFcn(hObject, eventdata, handles, varargin)

    handles.output = hObject;

    guidata(hObject, handles);


    global version % STRING variable that holds the version of the game
    global items % STRUCTURE that hols all item data

    version_link = 'https://global.api.pvp.net/api/lol/static-data/na/v1.2/versions?api_key=f1153217-7b9e-4adc-9036-596a248cb50b';
    version = parse_json(urlread(version_link));
    version = version{1};

    items_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/item.json'];
    items = parse_json(urlread(items_link));
    
    % format axis so that it is grey with no #tick marks
    set(gca, 'xtick', [], 'xticklabel', [], 'ytick', [], 'yticklabel', [], 'Color', [.5 .5 .5])
    load_filters(handles, 'All'); % load itsm under filter 'All'


% --- Outputs from this function are returned to the command line.
function varargout = itemsGUI_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;


% --- Executes on selection change in filters.
function filters_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns filters contents as cell array
%        filter = contents{get(hObject,'Value')} returns selected item from filters

    contents = cellstr(get(hObject,'String'));
    filter = contents{get(hObject,'Value')};
    
    % load filter for currently selected filter
    load_filters(handles, filter);
    % set the second listbox value to 'None'
    set(handles.item_list, 'Value', 1)


% --- Executes during object creation, after setting all properties.
function filters_CreateFcn(hObject, eventdata, handles)
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in add_item.
function add_item_Callback(hObject, eventdata, handles)

    global chosen_item % get chosen_item
    
    % set appdata 'item' to chosen_item to be retrieved by testGUI
    setappdata(0, 'item', chosen_item)
    % close the GUI
    close(itemsGUI)

    
% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles) %#ok<*INUSD>
    
    % set appdata 'item' to 'Item Slot' (no item) to be retrieved by testGUI
    setappdata(0, 'item', 'Item Slot')
    % close the GUI
    close(itemsGUI)


% --- Executes on selection change in item_list.
function item_list_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns item_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from item_list

    global items_data % list of filtered items
    global version 
    global chosen_item % STRUCTURE variable that holds the current selected item
    switch (get(hObject,'Value'))
        case 1 % if 'None' is selected
          cla(handles.axes1,'reset') % reset image on axis
          set(gca, 'xtick', [], 'xticklabel', [], 'ytick', [], 'yticklabel', [], 'Color', [.5 .5 .5]) % set axis to grey with no tick marks
          chosen_item = 'Item Slot'; % chosen_item set to 'Item Slot' (no item)
          set(handles.name, 'String', 'Name') % name text set to 'Name'
          set(handles.price, 'String', 'N/A') % price text set to 'N/A'
          set(handles.sell, 'String', 'N/A') % sell text set to 'N/A'
          set(handles.stats, 'String', 'Details') % details text set to 'Details'
        otherwise
          chosen_item = items_data{get(hObject,'Value')-1}; % chosen_item set to currently selected item
          % set currently selected items image to axis 
          imshow(imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/item/' items_data{get(hObject,'Value')-1}.image.full])); 
          set(handles.name, 'String', items_data{get(hObject,'Value')-1}.name) % name text set to item name
          set(handles.price, 'String', num2str(items_data{get(hObject,'Value')-1}.gold.total)) % price text set to total item's price
          set(handles.sell, 'String', num2str(items_data{get(hObject,'Value')-1}.gold.sell)) % sell text set to item's sell price
          set(handles.stats, 'String', readable(items_data{get(hObject,'Value')-1}.description)) % details text set to item description
          % disp(chosen_item.image.full) %uncomment to see item code
    end
    
    
% --- Executes during object creation, after setting all properties.
function item_list_CreateFcn(hObject, eventdata, handles)
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function item_search_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of item_search as text
%        str2double(get(hObject,'String')) returns contents of item_search as a double

    % set filter to 'All' and listbox2 to 'None'
    set(handles.filters, 'Value', 1)
    set(handles.item_list, 'Value', 1)
    
    search = get(handles.item_search, 'String'); % gets the search text
    if isempty(search) % if no search, loads all items
        load_filters(handles, 'All');
    else
        load_filters(handles, search); % loads filter for search
    end

    
% --- Executes during object creation, after setting all properties.
function item_search_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
