clear, clc

all_champions_link = 'http://ddragon.leagueoflegends.com/cdn/5.2.1/data/en_US/champion.json';
aatrox_link = 'http://ddragon.leagueoflegends.com/cdn/5.2.1/data/en_US/champion/Aatrox.json';
items_link = 'http://ddragon.leagueoflegends.com/cdn/5.2.1/data/en_US/item.json';

champions = parse_json(urlread(all_champions_link));
aatrox = parse_json(urlread(aatrox_link));
items = parse_json(urlread(items_link));
