CREATE TABLE offence_type (
   offence_id        SERIAL PRIMARY KEY,
   offence_category  VARCHAR(100) NOT NULL,
   subcategory       VARCHAR(150),
   UNIQUE (offence_category, subcategory)
);

CREATE TABLE incidents (
   incident_id     BIGSERIAL PRIMARY KEY,
   offence_id      INT NOT NULL REFERENCES offence_type(offence_id),
   month           DATE NOT NULL,
   incident_count  INT NOT NULL CHECK (incident_count >= 0)
);

CREATE TABLE census (
  sal_code                           TEXT PRIMARY KEY,
  sal_name                           TEXT NOT NULL,
  total_population                   INT CHECK (total_population >= 0),
  completed_year12                   INT CHECK (completed_year12 >= 0),
  total_labour_force                 INT CHECK (total_labour_force >= 0),
  total_unemployed                   INT CHECK (total_unemployed >= 0),
  median_weekly_household_income     INT CHECK (median_weekly_household_income >= 0),
  served_in_adf                      INT CHECK (served_in_adf >= 0),
  total_volunteers                   INT CHECK (total_volunteers >= 0)
);

CREATE TABLE suburbs (
  incident_id     BIGSERIAL PRIMARY KEY,
  offence_id      INT NOT NULL REFERENCES offence_type(offence_id),
  suburb          TEXT NOT NULL,
  sal_code        TEXT REFERENCES census(sal_code),
  month           DATE NOT NULL,
  incident_count  INT NOT NULL CHECK (incident_count >= 0)
);

----------------------
--- staging tables ---
----------------------

CREATE TABLE staging_table (
	state				   TEXT,
	offence_category	TEXT,
	subcategory			TEXT,
	"2025_population"	INT,
	"2026_population"	INT,
	month				   DATE,
	incident_count		INT
);
COPY staging_table (state, offence_category, subcategory,
"2025_population", "2026_population", month, incident_count)
FROM '/Users/davidung/Downloads/incidents_by_nsw_long.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE staging_suburbs (
   suburb            TEXT,
   offence_category  TEXT,
   subcategory       TEXT,
   month             DATE,
   incident_count    INT
);
COPY staging_suburbs (suburb, offence_category, subcategory, month, incident_count)
FROM '/Users/davidung/Downloads/incidents_by_suburb_long.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE staging_census (
    sal_code                          TEXT,
    sal_name                          TEXT,
    total_population                  INT,
    completed_year12                  INT,
    total_labour_force                INT,
    total_unemployed                  INT,
    median_weekly_household_income    INT,
    served_in_adf                     INT,
    total_volunteers                  INT
);
COPY staging_census (
    sal_code, sal_name, total_population, completed_year12,
    total_labour_force, total_unemployed, median_weekly_household_income,
    served_in_adf, total_volunteers
)
FROM '/Users/davidung/Downloads/Census_data.csv'
DELIMITER ','
CSV HEADER;


