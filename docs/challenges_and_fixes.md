# Challenges & Fixes

This document records the problems encountered while building this project,
how they were diagnosed, and how they were resolved. 

*(For the suburb-to-census `sal_code` linking process specifically, including its*
*own performance issue, see `merge_methodology.md`.)*

---

## 1. NULL subcategory values in `offence_type`

**Problem:** populating `offence_type` from the raw staging data failed with:
```
ERROR: null value in column "subcategory" of relation "offence_type" violates not-null constraint
```

**Diagnosis:** some offence categories (e.g. "Betting and gaming offences") are 
reported at the category level only, with no subcategory. The schema had 
`subcategory` set to `NOT NULL`, which didn't account for this.

**Fix:** the constraint was dropped, since a missing subcategory is a genuine
characteristic of the data, not a data quality error.
```sql
ALTER TABLE offence_type ALTER COLUMN subcategory DROP NOT NULL;
```

---

## 2. Rows silently dropped during the `incidents` load

**Problem:** after fixing the `NOT NULL` issue above, the row count in `incidents`
didn't match the row count in the staging table it was built from — some rows had
gone missing with no error raised.

**Diagnosis:** the join condition used standard equality:
```sql
ON s.subcategory = o.subcategory
```
In SQL, `NULL = NULL` doesn't evaluate to true — it evaluates to unknown, which is
treated as "no match" in a join. Every row where both sides had a NULL
subcategory was silently excluded from the result, rather than causing an error.

**Fix:** replaced `=` with `IS NOT DISTINCT FROM`, which treats two NULLs as
equal:
```sql
ON s.subcategory IS NOT DISTINCT FROM o.subcategory
```
After clearing the partially-loaded `incidents` table (`TRUNCATE TABLE incidents;`)
and re-running with this fix, row counts matched exactly.

---

## 3. Junk rows in the census staging data

**Problem:** checking `staging_census` for duplicate `sal_code` values returned a
group of 2 rows with `sal_code IS NULL`.

**Diagnosis:** inspecting these rows directly showed every column was `NULL` —
not real data, most likely blank trailing lines picked up during the CSV export.

**Fix:** excluded explicitly when building the final `census` table, since
`sal_code` is a primary key and cannot be NULL:
```sql
INSERT INTO census (...)
SELECT ...
FROM staging_census
WHERE sal_code IS NOT NULL;
```

---

## 4. The `suburbs` table was never normalised like `incidents`

**Problem:** `suburbs` still stored `offence_category` and `subcategory` as raw text on every
row, unlike `incidents`, which referenced `offence_type` via `offence_id`. The 
staging table was being treated like a proper normalised table.

**Fix:** the table was rebuilt to match the established pattern:
```sql
ALTER TABLE suburbs RENAME TO staging_suburbs;

CREATE TABLE suburbs (
    incident_id     BIGSERIAL PRIMARY KEY,
    offence_id      INT NOT NULL REFERENCES offence_type(offence_id),
    suburb          TEXT NOT NULL,
    sal_code        TEXT REFERENCES census(sal_code),
    month           DATE NOT NULL,
    incident_count  INT NOT NULL CHECK (incident_count >= 0)
);
```

**A second issue surfaced while re-populating it:** an anti-join check against
`offence_type` returned 13 unmatched offence category/subcategory combinations —
all of them cases like `"Arson" / "Arson"`, where the subcategory simply repeated
the category name, rather than being left NULL as in the original state-level
dataset. The two source files represented "no subcategory" differently.

**Fix:** normalised this pattern before matching, using `NULLIF` to treat a
self-referencing subcategory the same as a NULL one:
```sql
JOIN offence_type o
    ON s.offence_category = o.offence_category
    AND NULLIF(s.subcategory, s.offence_category) IS NOT DISTINCT FROM o.subcategory;
```

Instead of `"Arson" / "Arson"`, it was standardised to `"Arson" / Null`.

---

