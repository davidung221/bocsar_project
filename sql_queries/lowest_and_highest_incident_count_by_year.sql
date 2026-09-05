WITH cte AS (
   SELECT
       EXTRACT(YEAR FROM month) AS year,
       SUM(incident_count) AS total_incidents
   FROM incidents
   WHERE EXTRACT(YEAR FROM month) < 2026
   GROUP BY year
)
(SELECT 'lowest' AS label, year, total_incidents FROM cte ORDER BY total_incidents ASC LIMIT 1)
UNION ALL
(SELECT 'highest' AS label, year, total_incidents FROM cte ORDER BY total_incidents DESC LIMIT 1);
