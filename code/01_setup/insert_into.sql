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
