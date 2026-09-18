INSERT INTO offence_type (offence_category, subcategory)
SELECT DISTINCT offence_category, subcategory
FROM staging_table;

INSERT INTO incidents (offence_id, month, incident_count)
SELECT
   o.offence_id,
   s.month,
   s.incident_count
FROM staging_table s
JOIN offence_type o
  ON s.offence_category = o.offence_category
  AND s.subcategory IS NOT DISTINCT FROM o.subcategory;

INSERT INTO census (
    sal_code, sal_name, total_population, completed_year12,
    total_labour_force, total_unemployed, median_weekly_household_income,
    served_in_adf, total_volunteers
)
SELECT
    sal_code, sal_name, total_population, completed_year12,
    total_labour_force, total_unemployed, median_weekly_household_income,
    served_in_adf, total_volunteers
FROM staging_census
WHERE sal_code IS NOT NULL;

INSERT INTO suburbs (offence_id, suburb, sal_code, month, incident_count)
SELECT
    o.offence_id,
    s.suburb,
    s.sal_code,
    s.month,
    s.incident_count
FROM staging_suburbs s
JOIN offence_type o
    ON s.offence_category = o.offence_category
    AND NULLIF(s.subcategory, s.offence_category) IS NOT DISTINCT FROM o.subcategory;
