clear, clc


%% Get Client Version
version_link = 'https://global.api.pvp.net/api/lol/static-data/na/v1.2/versions?api_key=f1153217-7b9e-4adc-9036-596a248cb50b';
version = parse_json(urlread(version_link));
version = version{1};

%% Load All Champions and Items data
all_champions_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/champion.json'];
items_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/item.json'];

champions = parse_json(urlread(all_champions_link));
items = parse_json(urlread(items_link));

%% Load a Specific Champion
champion = 'Aatrox'; % change this to the champion you want
champion_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/champion/' champion '.json'];
champion = parse_json(urlread(champion_link));

%% Find Alphabetical Position of Champion
champion_names = fieldnames(champions.data); % creates a cell with all champion names
position = find(cellfun('length',regexp(champion_names, champion)) == 1); 