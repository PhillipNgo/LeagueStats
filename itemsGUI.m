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


function load_filters(handles, filter)

    global items
    global items_data
    item = struct2cell(items.data);
    items_list = {'None'};
    p = 2;

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

    set(handles.item_list, 'String', items_list);

% --- Executes just before itemsGUI is made visible.
function itemsGUI_OpeningFcn(hObject, eventdata, handles, varargin)

    handles.output = hObject;

    guidata(hObject, handles);


    global version
    global items

    version_link = 'https://global.api.pvp.net/api/lol/static-data/na/v1.2/versions?api_key=f1153217-7b9e-4adc-9036-596a248cb50b';
    version = parse_json(urlread(version_link));
    version = version{1};

    items_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/item.json'];
    items = parse_json(urlread(items_link));
    set(gca, 'xtick', [], 'xticklabel', [], 'ytick', [], 'yticklabel', [])
    load_filters(handles, 'All');


% --- Outputs from this function are returned to the command line.
function varargout = itemsGUI_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;


% --- Executes on selection change in filters.
function filters_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns filters contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filters

    contents = cellstr(get(hObject,'String'));
    filter = contents{get(hObject,'Value')};
    load_filters(handles, filter);
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

    global chosen_item

    setappdata(0, 'item', chosen_item)
    close(itemsGUI)

    
% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles) %#ok<*INUSD>

    setappdata(0, 'item', 'Item Slot')
    close(itemsGUI)


% --- Executes on selection change in item_list.
function item_list_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns item_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from item_list

    global items_data
    global version
    global chosen_item
    switch (get(hObject,'Value'))
        case 1
          cla
          chosen_item = 'Item Slot';
          set(handles.name, 'String', 'Name')
          set(handles.price, 'String', 'N/A')
          set(handles.sell, 'String', 'N/A')
          set(handles.stats, 'String', 'Details')
        otherwise
          chosen_item = items_data{get(hObject,'Value')-1};
          imshow(imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/item/' items_data{get(hObject,'Value')-1}.image.full])); 
          set(handles.name, 'String', items_data{get(hObject,'Value')-1}.name)
          set(handles.price, 'String', num2str(items_data{get(hObject,'Value')-1}.gold.total))
          set(handles.sell, 'String', num2str(items_data{get(hObject,'Value')-1}.gold.sell))
          set(handles.stats, 'String', items_data{get(hObject,'Value')-1}.description)
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

    filter = get(handles.item_search, 'String');
    if isempty(filter)
        load_filters(handles, 'All');
    else
        load_filters(handles, filter);
    end

    
% --- Executes during object creation, after setting all properties.
function item_search_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
