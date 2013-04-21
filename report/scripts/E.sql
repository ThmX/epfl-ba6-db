-- List all cities which hosted the Olympics more than once.

SELECT DISTINCT G.host_city
FROM Games G
WHERE EXISTS (
	SELECT *
	FROM Games G2
	WHERE G.id != G2.id AND G.host_city = G2.host_city
);