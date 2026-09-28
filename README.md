# Financing New Ventures: Startup Status, Lender Composition, and Loan Terms in the U.S. SBA 7(a) Program

This repository contains reproducible research materials for the revised working paper examining approved loan amounts and initial interest rates for startup and established-business borrowers in the U.S. Small Business Administration (SBA) 7(a) program.

**[Read the revised Version 2 working paper (PDF)](paper/Sarpong_SBA_7a_JEF_Version_2_Final_Corrected.pdf)** | **[View the R analysis](code/sba_7a_analysis.R)** | **[View the results tables](tables/)** | **[Data documentation](data/README.md)**

## Research question

**How do approved loan amounts and initial interest rates differ between startup and established-business borrowers within the SBA 7(a) program, and how sensitive are these differences to program and loan characteristics, lender composition, industry, and fiscal year?**

## Study period and analytical sample

The analysis uses SBA 7(a) FOIA loan-level records covering complete fiscal years **FY2010-FY2025**. FY2026 is excluded because the source extract used for the project was available only through June 30, 2026.

The primary analytical sample contains **681,992 approved SBA 7(a) loans**:

- **138,054 startup loans**
- **543,938 established-business loans**

A startup is defined using the SBA `BusinessAge` category **"Startup, Loan Funds will Open Business."** The established-business comparison group uses clearly established business-age categories available in the source files.

## Revised main findings

In the common-sample loan-amount analysis, the baseline specification implies approximately **18.0% higher** approved amounts for startups. The estimate changes to **-7.1%** after adjustment for processing method and to **-13.7%** after business type and collateral are also included.

With lender fixed effects, the baseline startup difference falls to approximately **+4.8%** and is not statistically significant. The fully adjusted lender fixed-effects estimate is approximately **-15.2%**.

For initial interest rates, startup status is associated with rates approximately **0.205 percentage points lower** in the baseline specification and **0.104 percentage points lower** in the fully adjusted specification without lender fixed effects. These differences do **not** persist within lenders: the fully adjusted lender fixed-effects estimate is approximately **+0.046 percentage points** and is not statistically significant.

Corrected heterogeneity specifications show significant variation in the startup-loan amount relationship:

- **Industry heterogeneity:** Wald F(23, 2611) = **16.00**, p < .001.
- **Fiscal-year heterogeneity:** Wald F(15, 2611) = **8.34**, p < .001.

The industry-specific point estimates are presented descriptively; the joint Wald test provides the primary inference on industry heterogeneity.

## Interpretation

These estimates describe **conditional associations among approved SBA 7(a) loans**. They do **not** identify a causal effect of startup status and do **not** estimate whether startups are more or less likely to obtain credit.

The revised analysis emphasizes specification sensitivity, lender composition, program and loan characteristics, and heterogeneity across industry and time rather than a universal startup financing premium or penalty.

## Methods

The revised empirical workflow includes:

- construction of a consistent startup/established-business classification;
- descriptive statistics and loan-amount distributions;
- common-sample sequential loan-amount and interest-rate specifications;
- fiscal-year, project-jurisdiction, and two-digit NAICS fixed effects;
- lender-clustered standard errors;
- lender fixed-effects specifications;
- corrected startup-by-industry heterogeneity specifications;
- corrected startup-by-fiscal-year heterogeneity specifications;
- project-jurisdiction clustering as a robustness check;
- a stricter business-age classification;
- CPI-U inflation-adjusted descriptive loan-amount trends; and
- inflation-adjusted lender fixed-effects robustness analysis.

## Software

The analysis is conducted in **R**. Principal packages include `dplyr`, `tidyr`, `ggplot2`, `scales`, `sandwich`, `lmtest`, and `fixest`.

## Data source

U.S. Small Business Administration, **7(a) & 504 FOIA** open-data files. The analysis combines the 7(a) FY2010-FY2019 file and the 7(a) FY2020-present file from the June 30, 2026 extract.

Official SBA open-data page: https://data.sba.gov/dataset/7a-504-foia

Raw SBA datasets are not stored in this repository.

## Version 2 figures

- [Figure 1: nominal and inflation-adjusted startup loan amounts](figures/figure1_nominal_real.png)
- [Figure 3: industry-specific startup–established loan-amount differences](figures/figure3_industry_heterogeneity.png)

## Version 2 correction note

The revised heterogeneity models include a common `StartupBinary` coefficient together with startup-by-industry or startup-by-year interactions and the corresponding fixed effects. This parameterization makes the interaction Wald tests assessments of equality of startup slopes across industries or fiscal years. The corrected joint statistics are **F(23, 2611) = 16.00** for industry and **F(15, 2611) = 8.34** for fiscal year.

## Author

**Peter Sarpong**

Revised working paper, September 2026.
