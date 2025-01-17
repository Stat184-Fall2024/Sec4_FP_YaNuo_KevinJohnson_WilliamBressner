# Load required libraries
library(tidyverse)
library(knitr)
library(kableExtra)
library(ggplot2)

# Load employment trends data 
employment_trends <- read.csv("~/Desktop/Stat 184/employment_trends.csv")
# Data cleaning
employment_trends_clean <- employment_trends %>%
  filter(REF_DATE >= "2015-01" & REF_DATE <= "2024-12",
         UOM != "Dollars") %>%
  mutate(
    REF_DATE = as.character(REF_DATE),
    Employment = replace_na(VALUE, 0), 
    Period = ifelse(REF_DATE < "2020-01", "Pre-Pandemic", "Post-Pandemic")
  ) %>%
  select(-c(DGUID, SYMBOL, TERMINATED, SCALAR_FACTOR, SCALAR_ID, STATUS, DECIMALS, Estimate, VECTOR, COORDINATE, UOM_ID)) %>%
  rename(
    Industry = North.American.Industry.Classification.System..NAICS., 
    Region = GEO,
    Date = REF_DATE
  )

write.csv(employment_trends_clean, "employment_trends_clean.csv", row.names = FALSE)

# Create subsets for post-pandemic and pre-pandemic data
post_pandemic_employment_trends <- employment_trends_clean %>%
  filter(Date >= "2020-01" & Date <= "2024-12")

pre_pandemic_employment_trends <- employment_trends_clean %>%
  filter(Date >= "2015-01" & Date <= "2019-12")

# Filter data for specific industries within Canada
industries_summary <- employment_trends_clean%>%
  filter(
    Region == "Canada", 
    Industry %in% c("Goods producing industries [11-33N]", 
                    "Service producing industries [41-91N]",
                    "Mining, quarrying, and oil and gas extraction [21]",
                    "Construction [23]",
                    "Manufacturing [31-33]",
                    "Transportation and warehousing [48-49]",
                    "Health care and social assistance [62]",
                    "Accommodation and food services [72]")
  )

# Calculate summary statistics
summary_stats <- industries_summary %>%
  filter(Region == "Canada") %>% 
  group_by(Period, Industry) %>%
  summarise(
    Avg_Employment = mean(Employment, na.rm = TRUE),
    Min_Employment = min(Employment, na.rm = TRUE),
    Max_Employment = max(Employment, na.rm = TRUE),
    SD_Employment = sd(Employment, na.rm = TRUE)
  ) %>%
  arrange(Industry, Period)
# Display to a table
kable(summary_stats, caption = "Summary Statistics for Employment Trends in Canada") %>%
  kable_styling(bootstrap_options = c("striped", "hover"), full_width = FALSE, font_size = 8) %>%
  kableExtra::column_spec(2, width = "5cm")

# Filter data
filtered_data_canada <- employment_trends_clean %>%
  filter(
    Region == "Canada", 
    Industry %in% c("Goods producing industries [11-33N]", 
                    "Service producing industries [41-91N]")
  )
# Summarize total employment by date and industry
industry_trends_canada <- filtered_data_canada %>%
  group_by(Date, Industry) %>%
  summarise(Total_Employment = sum(Employment, na.rm = TRUE)) %>%
  ungroup()
# Plot employment trends over time using ggplot
ggplot(industry_trends_canada, aes(x = Date, y = Total_Employment, color = Industry, group = Industry)) +
  geom_line(size = 1.2) +
  labs(
    title = "Employment Trends Over Time in Canada (2015–2024)",
    subtitle = "Comparison of Goods Producing and Service Producing Industries",
    x = "Year-Month",
    y = "Total Employment",
    color = "Industry"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom",
    legend.title = element_blank(),
    legend.text = element_text(size = 8)
  ) +
  scale_x_discrete(
    breaks = c("2015-01", "2017-01", "2019-01", "2021-01", "2023-01")
  ) +
  scale_y_continuous(labels = scales::comma)

# Define Goods Producing Industries
goods_industries <- c("Manufacturing [31-33]", 
                      "Construction [23]", 
                      "Mining, quarrying, and oil and gas extraction [21]")
# Filter data
goods_data <- employment_trends_clean %>%
  filter(
    Industry %in% goods_industries,
    Region == "Canada"
  )
# Calculate average employment
goods_summary <- goods_data %>%
  group_by(Industry, Period) %>%
  summarise(Average_Employment = mean(Employment, na.rm = TRUE)) %>%
  ungroup()
# Convert Period to factor with specific levels
goods_summary <- goods_summary %>%
  mutate(Period = factor(Period, levels = c("Pre-Pandemic", "Post-Pandemic")))
# Plot average employment levels for Goods Producing Industries
ggplot(goods_summary, aes(x = Industry, y = Average_Employment, fill = Period)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_text(aes(label = scales::comma(round(Average_Employment, 0))), 
            position = position_dodge(width = 0.9), 
            vjust = -0.25, size = 3) +
  labs(
    title = "Average Employment Levels: Goods Producing Industries",
    subtitle = "Pre-Pandemic (2015–2019) vs Post-Pandemic (2020–2024)",
    x = "Industry",
    y = "Average Employment"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10.5),
    legend.position = "bottom"
  ) +
  scale_fill_manual(values = c("Pre-Pandemic" = "#2C7FB8", "Post-Pandemic" = "#D95F02")) +
  scale_y_continuous(labels = scales::comma)

# Define Service Producing Industries
service_industries <- c("Health care and social assistance [62]",
                        "Accommodation and food services [72]",
                        "Transportation and warehousing [48-49]")
# Filter data
service_data <- employment_trends_clean %>%
  filter(
    Industry %in% service_industries,
    Region == "Canada"
  )
# Calculate average employment
service_summary <- service_data %>%
  group_by(Industry, Period) %>%
  summarise(Average_Employment = mean(Employment, na.rm = TRUE)) %>%
  ungroup()
# Convert Period to factor with specific levels
service_summary <- service_summary %>%
  mutate(Period = factor(Period, levels = c("Pre-Pandemic", "Post-Pandemic")))
# Plot average employment levels for Service Producing Industries
ggplot(service_summary, aes(x = Industry, y = Average_Employment, fill = Period)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_text(aes(label = scales::comma(round(Average_Employment, 0))), 
            position = position_dodge(width = 0.9), 
            vjust = -0.25, size = 3) +
  labs(
    title = "Average Employment Levels: Service Producing Industries",
    subtitle = "Pre-Pandemic (2015–2019) vs Post-Pandemic (2020–2024)",
    x = "Industry",
    y = "Average Employment"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10.5),
    legend.position = "bottom"
  ) +
  scale_fill_manual(values = c("Pre-Pandemic" = "#2C7FB8", "Post-Pandemic" = "#D95F02")) +
  scale_y_continuous(labels = scales::comma)

