-- List names of all events and Olympic Games for which the individual or team has defended a title from the previous games.
-- Forum : check only if country defened title (not athlete)

SELECT d1.name as discipline, c1.name as winner_country, g2.host_city as first_games, g2.year, g1.host_city as second_games, g1.year
FROM representant_participates_event p1, disciplines d1, countries c1, games g1,
representant_participates_event p2, disciplines d2, countries c2, games g2
WHERE p1.discipline_id = d1.id AND p1.country_id = c1.id AND p1.games_id = g1.id AND p1.ranking = 1 AND
p2.discipline_id = d2.id AND p2.country_id = c2.id AND p2.games_id = g2.id AND p2.ranking = 1 AND d1.id = d2.id AND g1.id != g2.id
AND NOT EXISTS (SELECT * FROM games g WHERE g.year < g1.year AND g.year > g2.year)
GROUP BY d1.id