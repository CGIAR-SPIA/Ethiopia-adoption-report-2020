# ===============================================================================
# Title: "Replication script for Table 10, 11, 12 and Fig 4, 9"
# Author: f.kosmowski@cgiar.org
# Date: April 2020
# Last edited by: M.Kirinyet@cgiar.org on 22/09/2025
# ===============================================================================

# Clear environment
rm(list = ls())

# Install and load required packages
required_packages <- c("readstata13", "haven", "dplyr", "ggthemes", "scales", 
                       "ggplot2", "gridExtra", "writexl", "grid")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

# Load and prepare data
DNA_data <- read.csv(file.path("data", "raw_data", "Auxiliary_data", "DNA_data_reports.csv"))
Var <- read.csv(file.path("data", "raw_data", "Auxiliary_data", "Var_data.csv"))

# Merge datasets
DNA_data <- droplevels(DNA_data) 
DNA_data <- merge(DNA_data, Var, by = 'subbinReferences', all.x = TRUE)

# ===============================================================================
# TABLE 10:Distribution of barley by variety planted during the 2018/19 growing season ----
# ===============================================================================

# Filter barley data
B <- DNA_data[DNA_data$Crop == 'Barley', ]
B$subbinReferences <- droplevels(factor(B$subbinReferences))

# Create frequency table
barley_table <- table(B$subbinReferences)
barley_df <- as.data.frame(barley_table)
names(barley_df) <- c("Variety", "N")

# Calculate percentages
B_total_samples <- sum(barley_df$N, na.rm = TRUE)
barley_df$percent_of_samples <- round((barley_df$N / B_total_samples) * 100, 1)

# Get variety information
B_variety_info <- B %>%
  filter(!is.na(subbinReferences)) %>%
  select(subbinReferences, Year_release, Variety_type, Crop_specific_variety_type) %>%
  distinct()

# Calculate years since release
B_variety_info$years_since_release <- 2019 - B_variety_info$Year_release

# Merge with variety info
table10_data <- merge(barley_df, B_variety_info, 
                      by.x = "Variety", by.y = "subbinReferences", 
                      all.x = TRUE)

# Clean variety names - Step by step approach
table10_data$variety_clean <- as.character(table10_data$Variety)

# Remove prefixes in sequence
table10_data$variety_clean <- gsub("^RL_", "", table10_data$variety_clean)
table10_data$variety_clean <- gsub("^RL:", "", table10_data$variety_clean)
table10_data$variety_clean <- gsub("^RLi-", "", table10_data$variety_clean)
table10_data$variety_clean <- gsub("_[A-Z]$", "", table10_data$variety_clean)
table10_data$variety_clean <- gsub("_C$", "", table10_data$variety_clean)
table10_data$variety_clean <- gsub("_B$", "", table10_data$variety_clean)

# Convert to proper title case and handle special cases
table10_data$variety_clean <- tools::toTitleCase(tolower(table10_data$variety_clean))

# Fix specific formatting issues with single gsub calls
table10_data$variety_clean <- gsub("Miscal_21", "Miscal-21", table10_data$variety_clean)
table10_data$variety_clean <- gsub("Abay-A", "Abay", table10_data$variety_clean)

# Sort by sample size
table10_data <- table10_data[order(-table10_data$N), ]

# Create final table
table10 <- data.frame(
  Variety = table10_data$variety_clean,
  N = table10_data$N,
  Percent_of_barley_samples = table10_data$percent_of_samples,
  Variety_type = table10_data$Crop_specific_variety_type,
  Years_since_release = table10_data$years_since_release,
  Release_year = table10_data$Year_release
)

# Print Table 10
print(table10)

# Save as Excel files
write_xlsx(table10, path = file.path("outputs", "tables", "Table10_Barley.xlsx"))

# ===============================================================================
# TABLE 11:  Distribution of maize by variety planted during the 2018/19 growing season ----
# ===============================================================================

# Filter and prepare maize data
M <- DNA_data[DNA_data$Crop == 'Maize', ]
M$subbinReferences <- as.character(M$subbinReferences)

