# Findings

This document summarises the key results from the analysis, organised by theme.
See the corresponding `.sql` files for the queries behind each finding.

---

## NSW-wide trends (1995-2025)

**Highest and lowest incident years:** The lowest year was 1995 with 528,888 incidents. The highest year was 2001 with 795,851 incidents.
In 2001, NSW averaged approximately 2,180 recorded incidents per day.

**Long-term trend:** total recorded incidents rose steadily from 1995, peaking
in 2001, and have declined fairly steadily since then.

**COVID-19 (2020):** 2020 saw the largest single year-over-year drop in the
dataset, consistent with the impact of lockdown restrictions on opportunities
for many offence types.

*(2026 is excluded from all year-based comparisons, as the dataset only covers
the year partially — January to March at the time of analysis.)*

---

## Has the composition of crime changed over time?

| Rank | 1995-1997 | 2023-2025 |
|---|---|---|
| 1 | Malicious damage to property | Transport regulatory offences |
| 2 | Theft (breaking and entering) | Breaching bail conditions |
| 3 | Theft (stealing from motor vehicles) | Intimidation, stalking, harassment |
| 4 | Theft (stealing from stores) | Malicious damage to property |
| 5 | Fraud | Fraud |
| ... | Assault | Domestic violence |

The composition has shifted notably. Property-focused offences (theft,
malicious damage) dominated the mid-1990s, while regulatory and
justice-procedure offences (transport offences, bail breaches) now lead.
Fraud, domestic violence, and reckless driving all show a markedly higher
ranking in the current period than 30 years ago, while several theft
subcategories have dropped out of the top ranks entirely.

---

## Suburb-level rankings

**Highest incident volume, last 5 years (2020-2025):**

| Rank | Suburb | Total incidents |
|---|---|---|
| 1 | Liverpool | 73,045 |
| 2 | Blacktown | 68,829 |
| 3 | Mount Druitt | 56,416 |
| 4 | Dubbo | 46,977 |
| 5 | Campbelltown | 45,015 |
| 6 | Haymarket | 42,582 |
| 7 | Bankstown | 34,315 |
| 8 | Coffs Harbour | 31,034 |
| 9 | Orange | 29,273 |
| 10 | Gosford | 24,673 |

**Highest incident volume, all-time (1995-2025):**

| Rank | Suburb | Total incidents |
|---|---|---|
| 1 | Blacktown | 294,435 |
| 2 | Liverpool | 268,719 |
| 3 | Dubbo | 205,804 |
| 4 | Haymarket | 196,922 |
| 5 | Campbelltown | 196,414 |
| 6 | Bankstown | 172,815 |
| 7 | Mount Druitt | 169,934 |
| 8 | Orange | 155,354 |
| 9 | Coffs Harbour | 139,322 |
| 10 | Cabramatta | 114,439 |

**Specific offence types:** targeted queries were run for abduction/kidnapping
and murder specifically over the last 5 years (2020-2025), to look at serious
offence types separately from the aggregate volume rankings. 

**Top 5 suburbs — abduction and kidnapping (2020-2025):**

| Rank | Suburb | Total incidents |
|---|---|---|
| 1 | Dubbo | 24 |
| 2 | Coffs Harbour | 18 |
| 3 | Greenacre | 17 |
| 4 | Bankstown | 17 |
| 5 | Auburn | 16 |

**Top 5 suburbs — murder (2020-2025):**

| Rank | Suburb | Total incidents |
|---|---|---|
| 1 | Bondi Beach | 15 |
| 2 | Coffs Harbour | 7 |
| 3 | Bondi Junction | 7 |
| 4 | Liverpool | 5 |
| 5 | Belmore | 4 |

*Note: at these low volumes, small differences in incident count can shift rankings meaningfully. 
Bondi Beach's 1st place ranking for murder is solely from the 14 December 2025 terrorist attack.*

---

## Incidents per capita

Suburb-level crime rates were calculated as incidents per 100,000 population,
using 2021 census population figures, restricted to a single year (2021) to
keep the rate and its denominator aligned in time.

**Top 10 suburbs — highest incidents per 100k (2021, population > 5,000):**

| Rank | Suburb | Population | Total incidents | Incidents per 100k |
|---|---|---|---|---|
| 1 | Haymarket | 8,305 | 9,703 | 116,833 |
| 2 | Mount Druitt | 16,986 | 9,782 | 57,588 |
| 3 | Campbelltown | 16,577 | 8,122 | 48,995 |
| 4 | Liverpool | 31,078 | 11,335 | 36,472 |
| 5 | Moree | 8,962 | 3,224 | 35,974 |
| 6 | Blacktown | 50,961 | 15,150 | 29,728 |
| 7 | Nowra | 9,956 | 2,617 | 26,285 |
| 8 | Bathurst | 7,001 | 1,832 | 26,167 |
| 9 | Byron Bay | 6,330 | 1,590 | 25,118 |
| 10 | Newtown | 14,690 | 3,497 | 23,805 |

**Top 10 suburbs — lowest incidents per 100k (2021, population > 5,000):**

