/* The suburbs table was too large (70M+ rows), and there was a mismatch between the suburb names from the CENSUS and from BOCSAR.
sal_code was added to suburbs table for more efficient joins and regex was used to clean and match the suburb names.
The census_name_lookup table was created because a direct UPDATE was too inefficient. */
ALTER TABLE suburbs ADD COLUMN sal_code TEXT;

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

UPDATE suburbs s
SET sal_code = cnl.sal_code
FROM census_name_lookup cnl
WHERE TRIM(UPPER(s.suburb)) = cnl.clean_name;