# Apply maize variety code mappings
maize_mappings <- c(
  'RM0012017' = 'AMH852Q', 'RM0022017' = 'Melkassa-1', 'RM0042017' = 'Kulani',
  'RM0062017' = 'Melkassa-1Q', 'RM0142017' = 'Wenchi', 'RM0202017' = 'Shone',
  'RM0212017' = 'Damote', 'RM0222017' = 'Jabi', 'RM0232017' = 'Limu',
  'RM0262017' = 'BH-140', 'RM0292017' = 'BH-661', 'RM0312017' = 'BH-540',
  'RM0472017' = 'BH-661', 'RM0482017' = 'BH-660', 'RM0512017' = 'GIBE1'
)

for (old_code in names(maize_mappings)) {
  M$subbinReferences[M$subbinReferences == old_code] <- maize_mappings[old_code]
}

# Create frequency table
maize_table <- table(M$subbinReferences)
maize_df <- as.data.frame(maize_table)
names(maize_df) <- c("Variety", "N")

# Calculate percentages
M_total_samples <- sum(maize_df$N, na.rm = TRUE)
maize_df$percent_of_samples <- round((maize_df$N / M_total_samples) * 100, 1)

# Get variety information
M_variety_info <- M %>%
  filter(!is.na(subbinReferences)) %>%
  select(subbinReferences, Year_release, Variety_type, Crop_specific_variety_type) %>%
  distinct()

M_variety_info$years_since_release <- 2019 - M_variety_info$Year_release

# Merge with variety info
table11_data <- merge(maize_df, M_variety_info, 
                      by.x = "Variety", by.y = "subbinReferences", 
                      all.x = TRUE)

# Sort by sample size
table11_data <- table11_data[order(-table11_data$N), ]

# Create final table
table11 <- data.frame(
  Variety = table11_data$Variety,
  N = table11_data$N,
  Percent_of_maize_samples = table11_data$percent_of_samples,
  Variety_type = table11_data$Crop_specific_variety_type,
  Years_since_release = table11_data$years_since_release,
  Release_year = table11_data$Year_release
)

# Print Table 11
print(table11)
write_xlsx(table11, path = file.path("outputs", "tables", "Table11_Maize.xlsx"))

# ===============================================================================
# TABLE 12: Distribution of sorghum by variety planted during the 2018/19 growing season
# ===============================================================================

# Filter sorghum data
S <- DNA_data[DNA_data$Crop == 'Sorghum', ]
S$subbinReferences <- droplevels(factor(S$subbinReferences))

# Create frequency table
sorghum_table <- table(S$subbinReferences)
sorghum_df <- as.data.frame(sorghum_table)
names(sorghum_df) <- c("Variety", "N")

# Calculate percentages
S_total_samples <- sum(sorghum_df$N, na.rm = TRUE)
sorghum_df$percent_of_samples <- round((sorghum_df$N / S_total_samples) * 100, 1)

# Get variety information
S_variety_info <- S %>%
  filter(!is.na(subbinReferences)) %>%
  select(subbinReferences, Year_release, Variety_type, Crop_specific_variety_type) %>%
  distinct()

S_variety_info$years_since_release <- 2019 - S_variety_info$Year_release

# Merge with variety info
table12_data <- merge(sorghum_df, S_variety_info, 
                      by.x = "Variety", by.y = "subbinReferences", 
                      all.x = TRUE)

# Sort by sample size
table12_data <- table12_data[order(-table12_data$N), ]

# Create final table
table12 <- data.frame(
  Variety = table12_data$Variety,
  N = table12_data$N,
  Percent_of_sorghum_samples = table12_data$percent_of_samples,
  Variety_type = table12_data$Crop_specific_variety_type,
  Years_since_release = table12_data$years_since_release,
  Release_year = table12_data$Year_release
)

# Print Table 12
print(table12)
write_xlsx(table12, path = file.path("outputs", "tables", "Table12_Sorghum.xlsx"))
# ===============================================================================
#  Figure 4: Adoption estimates for conservation agriculture (CA)
# ===============================================================================

# Conservation agriculture data
CA_data <- data.frame(
  CA = c("CA/MT", "CA/MT", "CA/ZT", "CA/ZT", "CRC", "CRC", 
         "CR", "CR", "MT", "MT", "ZT", "ZT"),
  Method = c("HH", "EA", "HH", "EA", "HH", "EA", 
             "HH", "EA", "HH", "EA", "HH", "EA"),
  Value = c(4.3, 18.5, 1.3, 7, 44.7, 63.1, 
            55.8, 76.2, 47.6, 80.6, 11.6, 36.3)
)

