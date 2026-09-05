/* 
==============================================================================================
This query shows the year in which the lowest and highest number of incidents occurred.
==============================================================================================
1. Used a CTE to return the total incidents per year, filtering out 2026 as it only
contains data for 3 months.
2. Created a column 'label' for a wide table containing the lowest and highest counts.
3. Used UNION ALL to combine two SELECT statements. ORDER BY ASC/DESC LIMIT 1 returns only
the row containing the lowest/highest value for total incidents.

E.g.,
LABEL | YEAR | TOTAL_INCIDENTS
lowest | 1995 | 528,888
==============================================================================================
*/

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