## 5. Division by zero in percentage-change calculations

**Problem:** calculating year-over-year percentage change at the suburb level
occasionally raised a division-by-zero error.

**Diagnosis:** some suburbs had zero recorded incidents in the earlier
comparison year, making that year's total (the denominator) zero.

**Fix:** wrapped the denominator in `NULLIF` to convert a zero into a NULL before
the division, so the result becomes NULL (rather than the query failing) for
suburbs where a percentage change genuinely can't be calculated:
```sql
ROUND(
    (total_incidents - previous_year_total) * 100.0 / NULLIF(previous_year_total, 0),
    2
) AS pct_change
```
The same technique was applied to the unemployment-rate calculation, to guard
against suburbs with a zero labour force denominator.

---

## 6. Misleading per-capita results for tiny or non-residential suburbs

**Problem:** an early incidents-per-100k ranking (no population floor) was
dominated by suburbs like Moore Park (population 18) and Bankstown Aerodrome
(population 5), with implausible rates in the hundreds of thousands or millions
per 100k.

**Diagnosis:** these are non-residential or near-uninhabited localities
(parkland, industrial zones, an aerodrome). A small number of incidents against
an almost-zero resident population inflates the rate to the point of being
meaningless — this is a general statistical issue with per-capita rates
calculated on small denominators, not a data error.

**Fix:** applied a population floor (suburbs with population > 5,000) in an
attempt to find a middle-ground between statistical reliability and retaining 
most of the state's suburbs in the analysis (a stricter floor, such as 10,000 
would have excluded most of regional and rural NSW).

---

## 7. Queries taking too long to load due to size

This was the most significant technical problem in the project — full detail is
in `merge_methodology.md`. To summarise, matching `suburbs` (72.3 million rows) to
`census` (4,542 rows) by suburb name required a regex-based text normalisation
on every comparison, which ran for over 15 minutes without completing. The fix was 
to pre-compute the normalised census names once into a small indexed lookup table, 
and join against that instead. This reduced the cost from recomputing the 
transformation per row-pair to computing it once per census row.

---

## 8. Deciphering and assembling the census source data

**Problem:** the ABS census data wasn't available as a
single, clean file. It was scattered across 50+ source tables, labelled
with ABS coding conventions (e.g. "G01") and had confusing column names,
making it unclear which files and columns corresponded to which variables.

**Fix:** cross-referenced the ABS metadata documentation for each source table to
identify the correct columns, then manually combined and
summed relevant columns (e.g., combining male-female columns into a single
total) in Excel to produce a unified `Census_data.csv` with clear, descriptive
column names.

---

## Summary

| Issue | Root cause | Fix |
|---|---|---|
| `NOT NULL` violation on `offence_type.subcategory` | Some offence categories have no subcategory breakdown | Dropped the constraint |
| Missing rows in `incidents` | `NULL = NULL` evaluates to unknown| `IS NOT DISTINCT FROM` |
| 2 junk rows in `staging_census` | Blank trailing lines from CSV export | Filtered with `WHERE sal_code IS NOT NULL` |
| `suburbs` inconsistent with rest of schema | Table was never normalised to use `offence_id` | Rebuilt table structure to match `incidents` |
| 13 offence types "unmatched" during rebuild | Suburb-level file used self-referencing subcategory instead of NULL | `NULLIF(subcategory, offence_category)` |
| Division-by-zero in rate calculations | Zero-value denominators (no prior incidents, no labour force) | `NULLIF(denominator, 0)` |
| Implausible per-capita rates | Small/non-residential suburbs with near-zero population | Population floor (>5,000), documented explicitly |
| 15+ minute unfinished query | Regex transformation recomputed per row-pair at 72.3M rows | Pre-computed, indexed lookup table |
| Census source data unclear and scattered | ABS files used coding conventions (e.g. "G01") to label tables spread across multiple files | Cross-referenced documentation and manually combined columns together into a single table `Census_data.csv` |
