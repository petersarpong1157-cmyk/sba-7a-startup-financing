# Financing New Ventures: Startup Status and Loan Terms in the U.S. SBA 7(a) Program
# Author: Peter Sarpong
# Study period: FY2010-FY2025
#
# This public script consolidates the analysis workflow used in the working paper.
# It does not redistribute the raw SBA files. Download the two 7(a) FOIA CSV files
# from https://data.sba.gov/dataset/7a-504-foia and place them in data/raw/.
#
# IMPORTANT: Update the two filenames below to match the downloaded SBA filenames.
# FY2026 is intentionally excluded because the source extract used in the study
# was available only through June 30, 2026.

library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(sandwich)
library(lmtest)

# ---------------------------------------------------------------------------
# 1. Import and combine SBA 7(a) files
# ---------------------------------------------------------------------------

file_2010_2019 <- "data/raw/FOIA_7a_FY2010_FY2019.csv"
file_2020_present <- "data/raw/FOIA_7a_FY2020_Present.csv"

sba_old <- read.csv(file_2010_2019, stringsAsFactors = FALSE)
sba_new <- read.csv(file_2020_present, stringsAsFactors = FALSE)

stopifnot(identical(names(sba_old), names(sba_new)))

sba <- bind_rows(sba_old, sba_new)

sba_main <- sba %>%
  filter(ApprovalFY >= 2010, ApprovalFY <= 2025)

# ---------------------------------------------------------------------------
# 2. Primary business-age classification
# ---------------------------------------------------------------------------

established_categories <- c(
  "Existing or more than 2 years old",
  "Existing, 5 or more years",
  "Less than 3 years old but at least 2",
  "Less than 4 years old but at least 3",
  "Less than 5 years old but at least 4"
)

