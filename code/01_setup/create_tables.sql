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
  sal_code                        TEXT PRIMARY KEY,
  sal_name                        TEXT NOT NULL,
  total_population                INT CHECK (total_population >= 0),
  completed_year12                INT CHECK (completed_year12 >= 0),
  total_labour_force              INT CHECK (total_labour_force >= 0),
  total_unemployed                INT CHECK (total_unemployed >= 0),
  median_weekly_household_income  INT CHECK (median_weekly_household_income >= 0),
  served_in_adf                    INT CHECK (served_in_adf >= 0),
  total_volunteers                 INT CHECK (total_volunteers >= 0)
);

CREATE TABLE suburbs (
  incident_id     BIGSERIAL PRIMARY KEY,
  offence_id      INT NOT NULL REFERENCES offence_type(offence_id),
  suburb          TEXT NOT NULL,
  sal_code        TEXT REFERENCES census(sal_code),
  month           DATE NOT NULL,
  incident_count  INT NOT NULL CHECK (incident_count >= 0)
);
