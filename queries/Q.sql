-- For each Olympic Games, list the name of the country which scored the largest percentage of the medals.

-- We compute views to select the number of medals per country and per games and to select the number of medals per games. The third one is to give the percentage of medals by country and by games. The query is only using the last one in order to get the name of the country which corresponds to the maximum for each games.

-- number of medals per country per games   
CREATE VIEW NbMedalsByCountryByGames
AS (SELECT g.id as games_id, c.id as country_id, COUNT(DISTINCT d.id) as number_of_medals_per_country
    FROM Games g, representant_participates_event p, disciplines d, Countries c
    WHERE p.games_id = g.id AND p.discipline_id = d.id AND p.country_id = c.id AND p.ranking != 0
    GROUP BY g.id, c.id);
   
-- number of total medals in games
CREATE VIEW NbMedalsByGames
AS (SELECT g.id as games_id, COUNT(DISTINCT d.id) as number_of_medals_in_games
    FROM Games g, representant_participates_event p, disciplines d
    WHERE p.games_id = g.id AND p.discipline_id = d.id AND p.ranking != 0
    GROUP BY g.id);
    
-- Percentage by country by games
CREATE VIEW Percentage
AS (SELECT nmg.games_id as games_id, c.name as country, (100*nmpc.number_of_medals_per_country/nmg.number_of_medals_in_games) as percentage_of_medals
    FROM NbMedalsByCountryByGames nmpc, NbMedalsByGames nmg, Countries c
    WHERE nmg.games_id = nmpc.games_id AND nmpc.country_id = c.id
    );
    
SELECT join1.games_id, join1.country as country, join1.percentage_of_medals as percentage_of_medals
FROM MaxPercentageByGames join1, (
    SELECT games_id, MAX(percentage_of_medals) as max_percentage_of_medals
    FROM MaxPercentageByGames
    GROUP BY games_id
) join2
WHERE join1.games_id = join2.games_id AND join1.percentage_of_medals = join2.max_percentage_of_medals