# Set factor levels
CA_data$CA <- factor(CA_data$CA, levels = c('MT', 'ZT', 'CRC', 'CR', 'CA/MT', 'CA/ZT'))

# Create EA-level plot
EA_CA <- ggplot(data = CA_data[CA_data$Method == 'EA', ], aes(x = CA, y = Value)) + 
  geom_bar(stat = 'identity', fill = "#4a7c7a", width = 0.7) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 25)) +
  theme_wsj(base_size = 10) +
  theme(
    plot.title = element_text(size = 12, hjust = 0.5, color = "#5ba3a3"),
    axis.title = element_blank(),
    axis.text.x = element_text(size = 9, color = "black"),
    axis.text.y = element_text(size = 9, color = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "#f5f2e8", color = NA),
    plot.background = element_rect(fill = "#f5f2e8", color = NA),
    axis.ticks.x = element_line(color = "black"),
    axis.line.x = element_line(color = "black", linewidth = 0.5),
    plot.margin = margin(5, 2, 5, 2)
  ) +
  labs(title = "EA-level")

# Create HH-level plot
HH_CA <- ggplot(data = CA_data[CA_data$Method == 'HH', ], aes(x = CA, y = Value)) + 
  geom_bar(stat = 'identity', fill = "#4a7c7a", width = 0.7) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 25)) +
  theme_wsj(base_size = 10) +
  theme(
    plot.title = element_text(size = 12, hjust = 0.5, color = "#5ba3a3"),
    axis.title = element_blank(),
    axis.text.x = element_text(size = 9, color = "black"),
    axis.text.y = element_text(size = 9, color = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "#f5f2e8", color = NA),
    plot.background = element_rect(fill = "#f5f2e8", color = NA),
    axis.ticks.x = element_line(color = "black"),
    axis.line.x = element_line(color = "black", linewidth = 0.5),
    plot.margin = margin(5, 2, 5, 2)
  ) +
  labs(title = "Household-level")

# Create legend
legend_grob <- grobTree(
  rectGrob(gp = gpar(fill = "#ADD8E6", col = NA)),
  textGrob(
    "MT = Minimum tillage; ZT = Zero tillage; CRC = Crop residue cover (visual aids); CR = Crop rotation;\nCA/MT = Conservation agriculture with minimum tillage; CA/ZT = Conservation agriculture with zero tillage", 
    gp = gpar(fontsize = 9, col = "white", fontface = "bold"),
    x = 0.5, hjust = 0.5, vjust = 0.5
  )
)

# Combine plots
combined_plot <- grid.arrange(
  legend_grob,
  arrangeGrob(EA_CA, HH_CA, ncol = 2, widths = c(1, 1)),
  heights = c(2, 10),
  ncol = 1
)

# Define your title
fig_title <- "Figure 4"

# Save using the cleaned title
ggsave(
  filename = file.path("outputs", "figures", paste0(fig_title, ".png")),
  plot = combined_plot,
  width = 8, height = 6, dpi = 300
)

# ===============================================================================
# Figure 9: Number of rural households adopting each CGIAR-related innovation in Ethiopia in 2019
# ===============================================================================

# Load absolute adoption data
Abs_data <- read.csv(file.path("data", "report_data", "Absolute_plots.csv"))

# Create Figure 9
figure9 <- ggplot(data = Abs_data, aes(reorder(Innovation, N2), y = N2)) + 
  geom_bar(stat = 'identity', fill = "#295c5a") +
  scale_y_continuous(limits = c(0, 10), breaks = seq(0, 10, 1)) +
  theme_wsj(base_size = 10) +
  theme(
    plot.title = element_text(size = 12),
    axis.text.x = element_text(angle = 90, hjust = 0.95, vjust = 0.2)
  ) +
  labs(
    x = NULL,
    y = "Abs. number of adopters, in millions",
    title = ""
  )

print(figure9)

# Define your title
fig_title <- "figure9"

# Save using the cleaned title
ggsave(
  filename = file.path("outputs", "figures", paste0(fig_title, ".png")),
  plot = figure9,
  width = 8, height = 6, dpi = 300
)

# ===============================================================================
# End of Script
# ===============================================================================
