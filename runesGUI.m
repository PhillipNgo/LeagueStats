function varargout = runesGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @runesGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @runesGUI_OutputFcn, ...
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


function load_filters(handles, filter, filter2, filter3)

    global runes % STRUCTURE variable that contains all runes
    global runes_data % CELL variable that holds all items that are part of the results
    rune = struct2cell(runes.data); % converts items.data into a CELL to loop through
    runes_list = {}; % CELL variable that adds all the names of the resultant items
    p = 1; % position in the items_list/items_data cells

    % loop through CELL item
    % if item matches filter/search, add it it runes_data and add its name to rune_list. increase position p.
    for i = 1:length(rune) 
        if ((~isempty(strfind(lower(rune{i}.name), lower(filter))) > 0 || ~isempty(strfind(lower(rune{i}.description), lower(filter))) > 0) && ...
                 ~strcmp(filter, 'red') && ~strcmp(filter, 'yellow') && ~strcmp(filter, 'blue') && ~strcmp(filter, 'black') ...
                  && (find_property_filter(filter2, rune{i}) || strcmp(filter2, 'All')) && (strcmp(rune{i}.rune.tier, filter3) || strcmp(filter3, 'All'))) ...   
           || ((strcmp(rune{i}.rune.type, filter) || strcmp(filter, 'All')) && (find_property_filter(filter2, rune{i}) || strcmp(filter2, 'All')) && ...
                (strcmp(rune{i}.rune.tier, filter3) || strcmp(filter3, 'All'))) ...
           || ((strcmp(rune{i}.rune.type, filter) || strcmp(filter, 'All')) && (find_property_filter(filter2, rune{i}) || strcmp(filter2, 'All')) && ... 
                (strcmp(rune{i}.rune.tier, filter3) || strcmp(filter3, 'All'))) ...
           || ((strcmp(rune{i}.rune.type, filter) || strcmp(filter, 'All')) && (find_property_filter(filter2, rune{i}) || strcmp(filter2, 'All')) && ...
                (strcmp(rune{i}.rune.tier, filter3) || strcmp(filter3, 'All'))) ...
           || ((strcmp(rune{i}.rune.type, filter) || strcmp(filter, 'All')) && (find_property_filter(filter2, rune{i}) || strcmp(filter2, 'All')) && ...
                (strcmp(rune{i}.rune.tier, filter3) || strcmp(filter3, 'All')))
            
            runes_list{p} = rune{i}.name;
            runes_data{p} = rune{i};
            p = p + 1;
        end
    end
    
    % sets resultant runes_list to the values in the third listbox
    set(handles.rune_list, 'String', runes_list);
    
function val = find_property_filter(filter, rune) 

    val = false;
    desc = lower(rune.description);
    switch filter
        case 'Abilities'
            if (~isempty(strfind(desc, 'ability')) || ~isempty(strfind(desc, 'cooldown')) || ~isempty(strfind(desc, 'magic penetration')))
                val = true;
            end
        case 'Defense'
            if ((~isempty(strfind(desc, 'armor')) && isempty(strfind(desc, 'armor pen'))) || ~isempty(strfind(desc, 'magic res')))
                val = true;
            end
        case 'Health'
            if (~isempty(strfind(desc, 'health')))
                val = true;
            end
        case 'Mana'
            if (~isempty(strfind(desc, 'mana')) || ~isempty(strfind(desc, 'energy')))
                val = true;
            end
        case 'Physical Attack'
            if (~isempty(strfind(desc, 'attack')) || ~isempty(strfind(desc, 'crit')) || ~isempty(strfind(desc, 'armor pen')))
                val = true;
            end
        case 'Utility'
            if (~isempty(strfind(desc, 'exp')) || ~isempty(strfind(desc, 'gold')) || ~isempty(strfind(desc, 'time')) || ...
                ~isempty(strfind(desc, 'movement')) || ~isempty(strfind(desc, 'life')) || ~isempty(strfind(desc, 'spell')))
                val = true;
            end
    end

% --- Executes just before runesGUI is made visible.
function runesGUI_OpeningFcn(hObject, eventdata, handles, varargin)

    handles.output = hObject;

    guidata(hObject, handles);

    global version % STRING variable that holds the version of the game
    global runes % STRUCTURE that hols all item data
    global curr_runes
    
    version_link = 'https://global.api.pvp.net/api/lol/static-data/na/v1.2/versions?api_key=f1153217-7b9e-4adc-9036-596a248cb50b';
    version = parse_json(urlread(version_link));
    version = version{1};

    runes_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/rune.json'];
    runes = parse_json(urlread(runes_link));
    
    curr_runes = struct;
    curr_runes.stats = runes.basic.stats;
    curr_runes.names = {};
    curr_runes.num = {};
    curr_runes.runes = {};
    curr_runes.state = false;
    
    % format axis so that it is grey with no #tick marks
    set(gca, 'xtick', [], 'xticklabel', [], 'ytick', [], 'yticklabel', [], 'Color', [.5 .5 .5])
    load_filters(handles, 'All', 'All', 'All'); % load itsm under filter 'All'


