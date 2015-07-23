function varargout = masteriesGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @masteriesGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @masteriesGUI_OutputFcn, ...
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


% --- Executes just before masteriesGUI is made visible.
function masteriesGUI_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

    handles.output = hObject;
    guidata(hObject, handles);

    global version % STRING variable that holds the version of the game
    global masteries % VECTOR variable that holds the stats static text handles
    global click_type
    global list
    global level_info
    global points
    
    % reads riot's API and places the most current game version in the version variable
    version_link = 'https://global.api.pvp.net/api/lol/static-data/na/v1.2/versions?api_key=f1153217-7b9e-4adc-9036-596a248cb50b';
    version = parse_json(urlread(version_link));
    version = version{1};
%     version = '5.13.1';
    
    mastery_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/mastery.json'];
    masteries = parse_json(urlread(mastery_link));
    click_type = 'add';
    points = 30;
    level_info = struct;
    list = {};
    
    ax = 1;
    for i = 1:3
        switch i
            case 1
                type = 'Offense';
                title = '#8B0000';
            case 2
                ax = 25;
                type = 'Defense';
                title = '#4169E1';
            case 3
                ax = 49;
                type = 'Utility';
                title = '#228B22';
        end
        tree = masteries.tree.(type);
        for j = 1:length(tree)
            level = tree{j};
            for k = 1:length(level)
                button = handles.(['pushbutton' num2str(ax)]);
                if ~isempty(level{k})
                    im = imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/mastery/' level{k}.masteryId '.png']);
                    set(button, 'CData', imresize(im, .8))
                    set(handles.(['text' num2str(ax)]), 'String', ['0/' num2str(masteries.data.(['alpha_' level{k}.masteryId]).ranks)] ,'BackgroundColor', 'k', 'ForegroundColor', 'y')
                    if (j-1)*4 ~= 0
                        req = ['<font color="red">' 'Requires ' num2str((j-1)*4) ' points in ' type '</font><br>'];
                    else 
                        req = '';
                    end
                    if strcmp(masteries.data.(['alpha_' level{k}.masteryId]).prereq, '0')
                        req = [req '<br>'];
                    else
                        req = [req '<font color="red">' 'Requires ' num2str(masteries.data.(['alpha_' masteries.data.(['alpha_' level{k}.masteryId]).prereq]).ranks) ' points in ' masteries.data.(['alpha_' masteries.data.(['alpha_' level{k}.masteryId]).prereq]).name '</font><br><br>'];
                    end
                    if (j < 2)
                        rank = '#008000';
                    else
                        rank = '#2F4F4F';
                    end
                    set(button, 'tooltipstring', ['<html><b><font color="' title '" size="5">' masteries.data.(['alpha_' level{k}.masteryId]).name '</font></b><br>' ...
                                                  '<font color="' rank '">' 'Rank: ' get(handles.(['text' num2str(ax)]), 'String') '</font><br>' ...
                                                  req ...
                                                  masteries.data.(['alpha_' level{k}.masteryId]).description{1} '<br><br>'])
                    list = [list num2str(ax)];
                     %set(button, 'Callback', 'button_callback(handles, hObject)')
                    level_info.(['alpha_' level{k}.masteryId]).level = j;
                    level_info.(['alpha_' level{k}.masteryId]).index = length(list);
                else
                    set(button,'visible','off')
                    set(handles.(['text' num2str(ax)]), 'visible', 'off')
                end
                ax = ax + 1;
            end
        end
    end
    
    for i = 1:3
        axes(handles.(['axes' num2str(i)])) %#ok<*LAXES>
        imshow(imread([cd '\backgrounds\mb' num2str(i) '.jpg']))
    end


function varargout = masteriesGUI_OutputFcn(hObject, eventdata, handles) 
    
    varargout{1} = handles.output;

    jb = findjobj('class', 'button');
    for i = 1:length(jb)
        jb(1,i).setBorderPainted(false);
    end
    
function pushbutton1_ButtonDownFcn(hObject, eventdata, handles)
    
    button_callback(handles, hObject)
    
function alpha = find_alpha(handles, tag)
    
    global list
    global masteries
    
    fields = fieldnames(masteries.data);
    for i = 1:length(list)
        if strcmp(tag(11:length(tag)), list{i})
            alpha = fields{i};
        end
    end

    
function count = count_tree(handles, num)
 
    start = (floor(num/24)*24) + 1;
    count = 0;
    
    for i = start:start+23
        str = get(handles.(['text' num2str(i)]), 'String');
        count = count + str2double(str(1));
    end


