-- List all countries which didn’t ever win a medal.

SELECT C.name
FROM Countries C
WHERE (
	SELECT SUM(RE.ranking)
	FROM Representant_participates_Event RE
	WHERE RE.country_id = C.id
) IS NULL OR (
	SELECT SUM(RE.ranking)
	FROM Representant_participates_Event RE
	WHERE RE.country_id = C.id
) = 0;