% --- Outputs from this function are returned to the command line.
function varargout = runesGUI_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;

 
function combine_filters(handles, search)

    contents = get(handles.rune_type,'Value');
        switch contents
            case 1
                filter1 = 'All';
            case 2
                filter1 = 'red';
            case 3
                filter1 = 'yellow';
            case 4
                filter1 = 'blue';
            case 5
                filter1 = 'black';
        end
        
    if search == true && ~isempty(get(handles.search, 'String'))
        filter1 = get(handles.search, 'String'); % loads filter for search
    end
    
    contents = cellstr(get(handles.rune_property,'String'));
    filter2 = contents{get(handles.rune_property,'Value')}; 
    
    if get(handles.rune_tier,'Value') > 1
        filter3 = num2str(get(handles.rune_tier,'Value')-1);
    else
        filter3 = 'All';
    end  
    
    load_filters(handles, filter1, filter2, filter3)


function search_Callback(hObject, eventdata, handles) %#ok<*INUSL>

    combine_filters(handles, true)

    
% --- Executes during object creation, after setting all properties.
function search_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in rune_type.
function rune_type_Callback(hObject, eventdata, handles)
    
    combine_filters(handles, false)

% --- Executes during object creation, after setting all properties.
function rune_type_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in rune_property.
function rune_property_Callback(hObject, eventdata, handles)

    combine_filters(handles, false)
    

% --- Executes during object creation, after setting all properties.
function rune_property_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
% --- Executes on selection change in rune_tier.
function rune_tier_Callback(hObject, eventdata, handles)

    combine_filters(handles, false)


% --- Executes during object creation, after setting all properties.
function rune_tier_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
function rune_list = get_list()
        
    global curr_runes
    global runes_data
    
    if curr_runes.state == true
        rune_list = curr_runes.runes;
        curr_runes.state = false;
    else
        rune_list = runes_data;
    end
    
    
