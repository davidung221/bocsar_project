/* 
==============================================================================================
This query shows the year-over-year % change in incidents per year, tracking change over time.
==============================================================================================
1. First CTE 'yearly_totals' gets the total incidents per year.
2. Second CTE 'comparison' uses LAG() to get the previous year's total.
3. Final SELECT statement calculates percentage change rounded to 1 decimal point.

E.g.,
YEAR | TOTAL_INCIDENTS | PREVIOUS_YEAR_TOTAL | PCT_CHANGE
1996 | 601692 | 528888 | 13.8
==============================================================================================
*/

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
