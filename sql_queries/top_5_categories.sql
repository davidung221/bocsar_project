--top 5 subcategories
select 
	offence_category, 
	subcategory, 
	sum(incident_count) as total_incidents
from incidents i
join offence_type ot
on i.offence_id = ot.offence_id
where subcategory is not null
group by offence_category, subcategory
order by total_incidents desc
limit 5;

-- top 5 categories
SELECT 
    offence_category, 
    SUM(incident_count) AS total_incidents
FROM incidents i
JOIN offence_type ot 
  ON i.offence_id = ot.offence_id
GROUP BY offence_category
ORDER BY total_incidents DESC
LIMIT 5;
