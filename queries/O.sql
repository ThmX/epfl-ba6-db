-- For all disciplines, compute the country which waited the most between two successive medals.

-- The View is the time that a country has waited  between 2 medals for each discipline. The following query is only giving the country according to the maximum time and the discipline.

CREATE VIEW DelayByCountryByDiscipline AS (
  SELECT p1.discipline_id as discipline_id, g1.year-g2.year as time_waited, p1.country_id as country_id
  FROM representant_participates_event p1, representant_participates_event p2, games g1, games g2
  WHERE p1.country_id = p2.country_id AND p1.games_id = g1.id AND p2.games_id = g2.id AND g1.year > g2.year
  AND p1.ranking != 0 AND p2.ranking != 0 AND p1.discipline_id = p2.discipline_id
  GROUP BY p1.discipline_id
);

SELECT d.name as discipline, c.name as country, join2.max_delay as number_of_years_waited
FROM DelayByCountryByDiscipline join1, Disciplines d, Countries c, (
  SELECT MAX(time_waited) as max_delay, discipline_id
  FROM DelayByCountryByDiscipline
  GROUP BY discipline_id
) join2
WHERE join1.discipline_id = join2.discipline_id AND join1.time_waited = join2.max_delay AND join1.discipline_id = d.id
AND join1.country_id = c.id