| Rank | Suburb | Population | Total incidents | Incidents per 100k |
|---|---|---|---|---|
| 1 | Cherrybrook | 19,082 | 241 | 1,262 |
| 2 | Hornsby Heights | 6,354 | 89 | 1,400 |
| 3 | Fairlight | 6,141 | 91 | 1,481 |
| 4 | Kiama Downs | 5,087 | 76 | 1,494 |
| 5 | Glenhaven | 6,619 | 105 | 1,586 |
| 6 | Eleebana | 6,460 | 103 | 1,594 |
| 7 | Caringbah South | 13,168 | 220 | 1,670 |
| 8 | Kenthurst | 5,313 | 89 | 1,675 |
| 9 | Googong | 7,444 | 125 | 1,679 |
| 10 | Beaumont Hills | 9,041 | 156 | 1,725 |

*Note: The gap between the highest and lowest per-capita suburbs is substantial even 
after applying the population floor — Haymarket's rate is roughly 90x that of Cherrybrook. 
The suburbs at the low end (Cherrybrook, Hornsby Heights, Glenhaven, Kenthurst, Beaumont Hills) 
are predominantly outer-suburban, low-density residential areas in Sydney's north-west and upper 
north shore, while the highest-rate suburbs are a mix of high-density inner-city/commercial precincts 
(Haymarket, Newtown) and outer-metro centres with known socioeconomic disadvantage (Mount Druitt, 
Campbelltown, Liverpool) — consistent with the unemployment and income correlations found elsewhere in this analysis.*

**A population floor of 5,000 was applied before ranking suburbs.** Per-capita
rates calculated on very small populations are highly unstable — a single
incident in a suburb of 20 people can swing the rate by thousands per 100,000,
distorting the ranking without reflecting any real difference in crime. A floor
of 5,000 limits this effect to roughly 20 incidents per 100,000 per
single-incident swing, striking a balance between statistical reliability and
retaining most of the state's suburbs in the analysis (a stricter floor, such
as 10,000, would have excluded much of regional and rural NSW).

Without a population floor, the highest-rate suburbs were dominated by
non-residential or near-uninhabited localities (an aerodrome, industrial and
park land) with populations in the single digits — a statistical artefact of
dividing by an almost-zero denominator, not a meaningful finding.

**With the floor applied**, the highest per-capita rates belonged to suburbs
including Maitland, Haymarket, Hexham, Gosford, and Kempsey. Haymarket in
particular — Sydney's Chinatown/entertainment and retail precinct — likely
reflects high foot traffic and commercial activity relative to its resident
population, rather than elevated risk to residents specifically.

**Assault and homicide specifically:** [FILL IN — top suburbs for this
category subset, if notable]

---

## Socioeconomic correlations

Using 2021 census data joined via `sal_code`, correlations were calculated
between incidents-per-capita and five socioeconomic indicators (suburbs with
population > 5,000):

| Variable | Correlation (r) | Interpretation |
|---|---|---|
| Unemployment rate | +0.379 | Weakest-to-moderate positive relationship — the strongest of the five |
| Median household income | -0.329 | Weak-to-moderate negative relationship |
| Volunteer participation rate | -0.120 | Weak negative relationship |
| Year 12 completion rate | -0.054 | Negligible |
| ADF service history rate | -0.036 | Negligible (included as a sanity check — no theoretical reason to expect a relationship, which this confirms) |

**Interpretation:** unemployment rate showed the strongest relationship with
incidents-per-capita, followed by income. Because income and unemployment are
likely correlated with each other, these results should not be read as two
independent confirmations of a socioeconomic-disadvantage effect — a multiple
regression would be needed to isolate each variable's independent
contribution, which is beyond the scope of this SQL-based analysis. Education
and ADF service history showed no meaningful relationship.

---

## Unemployment quartile comparison

Suburbs were split into four equal-sized groups by unemployment rate, to
present the unemployment relationship in a more visual, interpretable form
than the correlation coefficient alone:

| Quartile | Avg. unemployment | Avg. incidents per 100k |
|---|---|---|
| 1 (lowest) | 3.15% | 3,951.77 |
| 2 | 3.95% | 6,283.49 |
| 3 | 5.05% | 7,278.30 |
| 4 (highest) | 7.78% | 12,213.26 |

The relationship is monotonic — each quartile step up in unemployment
corresponds to a step up in crime rate, with no reversals. The highest-
unemployment quartile shows a per-capita rate roughly **three times** that of
the lowest-unemployment quartile — a clearer and more visually compelling
presentation of the same relationship captured in the correlation coefficient
above.

---

## Limitations

- Per-capita and correlation analysis uses a single census year (2021) and is
  not a trend over time — population data for other years was not available.
- Correlation does not imply causation. Several plausible confounders
  (population density, foot traffic, offence-type mix, reporting differences)
  were not controlled for.
- Year 12 completion rate is calculated against total population rather than
  working-age population, since age-bracketed population data wasn't
  available — this likely understates the true completion rate in suburbs
  with younger populations.
