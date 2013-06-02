-- List top 10 countries according to their success on the events which appear at the Olympics for the first
-- time. Present the list in the form of the medal table (as described for query I).

SELECT e1.discipline_id, e1.games_id
FROM disciplines_event_games e1, games g1, (
    SELECT e2.discipline_id as discipline_id, MIN(g2.year) as min_year
    FROM disciplines_event_games e2, games g2
    WHERE e2.games_id = g2.id
    GROUP BY e2.discipline_id
  ) min_by_dis
WHERE e1.games_id = g1.id AND min_by_dis.discipline_id = e1.discipline_id AND g1.year = min_by_dis.min_year