function update_tooltips(handles, num)

    global level_info
    global masteries
    global list
   
    num = (floor(num/24)*24) + 1;
    switch num
        case 1
            range = 1:20;
        case 2
            range = 21:39;
        case 3
            range = 40:57;
    end
    
    fields = fieldnames(masteries.data);
    for i = range
        num = list{level_info.(fields{i}).index};
        
        if str2double(num) > 48
            type = 'Utility';
            title = '#228B22';
        elseif str2double(num) > 24
            type = 'Defense';
            title = '#4169E1';
        else
            type = 'Offense';
            title = '#8B0000';
        end
       
        req = '';
        
        if count_tree(handles, str2double(num)) < (level_info.(fields{i}).level-1)*4
            req = ['<font color="red">' 'Requires ' num2str((level_info.(fields{i}).level-1)*4) ' points in ' type '</font><br>'];
        end
        if ~strcmp(masteries.data.(fields{i}).prereq, '0')
            str = get(handles.(['text' list{level_info.(['alpha_' masteries.data.(fields{i}).prereq]).index}]), 'String');
            if ~strcmp(str(1), str(3))
                req = [req '<font color="red">' 'Requires ' num2str(masteries.data.(['alpha_' masteries.data.(fields{i}).prereq]).ranks) ' points in ' masteries.data.(['alpha_' masteries.data.(fields{i}).prereq]).name '</font><br>'];
            end
        end
        
        req = [req '<br>'];
        
        if count_tree(handles, str2double(num)) < (level_info.(fields{i}).level-1)*4
            rank = '#2F4F4F';
        else
            rank = '#008000';
        end
        
        str = get(handles.(['text' num]), 'String');
        
        if strcmp(str(1), '0')
            desc = masteries.data.(fields{i}).description{1};
        else
            desc = masteries.data.(fields{i}).description{str2double(str(1))};
        end
        
        if ~strcmp(str(1), '0') && str2double(str(1)) < str2double(str(3))
            desc = [desc '<br><br>' 'Next Rank:' '<br>' masteries.data.(fields{i}).description{str2double(str(1)) + 1}];
        end
        
        set(handles.(['pushbutton' num]), 'tooltipstring', ... 
            ['<html><b><font color="' title '" size="5">' masteries.data.(fields{i}).name '</font></b><br>' ...
            '<font color="' rank '">' 'Rank: ' get(handles.(['text' num]), 'String') '</font><br>' ...
            req ...
            desc '<br><br>'])
    end
     

function button_callback(handles, object)
    
    global points
    global level_info
    global masteries
    global click_type
    
    tag = get(object, 'tag');
    alpha = find_alpha(handles, tag);
    num = tag(11:length(tag));
    str = get(handles.(['text' num]), 'String');
    rank = str2double(str(1));
    
    if strcmp(click_type, 'add')
        if rank < masteries.data.(alpha).ranks && points > 0 && count_tree(handles, str2double(num)) >= (level_info.(alpha).level-1) * 4
            set(handles.(['text' num]), 'String', [num2str(rank+1) str(2:3)])
            points = points - 1;
            update_tooltips(handles, str2double(num))
        end
    elseif strcmp(click_type, 'remove')
        if rank ~= 0
            set(handles.(['text' num]), 'String', [num2str(rank-1) str(2:3)])
            points = points + 1;
            update_tooltips(handles, str2double(num))
        end
    end
    

function text = readable(text)
    
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
        i = i + 1;
    end
    
    
% --- Executes on button press in add_masteries.
function add_masteries_Callback(hObject, eventdata, handles)



% --- Executes on button press in clear_masteries.
function clear_masteries_Callback(hObject, eventdata, handles)
    keyboard
    
% --- Executes on button press in add_click.
function add_click_Callback(hObject, eventdata, handles)
    
    global click_type
    click_type = 'add';
    set(hObject, 'Value', 1)
    set(handles.remove_click, 'Value', 0)

    
% --- Executes on button press in remove_click.
function remove_click_Callback(hObject, eventdata, handles)

    global click_type
    click_type = 'remove';
    set(hObject, 'Value', 1)
    set(handles.add_click, 'Value', 0)
    
    
% --- Executes on button press in pushbutton49.
function pushbutton49_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)

    
% --- Executes on button press in pushbutton50.
function pushbutton50_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton51.
function pushbutton51_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton52.
function pushbutton52_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)

% --- Executes on button press in pushbutton53.
function pushbutton53_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton54.
function pushbutton54_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton55.
function pushbutton55_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton56.
function pushbutton56_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton57.
function pushbutton57_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton58.
function pushbutton58_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton59.
function pushbutton59_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton60.
function pushbutton60_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton61.
function pushbutton61_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)

% --- Executes on button press in pushbutton62.
function pushbutton62_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton63.
function pushbutton63_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)

% --- Executes on button press in pushbutton64.
function pushbutton64_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton65.
function pushbutton65_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)

% --- Executes on button press in pushbutton66.
function pushbutton66_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton67.
function pushbutton67_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)

% --- Executes on button press in pushbutton68.
function pushbutton68_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton69.
function pushbutton69_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton70.
function pushbutton70_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton71.
function pushbutton71_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)
    

% --- Executes on button press in pushbutton72.
function pushbutton72_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)
    

% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton35.
function pushbutton35_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton36.
function pushbutton36_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton37.
function pushbutton37_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton38.
function pushbutton38_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton39.
function pushbutton39_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton40.
function pushbutton40_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton41.
function pushbutton41_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)
    

% --- Executes on button press in pushbutton42.
function pushbutton42_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton43.
function pushbutton43_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton44.
function pushbutton44_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton45.
function pushbutton45_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)
    

% --- Executes on button press in pushbutton46.
function pushbutton46_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton47.
function pushbutton47_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton48.
function pushbutton48_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    
    button_callback(handles, hObject)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)

    
% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)
    

% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)

    button_callback(handles, hObject)


    
