# Acceptance and reproducibility verification — JEF MS #1558

**Article:** Financing New Ventures: Startup Status, Lender Composition, and Loan Terms in the U.S. SBA 7(a) Program
**Author:** Peter Sarpong, Independent Researcher
**Journal:** The Journal of Entrepreneurial Finance
**Status:** Accepted for publication in November 2026; publication date, issue, pagination and article DOI not yet confirmed.

## Source and cohort
FY2010–FY2025 SBA 7(a) FOIA extracts (as of June 30, 2026): 893,265 fiscal-year-filtered records; 681,992 eligible approved loans (138,054 startup, 543,938 established).

## Verified loan-amount regressions
All four startup estimates and standard errors in each of Tables 2 and 3 were reproduced to four decimal places. Table 2's 681,956 eligible observations become 681,955 after one singleton removal. Table 3 contains 681,539 observations after 416 additional singleton removals.

| Model | Startup beta | Lender-clustered SE | N |
| --- | ---: | ---: | ---: |
| Baseline without lender FE | 0.1657 | 0.0709 | 681,955 |
| + processing | -0.0736 | 0.0606 | 681,955 |
| + business type | -0.0836 | 0.0599 | 681,955 |
| + collateral | -0.1478 | 0.0512 | 681,955 |
| Baseline with lender FE | 0.0468 | 0.0475 | 681,539 |
| + processing, lender FE | -0.1286 | 0.0302 | 681,539 |
| + business type, lender FE | -0.1338 | 0.0287 | 681,539 |
| + collateral, lender FE | -0.1654 | 0.0265 | 681,539 |

Project-state clustering: fully adjusted loan-amount beta -0.1478, SE 0.0141. Strict business-age sample: beta -0.1779, lender-clustered SE 0.0521, N=599,335.

## Interest-rate sample audit
The fully adjusted complete-case pool contains 681,738 loans. Excluding 34 blank business-type entries yields 681,704; one fixed-effect singleton is removed without lender FE (N=681,703). Adding lender FE removes 416 further singleton observations (N=681,287).

Fully adjusted no-lender-FE rate startup beta -0.1044 percentage points (SE 0.0407). Fully adjusted lender-FE beta +0.0455 percentage points (SE 0.0327). On the same 681,287 observations, baseline no-lender-FE beta -0.2052 (SE 0.0819), fully adjusted no-lender-FE beta -0.1045 (SE 0.0407), and fully adjusted lender-FE beta +0.0455 (SE 0.0327).

Project-state-clustered rate coefficient -0.1044 (SE 0.0217). Strict business-age rate coefficient -0.0931 (SE 0.0423; N=599,134). Table 6 was corrected from -0.1046 to -0.1044, and the strict-sample rounded rate figure to -0.0931.

With lender FE, the intermediate collateral-adjusted rate estimate is +11.55 basis points (p=.003); the fully adjusted estimate is +4.55 basis points (p=.163).

## Processing composition
Preferred Lenders Program: 50.5% of startup loans versus 38.0% of established loans. SBA Express: 25.2% versus 48.0%. The 7(a) General program: 12.6% versus 5.95%. These are descriptive differences.

## Scope and provenance
Estimates are observational conditional associations among **approved loans**, not causal effects or estimates of approval/access. Lenders are identified by the SBA BankName field, not a separately validated persistent institution ID. The raw SBA data are not redistributed. Official source: https://data.sba.gov/dataset/7a-504-foia .

The existing Zenodo v3.3.2 release predates journal acceptance; it is not the published journal article or an article DOI. Verify permissions before releasing the publisher-formatted manuscript.