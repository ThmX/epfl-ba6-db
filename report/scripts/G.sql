-- For each Olympic Games print the name of the country with the most participants.

SELECT G.year, C.name
FROM Games G, Countries C
WHERE C.id = (
	SELECT RE.country_id
	FROM Representant_participates_Event RE
	WHERE RE.games_id = G.id
	GROUP BY RE.country_id
	ORDER BY COUNT(RE.country_id) DESC LIMIT 1)
GROUP BY G.id;