% --- Executes on selection change in rune_list.
function rune_list_Callback(hObject, eventdata, handles)

    global version 
    global chosen_rune % STRUCTURE variable that holds the currently selected rune
    rune_list = get_list(); % list of filtered runes
    
    chosen_rune = rune_list{get(hObject,'Value')}; % chosen_rune set to currently selected rune
    % set currently selected items image to axis
    imshow(imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/rune/' rune_list{get(hObject,'Value')}.image.full]));
    
    name = chosen_rune.name;
    if strcmp(name(1:6), 'Lesser')
        name = name(7:length(name));
    elseif strcmp(name(1:7), 'Greater') 
        name = name(8:length(name));
    end
    
    set(handles.name, 'String', name) % name text set to rune name
    set(handles.tier, 'String', num2str(chosen_rune.rune.tier)) % tier text set to rune tier
    set(handles.desc, 'String', chosen_rune.description) % desc text set to rune description
    %disp(chosen_rune.tags{1}) % uncomment to see item code when clicked on

    set(handles.add_text, 'String', '0')
    set(handles.add_slider, 'Value', 0)
    set(handles.add_slider, 'Max', max_value(handles, 'add'))
    
    set(handles.remove_text, 'String', '0')
    set(handles.remove_slider, 'Value', 0)
    set(handles.remove_slider, 'Max', max_value(handles, 'remove'))
    
    if get(handles.add_slider, 'Max') ~= .5
        set(handles.add_slider, 'SliderStep', [1/get(handles.add_slider, 'Max') 10/get(handles.add_slider, 'Max')])
    end
    if get(handles.remove_slider, 'Max') ~= .5
        set(handles.remove_slider, 'SliderStep', [1/get(handles.remove_slider, 'Max') 10/get(handles.remove_slider, 'Max')])
    end
    
% --- Executes during object creation, after setting all properties.
function rune_list_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
% --- Executes on button press in add_runes.
function add_runes_Callback(hObject, eventdata, handles)

    global curr_runes % get chosen_item
    
    curr_runes = rmfield(curr_runes, 'state');
    curr_runes = rmfield(curr_runes, 'runes');
    % set appdata 'rune' to chosen_item to be retrieved by LeagueStatsGUI
    setappdata(0, 'rune', chosen_item)
    % close the GUI
    close(itemsGUI)

    
% --- Executes on button press in clear_runes.
function clear_runes_Callback(hObject, eventdata, handles)
    
    global curr_runes
    global chosen_rune
    global runes
    
    curr_runes.stats = runes.basic.stats;
    curr_runes.names = {};
    curr_runes.num = {};
    curr_runes.runes = {};
    curr_runes.state = false;
    
    for i = 1:4
        set(handles.(['count' num2str(i)]), 'String', '0')
    end
    
    set(handles.add_text, 'String', '0')
    set(handles.add_slider, 'Value', 0)
    set(handles.remove_text, 'String', '0')
    set(handles.remove_slider, 'Value', 0)
    
    if ~isempty(chosen_rune)
        set(handles.add_slider, 'Max', max_value(handles, 'add'))
        set(handles.remove_slider, 'Max', max_value(handles, 'remove'))
        if get(handles.add_slider, 'Max') ~= .5
            set(handles.add_slider, 'SliderStep', [1/get(handles.add_slider, 'Max') 10/get(handles.add_slider, 'Max')])
        end
        if get(handles.remove_slider, 'Max') ~= .5
            set(handles.remove_slider, 'SliderStep', [1/get(handles.remove_slider, 'Max') 10/get(handles.remove_slider, 'Max')])
        end
    end
   
    set(handles.current_runes, 'String', {})

    
% --- Executes on selection change in current_runes.
function current_runes_Callback(hObject, eventdata, handles)
    
    global curr_runes
    
    if get(hObject, 'Value') ~= 0
        curr_runes.state = true;
        rune_list_Callback(hObject, eventdata, handles)
    end
    

% --- Executes during object creation, after setting all properties.
function current_runes_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
% --- Executes on button press in add.
function add_Callback(hObject, eventdata, handles)

    global chosen_rune
    global curr_runes
    
    if get(handles.add_slider, 'Value') > 0
        max = 9;
        switch chosen_rune.rune.type
            case 'red'
                field = 'count1';
            case 'yellow'
                field = 'count2';
            case 'blue'
                field = 'count3';
            case 'black'
                field = 'count4';
                max = 3;
        end
        curr_num = str2double(get(handles.(field), 'String'));
        set(handles.(field), 'String', num2str(curr_num + str2double(get(handles.add_text, 'String'))));
        
        if isempty(find(ismember(curr_runes.names, chosen_rune.name), 1))
            curr_runes.names = [curr_runes.names chosen_rune.name];
            curr_runes.num = [curr_runes.num 0];
            curr_runes.runes = [curr_runes.runes chosen_rune];
        end
        
        fields = fieldnames(chosen_rune.stats);
        for i = 1:length(fields)
            curr_runes.stats.(fields{i}) = curr_runes.stats.(fields{i}) + chosen_rune.stats.(fields{i})*str2double(get(handles.add_text, 'String'));
        end
        
        curr_runes.num{find(ismember(curr_runes.names, chosen_rune.name), 1)} = curr_runes.num{find(ismember(curr_runes.names, chosen_rune.name), 1)} + str2double(get(handles.add_text, 'String'));
        
        for i = 1:length(curr_runes.num)
            new_list{i} = [num2str(curr_runes.num{i}) 'x ' curr_runes.names{i}];
        end
        if get(handles.current_runes, 'Value') ~= length(new_list)
            set(handles.current_runes, 'Value', length(new_list))
        end
        set(handles.current_runes, 'String', new_list)
        
        if str2double(get(handles.(field), 'String')) + str2double(get(handles.add_text, 'String')) > max
            set(handles.add_text, 'String', 0)
            set(handles.add_slider, 'Value', 0)
        end
        
        set(handles.remove_slider, 'Max', max_value(handles, 'remove'))
        set(handles.remove_slider, 'SliderStep', [1/(max_value(handles, 'remove')) 10/(max_value(handles, 'remove'))])
        
        set(handles.add_slider, 'Max', max_value(handles, 'add'))
        if get(handles.add_slider, 'Max') ~= .5
            set(handles.add_slider, 'SliderStep', [1/(max_value(handles, 'add')) 10/(max_value(handles, 'add'))])
        end
    end
    
    
function add_text_Callback(hObject, eventdata, handles)

    num = str2double(get(hObject, 'String'));
    if isnan(num) || num < 0 || num ~= int8(num) || num > max_value(handles, 'add')
        errordlg('invalid input')
        set(hObject, 'String', '0')
    else
        set(handles.add_slider, 'Value', str2double(get(hObject, 'String')))
    end
    
    
% --- Executes on slider movement.
function add_slider_Callback(hObject, eventdata, handles)
    
    if get(hObject, 'Value') ~= int8(get(hObject, 'Value'))
        set(hObject, 'Value', 0)
    end
    set(handles.add_text, 'String', num2str(get(hObject,'Value')));


% --- Executes during object creation, after setting all properties.
function add_slider_CreateFcn(hObject, eventdata, handles)

    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

    
% --- Executes during object creation, after setting all properties.
function add_text_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    

% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
    
    global chosen_rune
    global curr_runes
    
    if str2double(get(handles.remove_text, 'String')) > 0
        switch chosen_rune.rune.type
            case 'red'
                field = 'count1';
            case 'yellow'
                field = 'count2';
            case 'blue'
                field = 'count3';
            case 'black'
                field = 'count4';
        end
        curr_num = str2double(get(handles.(field), 'String'));
        set(handles.(field), 'String', num2str(curr_num - str2double(get(handles.remove_text, 'String'))));        
        
        fields = fieldnames(chosen_rune.stats);
        for i = 1:length(fields)
            curr_runes.stats.(fields{i}) = curr_runes.stats.(fields{i}) - chosen_rune.stats.(fields{i})*str2double(get(handles.remove_text, 'String'));
        end
        
        ind =  find(ismember(curr_runes.names, chosen_rune.name), 1);
        curr_runes.num{ind} = curr_runes.num{ind} - str2double(get(handles.remove_text, 'String'));
        
        if curr_runes.num{ind} == 0
            curr_runes.num(:,ind) = [];
            curr_runes.names(:,ind) = [];
            curr_runes.runes(:,ind) = [];
        end
        
        new_list = {};
        for i = 1:length(curr_runes.num)
            new_list{i} = [num2str(curr_runes.num{i}) 'x ' curr_runes.names{i}];
        end
        if get(handles.current_runes, 'Value') ~= length(new_list)
            set(handles.current_runes, 'Value', length(new_list))
        end
        set(handles.current_runes, 'String', new_list)
        
        
        if max_value(handles, 'remove') - str2double(get(handles.remove_text, 'String')) < 0
            set(handles.remove_text, 'String', 0)
            set(handles.remove_slider, 'Value', 0)
        end
        
        set(handles.add_slider, 'Max', max_value(handles, 'add'))
        set(handles.add_slider, 'SliderStep', [1/(max_value(handles, 'add')) 10/(max_value(handles, 'add'))])
        set(handles.remove_slider, 'Max', max_value(handles, 'remove'))
        
        if get(handles.remove_slider, 'Max') ~= .5
            set(handles.remove_slider, 'SliderStep', [1/(max_value(handles, 'remove')) 10/(max_value(handles, 'remove'))])
        end
    end
    
    
function max = max_value(handles, type)
    
    global chosen_rune
    global curr_runes
    
    max = 9;
    switch chosen_rune.rune.type
        case 'red'
            curr_num = str2double(get(handles.count1, 'String'));
            type2 = 'Mark';
        case 'yellow'
            curr_num = str2double(get(handles.count2, 'String'));
            type2 = 'Seal';
        case 'blue'
            curr_num = str2double(get(handles.count3, 'String'));
            type2 = 'Glyph';
        case 'black'
            curr_num = str2double(get(handles.count4, 'String'));    
            type2 = 'Quint';
            max = 3;
    end
    if strcmp(type, 'add')
        max = max - curr_num;
    elseif strcmp(type, 'remove')
        index = find(cellfun('length',regexp(curr_runes.names, type2)) == 1);
        if ~isempty(index)
            for i = 1:length(index)
                if ~strcmp(curr_runes.names{index(i)}, chosen_rune.name)
                    curr_num = curr_num - curr_runes.num{index(i)};
                end
            end
        end
        max = curr_num;
    end        
    
    if max == 0 
        max = .5;
    end

    
function remove_text_Callback(hObject, eventdata, handles)

    num = str2double(get(hObject, 'String'));
    if isnan(num) || num < 0 || num ~= int8(num) || num > max_value(handles, 'remove')
        errordlg('invalid input')
        set(hObject, 'String', '0')
    else
        set(handles.remove_slider, 'Value', str2double(get(hObject, 'String')))
    end
    
    
% --- Executes during object creation, after setting all properties.
function remove_text_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
% --- Executes on slider movement.
function remove_slider_Callback(hObject, eventdata, handles)
    
    if get(hObject, 'Value') ~= int8(get(hObject, 'Value'))
        set(hObject, 'Value', 0)
    end
    set(handles.remove_text, 'String', num2str(get(hObject,'Value')));


% --- Executes during object creation, after setting all properties.
function remove_slider_CreateFcn(hObject, eventdata, handles)

    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end











    
    
    
