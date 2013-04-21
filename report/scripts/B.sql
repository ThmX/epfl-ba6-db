--Names of gold medalists in sports which appeared only once at the Olympics.

SELECT a.name as athlete, d.name as sport 
FROM athletes a, representant_participates_event p, disciplines d 
WHERE a.id = p.athlete_id AND p.ranking = 1 AND d.id = p.discipline_id AND d.sport IN (
	SELECT d.sport 
	FROM disciplines d, disciplines_event_games e
    	WHERE d.id = e.discipline_id 
   	 GROUP BY d.sport
    	HAVING COUNT(*) = 1);