# Data

The raw SBA loan-level files are **not included** in this repository.

## Source

U.S. Small Business Administration (SBA), **7(a) & 504 FOIA** open-data files:

- 7(a) FY2010-FY2019
- 7(a) FY2020-Present
- 7(a)/504 FOIA data dictionary

The files used for this project were from the **June 30, 2026** extract.

Official source:
https://data.sba.gov/dataset/7a-504-foia

## Study period

The two 7(a) files are combined and the analysis is restricted to complete fiscal years **FY2010-FY2025**. FY2026 is excluded because the extract used for the study contains only a partial fiscal year through June 30, 2026.

## Primary business-age definition

**Startup**

`Startup, Loan Funds will Open Business`

**Established business**

- `Existing or more than 2 years old`
- `Existing, 5 or more years`
- `Less than 3 years old but at least 2`
- `Less than 4 years old but at least 3`
- `Less than 5 years old but at least 4`

Change-of-ownership observations, unanswered or missing business-age records, and other new-business classifications whose definitions differ across source periods are excluded from the primary startup-versus-established comparison.

The resulting primary analytical sample contains **681,992 approved loans**: **138,054 startups** and **543,938 established businesses**.

## Reproduction

Download the source files from the SBA open-data page and import them into R before running the analysis script. The public code intentionally does not redistribute the raw administrative files.

## Important interpretation

The source data used in this study contain approved SBA 7(a) loans. The analysis therefore does not measure application approval probability or general access to credit.
