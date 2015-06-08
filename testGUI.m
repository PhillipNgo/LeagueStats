function varargout = testGUI(varargin)
% TESTGUI MATLAB code for testGUI.fig
%      TESTGUI, by itself, creates a new TESTGUI or raises the existing
%      singleton*.
%
%      H = TESTGUI returns the handle to a new TESTGUI or the handle to
%      the existing singleton*.
%
%      TESTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTGUI.M with the given input arguments.
%
%      TESTGUI('Property','Value',...) creates a new TESTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testGUI

% Last Modified by GUIDE v2.5 06-Jun-2015 21:05:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @testGUI_OutputFcn, ...
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


% --- Executes just before testGUI is made visible.
function testGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testGUI (see VARARGIN)

% Choose default command line output for testGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes testGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global version
global champion
global static_texts

version_link = 'https://global.api.pvp.net/api/lol/static-data/na/v1.2/versions?api_key=f1153217-7b9e-4adc-9036-596a248cb50b';
version = parse_json(urlread(version_link));
version = version{1};

champion_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/champion/Aatrox.json'];
champion = parse_json(urlread(champion_link));
champion = struct2cell(champion.data);
champion = champion{1};

static_texts = [handles.hp handles.hpperlevel handles.mp handles.mpperlevel handles.movespeed handles.armor ...
                handles.armorperlevel handles.spellblock handles.spellblockperlevel handles.attackrange ...
                handles.hpregen handles.hpregenperlevel handles.mpregen handles.mpregenperlevel handles.crit ...
                handles.critperlevel handles.attackdamage handles.attackdamageperlevel handles.attackspeed ...
                handles.attackspeedperlevel];

imshow(imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/champion/Aatrox.png']));

% --- Outputs from this function are returned to the command line.
function varargout = testGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in champion_menu.
function champion_menu_Callback(hObject, eventdata, handles)
% hObject    handle to champion_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns champion_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from champion_menu

global version
global champion
global static_texts

champion_list = cellstr(get(hObject,'String'));
selected_champion = champion_list{get(hObject,'Value')};

champion_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/champion/' selected_champion '.json'];
champion = parse_json(urlread(champion_link));
champion = struct2cell(champion.data);
champion = champion{1};

imshow(imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/champion/' selected_champion '.png']));
%{ 
   Champion Stat Names. Example Call: champion.stats.hp
    'hp'
    'hpperlevel'
    'mp'
    'mpperlevel'
    'movespeed'
    'armor'
    'armorperlevel'
    'spellblock'
    'spellblockperlevel'
    'attackrange'
    'hpregen'
    'hpregenperlevel'
    'mpregen'
    'mpregenperlevel'
    'crit'
    'critperlevel'
    'attackdamage'
    'attackdamageperlevel'
    'attackspeedoffset'
    'attackspeedperlevel'
%}

set(handles.name,'String',champion.id)
set(handles.title,'String',champion.title)

stats = struct2cell(champion.stats);
for i = 1:length(static_texts)
    if i ~= 19
        set(static_texts(i), 'String' , num2str(stats{i}))
    else
        set(static_texts(i), 'String', num2str(.625/(1+stats{i})))
    end
end

% --- Executes during object creation, after setting all properties.
function champion_menu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global version

all_champions_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/champion.json'];
champions = parse_json(urlread(all_champions_link));

set(hObject, 'String', fieldnames(champions.data));



