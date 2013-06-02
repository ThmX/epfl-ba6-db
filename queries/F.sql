-- List names of all athletes who competed for more than one country.

SELECT A.name
FROM Athletes A
WHERE (
	SELECT COUNT(AC.country_id)
	FROM Athletes_represent_Countries AC
	WHERE A.id = AC.athlete_id
) > 1;