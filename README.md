# Financing New Ventures: Startup Status and Loan Terms in the U.S. SBA 7(a) Program

This repository contains the reproducible research materials for a working paper examining how loan amounts and initial interest rates differ between startup and established-business borrowers within the U.S. Small Business Administration (SBA) 7(a) program.

## Research question

**How do loan amounts and initial interest rates differ between startup and established-business borrowers within the SBA 7(a) program, and how sensitive are these differences to observable industry, geographic, program, and loan characteristics?**

## Study period and analytical sample

The analysis uses SBA 7(a) FOIA loan-level records covering complete fiscal years **FY2010-FY2025**. FY2026 is excluded because the source extract used for the project was available only through June 30, 2026.

The primary analytical sample contains **681,992 approved SBA 7(a) loans**:

- **138,054 startup loans**
- **543,938 established-business loans**

A startup is defined using the SBA `BusinessAge` category **"Startup, Loan Funds will Open Business."** The established-business comparison group uses clearly established business-age categories available in the source files.

## Main findings

Descriptively, startup loans have a median gross approval amount of **$200,000**, compared with **$150,000** for established-business loans.

In the baseline loan-amount model, which includes fiscal-year, project-jurisdiction, and two-digit NAICS industry fixed effects, startup status is associated with approximately **18.04% higher** gross approval amounts.

In the extended loan-amount specification, which additionally accounts for processing method, business type, and collateral status, the association reverses to approximately **13.74% lower** gross approval amounts.

For initial interest rates, startup status is associated with rates approximately **0.205 percentage points lower** in the baseline specification and **0.105 percentage points lower** in the extended specification.

The sign reversal in the loan-amount models is an important part of the result: the observed startup-loan-size relationship is sensitive to program, borrower, and loan composition.

## Interpretation

These estimates describe **conditional associations among approved SBA 7(a) loans**. They do **not** identify a causal effect of startup status and do **not** estimate whether startups are more or less likely to obtain credit.

## Repository structure

```
.
├── README.md
├── code/
│   └── sba_7a_analysis.R
├── data/
│   └── README.md
├── figures/
├── tables/
└── paper/
```

The raw SBA datasets are not stored in this repository. See `data/README.md` for the source files and reproduction notes.

## Methods

The empirical workflow includes:

- construction of a consistent startup/established-business classification;
- descriptive statistics and loan-amount distributions;
- annual startup-share calculations;
- two-digit NAICS industry comparisons;
- OLS models for log gross approval amount;
- OLS models for initial interest rates;
- fiscal-year, project-jurisdiction, and industry fixed effects;
- lender-clustered standard errors;
- project-jurisdiction clustering as a robustness check; and
- a stricter business-age classification as an additional robustness test.

## Software

The analysis is conducted in **R**. Principal packages used in the analysis include `dplyr`, `tidyr`, `ggplot2`, `scales`, `sandwich`, and `lmtest`.

## Data source

U.S. Small Business Administration, **7(a) & 504 FOIA** open-data files. The analysis combines the 7(a) FY2010-FY2019 file and the 7(a) FY2020-present file from the June 30, 2026 extract.

Official SBA open-data page: https://data.sba.gov/dataset/7a-504-foia

## Author

**Peter Sarpong**

Working paper, September 2026.
