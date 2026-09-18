----------------------------------------
--- ### INCIDENTS BY NSW QUERIES ### ---
----------------------------------------

-- lowest and highest incident count by year, excluding 2026
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


-- year-over-year percentage change of total incidents
WITH yearly_totals AS (
   SELECT
       EXTRACT(YEAR FROM month) AS year,
       SUM(incident_count) AS total_incidents
   FROM incidents
   WHERE EXTRACT(YEAR FROM month) < 2026
   GROUP BY year
),
comparison as (
SELECT
   year,
   total_incidents,
   LAG(total_incidents) OVER (ORDER BY year) AS previous_year_total
FROM yearly_totals
ORDER BY year)
select *,
ROUND(
		((total_incidents - previous_year_total)*100.0 / previous_year_total),1)
		AS pct_change
FROM comparison;


-- top 5 incident types in last 3 years (2023 - 2025)
select 
  offence_category, 
  subcategory, 
  sum(incident_count) as total_incidents
from incidents i
join offence_type ot on i.offence_id = ot.offence_id
where extract(year from month) between 2023 and 2025
group by offence_category, subcategory
order by total_incidents desc
limit 10;

-------------------------------------------
--- ### INCIDENTS BY SUBURB QUERIES ### ---
-------------------------------------------

-- top 5 by abduction and kidnapping in the last 5 years (2020 - 2025)
SELECT s.suburb,
   ot.offence_category,
   SUM(s.incident_count) AS total_incidents
FROM suburbs s
JOIN offence_type ot ON s.offence_id = ot.offence_id
WHERE ot.offence_category ILIKE 'abduction%'
   AND EXTRACT(YEAR FROM s.month) BETWEEN 2020 AND 2025
GROUP BY s.suburb, ot.offence_category
ORDER BY total_incidents DESC
LIMIT 5;


-- top 5 suburbs by murder in the last 5 years (2020 - 2025)
SELECT s.suburb,
   ot.subcategory,
   SUM(s.incident_count) AS total_incidents
FROM suburbs s
JOIN offence_type ot ON s.offence_id = ot.offence_id
WHERE ot.subcategory = 'Murder *'
   AND EXTRACT(YEAR FROM s.month) BETWEEN 2020 AND 2025
GROUP BY s.suburb, ot.subcategory
ORDER BY total_incidents DESC
LIMIT 5;


-- top 10 suburbs by number of incidents of all time
select suburb, 
  sum(incident_count) as total_incidents
from suburbs
group by suburb
order by total_incidents desc
limit 10;


--- top 10 suburbs by total incidents in last 5 years
select suburb, sum(incident_count) as total_incidents
from suburbs
where extract(year from month) between 2020 and 2025
group by suburb
order by total_incidents desc
limit 10;

---------------------------------------
--- ### CENSUS + SUBURB QUERIES ### ---
---------------------------------------

-- top 10 highest incidents per 100k by suburb, with a population floor of 5k
SELECT
   s.suburb,
   c.total_population,
   SUM(s.incident_count) AS total_incidents,
   SUM(s.incident_count) * 100000 / c.total_population AS incidents_per_100k
FROM suburbs s
JOIN census c ON s.sal_code = c.sal_code
WHERE c.total_population > 5000
and extract(year from month) = 2021
GROUP BY s.suburb, c.total_population
order by incidents_per_100k DESC
LIMIT 10;


-- highest number of incidents per 100k for assault and homicides
SELECT
   s.suburb,
   c.total_population,
   SUM(s.incident_count) AS total_incidents,
   SUM(s.incident_count) * 100000 / c.total_population AS incidents_per_100k
FROM suburbs s
JOIN census c ON s.sal_code = c.sal_code
JOIN offence_type ot ON s.offence_id = ot.offence_id
WHERE c.total_population > 5000
   AND EXTRACT(YEAR FROM s.month) = 2021
   AND ot.offence_category IN ('Assault', 'Homicide')
GROUP BY s.suburb, c.total_population
ORDER BY incidents_per_100k DESC
LIMIT 10;


-- creating CTE with all the rates calculated first
WITH suburb_profile AS (
   SELECT
       s.suburb,
       c.median_weekly_household_income,
       c.total_unemployed * 1.0 / NULLIF(c.total_labour_force, 0) AS unemployment_rate,
       c.completed_year12 * 1.0 / NULLIF(c.total_population, 0) AS year12_completion_rate,
       c.served_in_adf * 1.0 / NULLIF(c.total_population, 0) AS adf_rate,
       c.total_volunteers * 1.0 / NULLIF(c.total_population, 0) AS volunteer_rate,
       SUM(s.incident_count) * 100000.0 / c.total_population AS incidents_per_100k
   FROM suburbs s
   JOIN census c ON s.sal_code = c.sal_code
   WHERE c.total_population > 5000
       AND EXTRACT(YEAR FROM s.month) = 2021
   GROUP BY s.suburb, c.median_weekly_household_income, c.total_unemployed,
            c.total_labour_force, c.completed_year12, c.total_population,
            c.served_in_adf, c.total_volunteers
)
/*checking data quality for any impossible values
SELECT suburb, unemployment_rate, year12_completion_rate, adf_rate, volunteer_rate
FROM suburb_profile
WHERE unemployment_rate > 1
  OR year12_completion_rate > 1
  OR adf_rate > 1
  OR volunteer_rate > 1; */
SELECT
   ROUND(CORR(incidents_per_100k, median_weekly_household_income)::NUMERIC, 3) AS corr_income,
   ROUND(CORR(incidents_per_100k, unemployment_rate)::NUMERIC, 3) AS corr_unemployment,
   ROUND(CORR(incidents_per_100k, year12_completion_rate)::NUMERIC, 3) AS corr_education,
   ROUND(CORR(incidents_per_100k, adf_rate)::NUMERIC, 3) AS corr_adf,
   ROUND(CORR(incidents_per_100k, volunteer_rate)::NUMERIC, 3) AS corr_volunteer
FROM suburb_profile;


-- unemployment quartile
WITH CTE AS (
SELECT
	s.suburb,
	c.total_unemployed * 1.0 / NULLIF(c.total_labour_force, 0) AS unemployment_rate,
	SUM(s.incident_count) * 100000.0 / c.total_population AS incidents_per_100k,
	NTILE(4) OVER (ORDER BY (c.total_unemployed * 1.0 / NULLIF(c.total_labour_force, 0))) AS unemployment_quartile
FROM suburbs s
JOIN census c ON s.sal_code = c.sal_code
WHERE c.total_population > 5000
AND EXTRACT(YEAR FROM s.month) = 2021
GROUP BY s.suburb, c.total_unemployed, c.total_labour_force, c.total_population
)
SELECT
   unemployment_quartile,
   COUNT(*) AS num_suburbs,
   ROUND(AVG(unemployment_rate) * 100, 2) AS avg_unemployment_pct,
   ROUND(AVG(incidents_per_100k), 2) AS avg_incidents_per_100k
FROM cte
GROUP BY unemployment_quartile
ORDER BY unemployment_quartile;
