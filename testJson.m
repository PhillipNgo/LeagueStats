clear, clc

version_link = 'https://global.api.pvp.net/api/lol/static-data/na/v1.2/versions?api_key=f1153217-7b9e-4adc-9036-596a248cb50b';
version = parse_json(urlread(version_link));
version = version{1};

all_champions_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/champion.json'];
aatrox_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/champion/Aatrox.json'];
items_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/item.json'];


champions = parse_json(urlread(all_champions_link));
aatrox = parse_json(urlread(aatrox_link));
items = parse_json(urlread(items_link));

link = 'http://ddragon.leagueoflegends.com/cdn/5.2.1/data/en_US/champion/';
json = '.json';
championnames = fieldnames(champions.data);

find(cellfun('length',regexp(championnames,'Zilean')) == 1)% finds the position # of champion