-- Compute medal table for the specific Olympic Games supplied by the user. Medal table should contain country’s IOC code followed by the number of gold, silver, bronze and total medals. It should first be sorted by the number of gold, then silvers and finally bronzes.

SET @selected_game_id = '47';

SELECT C.ioc_code, COUNT(case P.ranking when 1 then 1 else null end) as nb_gold, COUNT(case P.ranking when 2 then 1 else null end) as nb_silver, COUNT(case P.ranking when 3 then 1 else null end) as nb_bronze, COUNT(case when P.ranking > 0 then 1 else null end) as total_medals
FROM Representant_participates_Event P
INNER JOIN Countries C ON P.country_id = C.id
WHERE P.games_id = @selected_game_id
GROUP BY C.ioc_code
ORDER BY nb_gold, nb_silver, nb_bronze




















 