sba_analysis <- sba_main %>%
  mutate(
    FirmStage = case_when(
      BusinessAge == "Startup, Loan Funds will Open Business" ~ "Startup",
      BusinessAge %in% established_categories ~ "Established",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(FirmStage)) %>%
  mutate(
    StartupBinary = ifelse(FirmStage == "Startup", 1, 0),
    NAICS2 = if_else(
      is.na(NaicsCode) | NaicsCode <= 0,
      NA_character_,
      substr(sprintf("%06.0f", NaicsCode), 1, 2)
    ),
    LogLoan = log(GrossApproval)
  )

# Primary analytical sample check
print(table(sba_analysis$FirmStage))
print(prop.table(table(sba_analysis$FirmStage)) * 100)

# ---------------------------------------------------------------------------
# 3. Descriptive statistics (Table 1)
# ---------------------------------------------------------------------------

table1 <- sba_analysis %>%
  group_by(FirmStage) %>%
  summarise(
    N = n(),
    Mean_Loan = mean(GrossApproval, na.rm = TRUE),
    Median_Loan = median(GrossApproval, na.rm = TRUE),
    Mean_Rate = mean(InitialInterestRate[InitialInterestRate > 0], na.rm = TRUE),
    Median_Rate = median(InitialInterestRate[InitialInterestRate > 0], na.rm = TRUE),
    Mean_Term_Months = mean(TermInMonths[TermInMonths > 0], na.rm = TRUE),
    Median_Term_Months = median(TermInMonths[TermInMonths > 0], na.rm = TRUE),
    Collateralized_Pct = mean(CollateralInd == "Y", na.rm = TRUE) * 100,
    Fixed_Rate_Pct = mean(FixedorVariableInterestInd == "F", na.rm = TRUE) * 100,
    Corporation_Pct = mean(BusinessType == "CORPORATION", na.rm = TRUE) * 100,
    .groups = "drop"
  )

loan_distribution <- sba_analysis %>%
  group_by(FirmStage) %>%
  summarise(
    P10 = quantile(GrossApproval, 0.10, na.rm = TRUE),
    P25 = quantile(GrossApproval, 0.25, na.rm = TRUE),
    Median = quantile(GrossApproval, 0.50, na.rm = TRUE),
    P75 = quantile(GrossApproval, 0.75, na.rm = TRUE),
    P90 = quantile(GrossApproval, 0.90, na.rm = TRUE),
    .groups = "drop"
  )

print(table1)
print(loan_distribution)

# ---------------------------------------------------------------------------
# 4. Annual startup statistics and Figure 1
# ---------------------------------------------------------------------------

startup_year <- sba_analysis %>%
  filter(FirmStage == "Startup") %>%
  group_by(ApprovalFY) %>%
  summarise(
    Startup_Loans = n(),
    Median_Loan = median(GrossApproval, na.rm = TRUE),
    Median_Rate = median(
      InitialInterestRate[InitialInterestRate > 0],
      na.rm = TRUE
    ),
    .groups = "drop"
  )

figure1 <- ggplot(startup_year, aes(x = ApprovalFY, y = Median_Loan)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_text(
    aes(label = dollar(Median_Loan, accuracy = 1)),
    vjust = -0.8,
    size = 3
  ) +
  scale_x_continuous(breaks = 2010:2025) +
  scale_y_continuous(
    labels = dollar_format(),
    limits = c(0, 310000),
    expand = expansion(mult = c(0, 0.05))
  ) +
  labs(
    title = "Median SBA 7(a) Loan Amount for Startup Businesses, FY2010–FY2025",
    subtitle = "Startup defined as 'Startup, Loan Funds will Open Business'",
    x = "Fiscal Year",
    y = "Median Gross Approval Amount",
    caption = "Source: U.S. Small Business Administration 7(a) FOIA data."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(face = "bold")
  )

# ---------------------------------------------------------------------------
# 5. Annual startup share and Figure 2
# ---------------------------------------------------------------------------

annual_startup <- sba_analysis %>%
  group_by(ApprovalFY) %>%
  summarise(
    Total = n(),
    Startup = sum(FirmStage == "Startup"),
    Startup_Share = 100 * Startup / Total,
    .groups = "drop"
  )

figure2 <- ggplot(annual_startup, aes(x = ApprovalFY, y = Startup_Share)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_text(
    aes(
      label = sprintf("%.1f%%", Startup_Share),
      vjust = ifelse(ApprovalFY == 2020, 1.7, -0.8)
    ),
    size = 3
  ) +
  scale_x_continuous(breaks = 2010:2025) +
  scale_y_continuous(
    labels = function(x) paste0(x, "%"),
    expand = expansion(mult = c(0.05, 0.15))
  ) +
  labs(
    title = "Startup Share of the SBA 7(a) Analytical Sample, FY2010–FY2025",
    subtitle = paste(
      "Startup loans as a percentage of startup and established-business",
      "loans in the analytical sample"
    ),
    x = "Fiscal Year",
    y = "Startup Share",
    caption = paste(
      "Source: U.S. Small Business Administration 7(a) FOIA data.",
      "Author's calculations."
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

# ---------------------------------------------------------------------------
# 6. Industry composition and Figure 3
# ---------------------------------------------------------------------------

industry_summary <- sba_analysis %>%
  group_by(NAICS2) %>%
  summarise(
    Total_Loans = n(),
    Startup_Loans = sum(FirmStage == "Startup"),
    Established_Loans = sum(FirmStage == "Established"),
    Startup_Share = Startup_Loans / Total_Loans * 100,
    Median_Loan = median(GrossApproval, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Loans))

figure3_data <- industry_summary %>%
  filter(!is.na(NAICS2), trimws(NAICS2) != "") %>%
  mutate(
    Industry = case_when(
      NAICS2 == "11" ~ "Agriculture, Forestry, Fishing & Hunting (11)",
      NAICS2 == "21" ~ "Mining, Quarrying, Oil & Gas Extraction (21)",
      NAICS2 == "22" ~ "Utilities (22)",
      NAICS2 == "23" ~ "Construction (23)",
      NAICS2 %in% c("31", "32", "33") ~ paste0("Manufacturing (", NAICS2, ")"),
      NAICS2 == "42" ~ "Wholesale Trade (42)",
      NAICS2 %in% c("44", "45") ~ paste0("Retail Trade (", NAICS2, ")"),
      NAICS2 %in% c("48", "49") ~ paste0("Transportation & Warehousing (", NAICS2, ")"),
      NAICS2 == "51" ~ "Information (51)",
      NAICS2 == "52" ~ "Finance & Insurance (52)",
      NAICS2 == "53" ~ "Real Estate, Rental & Leasing (53)",
      NAICS2 == "54" ~ "Professional, Scientific & Technical Services (54)",
      NAICS2 == "55" ~ "Management of Companies & Enterprises (55)",
      NAICS2 == "56" ~ "Administrative Support & Waste Management (56)",
      NAICS2 == "61" ~ "Educational Services (61)",
      NAICS2 == "62" ~ "Health Care & Social Assistance (62)",
      NAICS2 == "71" ~ "Arts, Entertainment & Recreation (71)",
      NAICS2 == "72" ~ "Accommodation & Food Services (72)",
      NAICS2 == "81" ~ "Other Services, except Public Administration (81)",
      NAICS2 == "92" ~ "Public Administration (92)",
      TRUE ~ NAICS2
    )
  ) %>%
  arrange(Startup_Share)

figure3 <- ggplot(
  figure3_data,
  aes(x = reorder(Industry, Startup_Share), y = Startup_Share)
) +
  geom_col(width = 0.7) +
  geom_text(
    aes(label = sprintf("%.1f%%", Startup_Share)),
    hjust = -0.15,
    size = 3
  ) +
  coord_flip() +
  scale_y_continuous(
    labels = function(x) paste0(x, "%"),
    expand = expansion(mult = c(0, 0.12))
  ) +
  labs(
    title = "Startup Share by Two-Digit NAICS Industry",
    subtitle = paste(
      "Startup loans as a percentage of startup and established-business",
      "loans, FY2010–FY2025"
    ),
    x = NULL,
    y = "Startup Share",
    caption = paste(
      "Source: U.S. Small Business Administration 7(a) FOIA data.",
      "Author's calculations."
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.text.y = element_text(size = 9)
  )

# ---------------------------------------------------------------------------
# 7. Regression samples
# ---------------------------------------------------------------------------

loan_lender <- sba_analysis %>%
  filter(
    !is.na(NAICS2),
    trimws(NAICS2) != "",
    !is.na(BankName),
    trimws(BankName) != ""
  )

rate_lender <- sba_analysis %>%
  filter(
    !is.na(InitialInterestRate),
    InitialInterestRate > 0,
    !is.na(NAICS2),
    trimws(NAICS2) != "",
    !is.na(BankName),
    trimws(BankName) != ""
  )

# ---------------------------------------------------------------------------
# 8. Baseline and extended models
# ---------------------------------------------------------------------------

m4_lender_model <- lm(
  LogLoan ~ StartupBinary +
    factor(ApprovalFY) +
    factor(ProjectState) +
    factor(NAICS2),
  data = loan_lender
)

m5_lender_model <- lm(
  LogLoan ~ StartupBinary +
    factor(ApprovalFY) +
    factor(ProjectState) +
    factor(NAICS2) +
    factor(ProcessingMethod) +
    factor(BusinessType) +
    factor(CollateralInd),
  data = loan_lender
)

r4_lender_model <- lm(
  InitialInterestRate ~ StartupBinary +
    factor(ApprovalFY) +
    factor(ProjectState) +
    factor(NAICS2),
  data = rate_lender
)

r5_lender_model <- lm(
  InitialInterestRate ~ StartupBinary +
    LogLoan +
    TermInMonths +
    factor(FixedorVariableInterestInd) +
    factor(ApprovalFY) +
    factor(ProjectState) +
    factor(NAICS2) +
    factor(ProcessingMethod) +
    factor(BusinessType) +
    factor(CollateralInd),
  data = rate_lender
)

# Lender-clustered inference
m4_lender <- coeftest(
  m4_lender_model,
  vcov = vcovCL(m4_lender_model, cluster = ~ BankName, type = "HC1")
)
m5_lender <- coeftest(
  m5_lender_model,
  vcov = vcovCL(m5_lender_model, cluster = ~ BankName, type = "HC1")
)
r4_lender <- coeftest(
  r4_lender_model,
  vcov = vcovCL(r4_lender_model, cluster = ~ BankName, type = "HC1")
)
r5_lender <- coeftest(
  r5_lender_model,
  vcov = vcovCL(r5_lender_model, cluster = ~ BankName, type = "HC1")
)

core_results <- data.frame(
  Outcome = c(
    "Log Gross Approval",
    "Log Gross Approval",
    "Initial Interest Rate",
    "Initial Interest Rate"
  ),
  Specification = c("Baseline", "Extended", "Baseline", "Extended"),
  Startup_Estimate = c(
    m4_lender["StartupBinary", "Estimate"],
    m5_lender["StartupBinary", "Estimate"],
    r4_lender["StartupBinary", "Estimate"],
    r5_lender["StartupBinary", "Estimate"]
  ),
  Clustered_SE = c(
    m4_lender["StartupBinary", "Std. Error"],
    m5_lender["StartupBinary", "Std. Error"],
    r4_lender["StartupBinary", "Std. Error"],
    r5_lender["StartupBinary", "Std. Error"]
  ),
  P_Value = c(
    m4_lender["StartupBinary", "Pr(>|t|)"],
    m5_lender["StartupBinary", "Pr(>|t|)"],
    r4_lender["StartupBinary", "Pr(>|t|)"],
    r5_lender["StartupBinary", "Pr(>|t|)"]
  ),
  N = c(
    nobs(m4_lender_model),
    nobs(m5_lender_model),
    nobs(r4_lender_model),
    nobs(r5_lender_model)
  ),
  Year_FE = "Yes",
  State_FE = "Yes",
  Industry_FE = "Yes",
  Additional_Controls = c("No", "Yes", "No", "Yes")
)

loan_effects <- core_results %>%
  filter(Outcome == "Log Gross Approval") %>%
  mutate(Percent_Difference = 100 * (exp(Startup_Estimate) - 1))

print(core_results)
print(loan_effects)

# ---------------------------------------------------------------------------
# 9. Robustness: project-jurisdiction clustering
# ---------------------------------------------------------------------------

m5_state <- coeftest(
  m5_lender_model,
  vcov = vcovCL(m5_lender_model, cluster = ~ ProjectState, type = "HC1")
)

r5_state <- coeftest(
  r5_lender_model,
  vcov = vcovCL(r5_lender_model, cluster = ~ ProjectState, type = "HC1")
)

print(m5_state["StartupBinary", ])
print(r5_state["StartupBinary", ])

# ---------------------------------------------------------------------------
# 10. Robustness: stricter established-business definition
# ---------------------------------------------------------------------------

strict_sample <- sba_main %>%
  mutate(
    FirmStageStrict = case_when(
      BusinessAge == "Startup, Loan Funds will Open Business" ~ "Startup",
      BusinessAge %in% c(
        "Existing, 5 or more years",
        "Existing or more than 2 years old"
      ) ~ "Established",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(FirmStageStrict)) %>%
  mutate(
    StartupBinary = ifelse(FirmStageStrict == "Startup", 1, 0),
    NAICS2 = if_else(
      is.na(NaicsCode) | NaicsCode <= 0,
      NA_character_,
      substr(sprintf("%06.0f", NaicsCode), 1, 2)
    ),
    LogLoan = log(GrossApproval)
  )

strict_loan <- strict_sample %>%
  filter(
    !is.na(NAICS2),
    trimws(NAICS2) != "",
    !is.na(BankName),
    trimws(BankName) != ""
  )

strict_rate <- strict_sample %>%
  filter(
    !is.na(InitialInterestRate),
    InitialInterestRate > 0,
    !is.na(NAICS2),
    trimws(NAICS2) != "",
    !is.na(BankName),
    trimws(BankName) != ""
  )

strict_m <- lm(
  LogLoan ~ StartupBinary +
    factor(ApprovalFY) +
    factor(ProjectState) +
    factor(NAICS2) +
    factor(ProcessingMethod) +
    factor(BusinessType) +
    factor(CollateralInd),
  data = strict_loan
)

strict_r <- lm(
  InitialInterestRate ~ StartupBinary +
    log(GrossApproval) +
    TermInMonths +
    factor(FixedorVariableInterestInd) +
    factor(ApprovalFY) +
    factor(ProjectState) +
    factor(NAICS2) +
    factor(ProcessingMethod) +
    factor(BusinessType) +
    factor(CollateralInd),
  data = strict_rate
)

strict_m_cluster <- coeftest(
  strict_m,
  vcov = vcovCL(strict_m, cluster = ~ BankName, type = "HC1")
)

strict_r_cluster <- coeftest(
  strict_r,
  vcov = vcovCL(strict_r, cluster = ~ BankName, type = "HC1")
)

print(table(strict_sample$FirmStageStrict))
print(strict_m_cluster["StartupBinary", ])
print(strict_r_cluster["StartupBinary", ])
print(100 * (exp(coef(strict_m)["StartupBinary"]) - 1))

# ---------------------------------------------------------------------------
# 11. Export reproducible outputs
# ---------------------------------------------------------------------------

dir.create("figures", showWarnings = FALSE, recursive = TRUE)
dir.create("tables", showWarnings = FALSE, recursive = TRUE)

ggsave(
  "figures/Figure_1_Median_Startup_Loan.png",
  plot = figure1,
  width = 9,
  height = 5.5,
  dpi = 300
)

ggsave(
  "figures/Figure_2_Startup_Share_FY2010_2025.png",
  plot = figure2,
  width = 9,
  height = 5.5,
  dpi = 300
)

ggsave(
  "figures/Figure_3_Startup_Share_by_NAICS.png",
  plot = figure3,
  width = 11,
  height = 8,
  dpi = 300
)

write.csv(table1, "tables/table1_descriptive_statistics.csv", row.names = FALSE)
write.csv(core_results, "tables/table2_core_regression_results.csv", row.names = FALSE)
write.csv(annual_startup, "tables/annual_startup_share.csv", row.names = FALSE)
write.csv(industry_summary, "tables/industry_summary.csv", row.names = FALSE)

# End of reproducible analysis.


# ============================================================
# VERSION 2: CORRECTED HETEROGENEITY SPECIFICATIONS
# Revised JEF analysis. These models include the common
# StartupBinary coefficient and the corresponding industry/year
# fixed effects so the Wald tests assess equality of startup slopes.
# ============================================================

industry_model2 <- fixest::feols(
  LogLoan ~
    StartupBinary +
    i(NAICS2, StartupBinary, ref = "54") +
    factor(ProcessingMethod) +
    factor(BusinessType) +
    factor(CollateralInd) |
    ApprovalFY + ProjectState + NAICS2 + BankName,
  data = v2_sample,
  cluster = ~BankName
)

summary(industry_model2)
fixest::wald(industry_model2, keep = "NAICS2::")
# Verified result: F(23, 2611) = 16.00, p < .001.

time_model2 <- fixest::feols(
  LogLoan ~
    StartupBinary +
    i(ApprovalFY, StartupBinary, ref = 2010) +
    factor(ProcessingMethod) +
    factor(BusinessType) +
    factor(CollateralInd) |
    ApprovalFY + ProjectState + NAICS2 + BankName,
  data = v2_sample,
  cluster = ~BankName
)

summary(time_model2)
fixest::wald(time_model2, keep = "ApprovalFY::")
# Verified result: F(15, 2611) = 8.34, p < .001.
