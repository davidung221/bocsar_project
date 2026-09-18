# Joining Suburb Crime Data to Census Data

This document explains how the BOCSAR suburb-level crime dataset (`suburbs`) was linked to
ABS census data (`census`), using `sal_code` (Statistical Area Level code) as the
join key. This link is what enables incidents-per-capita and socioeconomic
correlation analysis elsewhere in this project.

## Why a direct name-based join wasn't used

`suburbs.suburb` and `census.sal_name` are both text fields, and text matching
between independently-produced datasets is fragile. It breaks on casing,
whitespace, formatting differences, and it's expensive and inefficient on large
datasets (like the suburbs table with 70M+ rows). Rather than joining on suburb 
name in every query, this project resolves the match once and stores a stable 
`sal_code` on each `suburbs` row.

## 1. Initial name comparison

Suburb names were compared between the two datasets using an anti-join in both
directions, to find names present in one dataset but not the other:

```sql
-- Suburbs in crime data with no match in census
SELECT DISTINCT s.suburb
FROM suburbs s
LEFT JOIN census c
    ON TRIM(UPPER(s.suburb)) = TRIM(UPPER(c.sal_name))
WHERE c.sal_name IS NULL;
```

**Result:** many suburbs failed to match. Investigation showed the census file's
`sal_name` uses ABS SAL naming conventions (e.g., `"Abbotsford (NSW)"`, 
`"Alison (Central Coast - NSW)"`) that the BOCSAR suburb names don't include.

## 2. Normalising the bracketed text

Two distinct bracket patterns needed to be handled:

1. A bare state qualifier with no region name — `" (NSW)"` — removed entirely
   (`"Abbotsford (NSW)"` → `"Abbotsford"`)
2. A region qualifier with a trailing state name — `" - NSW)"` — collapsed to
   just the region (`"Alison (Central Coast - NSW)"` → `"Alison (Central Coast)"`)

```sql
TRIM(UPPER(
    REGEXP_REPLACE(
        REGEXP_REPLACE(sal_name, '\s*-\s*NSW\)$', ')'),
        '\s*\(NSW\)$', ''
    )
))
```

Re-running the anti-join with this normalisation applied returned zero
unmatched rows on the BOCSAR side, confirming every suburb in `suburbs` now
had a corresponding census entry. The reverse check (census suburbs with no
crime-data match) returned several hundred rows, which was expected. The 
census file covers more NSW localities that don't appear in the incident dataset.

## 3. Handling duplicate suburb names

A small number of suburb names exist more than once in NSW under different
regions (e.g. `"Alison (Central Coast)"` vs. `"Alison (Dungog)"`). Both datasets
disambiguate these the same way, by region in brackets, so the normalisation in
Step 2 preserved the region qualifier and these cases matched correctly without
manual intervention. This was manually spot-checked to confirm no ambiguity was
introduced.

## 4. Building the census lookup and populating `sal_code`

Given the scale involved — `suburbs` contains 72.3 million rows, while `census`
contains 4,542; computing the regex-based name transformation inline for every
row comparison was not viable. An initial attempt did not complete after 15+
minutes. Instead, the cleaned census names were pre-computed once into a small,
indexed lookup table:

```sql
CREATE TABLE census_name_lookup AS
SELECT
    sal_code,
    TRIM(UPPER(
        REGEXP_REPLACE(
            REGEXP_REPLACE(sal_name, '\s*-\s*NSW\)$', ')'),
            '\s*\(NSW\)$', ''
        )
    )) AS clean_name
FROM census;

CREATE INDEX idx_census_lookup_clean_name ON census_name_lookup (clean_name);
```

`suburbs.sal_code` was then populated by joining against this small, pre-cleaned
table rather than transforming `census.sal_name` on the fly for every row:

```sql
ALTER TABLE suburbs ADD COLUMN sal_code TEXT;

UPDATE suburbs s
SET sal_code = cnl.sal_code
FROM census_name_lookup cnl
WHERE TRIM(UPPER(s.suburb)) = cnl.clean_name;
```

This completed successfully across all 72.3 million rows.

## 5. Verification

```sql
SELECT COUNT(*) FROM suburbs WHERE sal_code IS NULL;
```

Result: `0` — every row in `suburbs` was successfully matched to a `census.sal_code`.

## 6. Cleanup

Once verified, the temporary lookup table was no longer needed:

```sql
DROP TABLE census_name_lookup;
```

## Summary

| Decision | Reasoning |
|---|---|
| Resolve suburb-to-census matching once, store `sal_code` | Avoids repeating fragile text-matching logic in every future query; matches the `offence_id` pattern used elsewhere in the schema |
| Normalise bracketed region/state qualifiers before matching | Census `sal_name` includes text not present in the crime data's suburb names |
| Preserve region qualifiers for duplicate suburb names | Both datasets disambiguate consistently by region, so this safely distinguished genuinely different places sharing a name |
| Use a pre-computed, indexed lookup table instead of an inline transformation join | At 72.3M rows, recomputing the regex transformation per row pair was not feasible; pre-computing against the smaller `census_name_lookup` table made the join tractable |

*Note: this document covers the process of linking `suburbs` to `census` via*
*`sal_code`. A separate normalisation of the `suburbs` table itself (converting*
*`offence_category`/`subcategory` text columns into a proper `offence_id`*
*foreign key) is covered in `challenges_and_fixes.md`.*
