--YoY% change
WITH yearly_totals AS (
    SELECT
        EXTRACT(YEAR FROM month) AS year,
        SUM(incident_count) AS total_incidents
    FROM incidents
    WHERE EXTRACT(YEAR FROM month) < 2026
    GROUP BY year
),
comparison as (SELECT
    year,
    total_incidents,
    LAG(total_incidents) OVER (ORDER BY year) AS previous_year_total
FROM yearly_totals
ORDER BY year)
select *,
	ROUND(
		((total_incidents - previous_year_total)*100.0 / previous_year_total),1) 
		as pct_change
from comparison;
