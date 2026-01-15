
# ---
# Title: "Matching ESS EAs to the closest location of CGIAR research activities per innovation"
# Author email: "f.kosmowski@cgiar.org"
# Date: "June 2020"
# ---


# This script calculates the distance between georeferenced locations of CGIAR center research activities and 
# the Ethiopian socio-Economic survey EAs. The script first sets spatial coordinates from both datasets and 
# creates a Spatial object. For each innovation, a k-nearest neighbor classifier is used to calculate the closest 
# distance from each EA to a woreda with research activity for that particular innovation. For each EA, the 
# k-nearest Euclidean distance of latitude and longitude coordinates is found (Cover et al., 1967), revealing the 
# closest match within a radius of each georeferenced EA. Analysis were published in the SPIA report "Shining a 
# brighter light: Comprehensive evidence on adoption and diffusion of CGIAR-related innovations in Ethiopia" in 2020

# Inputs
  # Innov_GPS - contains innovations and location of projects in Ethiopia (1999-2019). The last spreadsheet (CG areas GPS v16.06) of "Stocktake_locations_def.xlsx" should be used
  # Zones_Level_2.shp - Shapefile of Ethiopia's adminstrative zones
  # ESS_GPS - dataset containing ESS centroids

# Output
  # ESS.Distances.csv with variables:
     # Dist_CG_LargeR = Distance from closest area of activities
     # N_20_CG_LargeR = N area of activities within a 20km radius
     # N_50_CG_LargeR = N area of activities within a 50km radius
     # N_100_CG_LargeR = N area of activities within a 100km radius

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Clears the workspace and lists files 
rm(list = ls())
list.files()

# Required package handling. 
required_packages <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE)) {
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
    }
  }
}

required_packages(c("readxl", "haven", "dplyr", "sp", "FNN", "ggplot2", "sf", "nabor","readstata13", "class"))


# Set file paths
data_dir <- "data"
raw_data_dir <- file.path(data_dir, "raw_data")
processed_data_dir <- file.path(data_dir, "report_data")
dashboard_dir <- file.path(raw_data_dir, "Dashboard locations")
ess3_dir <- file.path(raw_data_dir, "ESS3_2015-16", "Data", "STATA")
ess4_dir <- file.path(raw_data_dir, "ESS4_2018-19", "Data", "HH")


# Section 1: Load and prepare project location data ---------------------
Innov_GPS <- read_excel(
  file.path(dashboard_dir, "Stocktake_locations.xlsx"), 
  sheet = "CG areas GPS v16.06"
)

# Remove entries with missing coordinates
sum(is.na(Innov_GPS$x_c))
Innov_GPS <- Innov_GPS[!is.na(Innov_GPS$x_c), ]
Innov_GPS_ori <- Innov_GPS

# Categorize innovations into core domains
Innov_GPS$CGcore[Innov_GPS$CGinovation %in% c('Large ruminants crossbred', 'Poultry crossbred', 'Small ruminants crossbred')] <- 'a) Animal agriculture'
Innov_GPS$CGcore[Innov_GPS$CGinovation %in% c('Avocado trees', 'Conservation Agriculture', 'Watershed SLM')] <- 'c) Natural Resource Management'
Innov_GPS$CGcore[Innov_GPS$CGinovation %in% c('DTMZ varieties', 'Improved sorghum varieties', 'NuME varieties', 'OFSP', 'PPP for barley seed dissemination')] <- 'b) Crop germplasm improvement'

# Table: Overview of georeferenced location collected
table(Innov_GPS$CGinovation)

# Section 2: Load and prepare ESS GPS data -------------------------------

# Load ESS3 GPS data 
ESS3_geo <- read_dta(file.path(ess3_dir, "ETH_HouseholdGeovars_y3.dta"))

# Create unique EA coordinates 
ESS_GPS_ori <- ESS3_geo %>%
  group_by(ea_id2) %>%
  summarise(
    lat_dd_mod = first(lat_dd_mod),
    lon_dd_mod = first(lon_dd_mod),
    .groups = 'drop'
  )

# Rename columns to match what the script expects
ESS_GPS_ori <- ESS_GPS_ori %>%
  rename(
    ea_id = ea_id2,
    s3q09__Latitude = lat_dd_mod,
    s3q09__Longitude = lon_dd_mod
  )

# Create the ESS_GPS dataset for spatial operations
ESS_GPS <- ESS_GPS_ori
coordinates(ESS_GPS) <- ~ s3q09__Longitude + s3q09__Latitude

# Load ESS4 zone data for additional geographic information
zone.dat <- read_dta(file.path(ess4_dir, "sect_cover_hh_w4.dta"))
zone.dat <- zone.dat[, c(2, 5, 6, 7)]
zone.dat <- zone.dat[!duplicated(zone.dat$ea_id), ]
ESS_GPS_ori <- merge(ESS_GPS_ori, zone.dat, by='ea_id', all.x=TRUE)

# Convert coordinates to numeric and filter out missing values
Innov_GPS$x_c <- as.numeric(Innov_GPS$x_c)
Innov_GPS$y_c <- as.numeric(Innov_GPS$y_c)
Innov_GPS <- Innov_GPS[!is.na(Innov_GPS$x_c) & !is.na(Innov_GPS$y_c), ]

# Check what we have
cat("Number of ESS EAs with coordinates:", nrow(ESS_GPS), "\n")
cat("Number of CGIAR project locations:", nrow(Innov_GPS), "\n")

# Section 3: Mapping ------------------------------------------------------

# Load and prepare administrative boundaries
Sys.setenv(SHAPE_RESTORE_SHX = "YES") # Fix for incomplete shapefiles
zones <- st_read(file.path(dashboard_dir, "Zones_Level_2.shp"))
st_crs(zones) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

# Create Figure 5 - Project locations by core domain
Figure5 <- ggplot() + 
  geom_sf(data = zones, fill = "grey92", color = "white", size = 0.3) +
  geom_point(data = Innov_GPS, aes(x = x_c, y = y_c), size = 0.2, color = 'darkcyan') +
  ggtitle('') +
  facet_wrap(~ CGcore, ncol = 3) +
  theme_minimal() +
  theme(
    axis.text = element_text(size = 8),
    strip.text = element_text(size = 10),
    plot.title = element_text(size = 12)
  ) +
  labs(x = "", y = "")

print(Figure5)

# Define your title
fig_title <- "figure5"

# Save using the cleaned title
ggsave(
  filename = file.path("outputs", "figures", paste0(fig_title, ".png")),
  plot = Figure5,
  width = 8, height = 6, dpi = 300
)


# Section 4: Calculate distances for each innovation ----------------------

# A/ Poultry crossbred
Innov_Chickens <- Innov_GPS[Innov_GPS$CGinovation == 'Poultry crossbred', 1:9]
coordinates(Innov_Chickens) <- ~ x_c + y_c
knn_result <- FNN::get.knnx(data = coordinates(Innov_Chickens), query = coordinates(ESS_GPS), k = nrow(Innov_Chickens))
Innov_Chickens <- data.frame(
  nn.idx.1 = knn_result$nn.index[, 1],
  nn.dists.1 = knn_result$nn.dist[, 1]
)

# Calculate proximity counts
dist_data_chickens <- knn_result$nn.dist
Innov_Chickens$N_20_CG_chicken <- rowSums(dist_data_chickens <= 0.180)   # 20 km
Innov_Chickens$N_50_CG_chicken <- rowSums(dist_data_chickens <= 0.452)   # 50 km  
Innov_Chickens$N_100_CG_chicken <- rowSums(dist_data_chickens <= 0.904)  # 100 km

# Keep relevant columns and convert distance to km
Innov_Chickens <- Innov_Chickens[names(Innov_Chickens) %in% c('nn.idx.1','nn.dists.1', 'N_20_CG_chicken','N_50_CG_chicken', 'N_100_CG_chicken')]
names(Innov_Chickens)[2] <- "Dist_CG_chicken"
Innov_Chickens$Dist_CG_chicken <- Innov_Chickens$Dist_CG_chicken * 110.56
ESS_Chickens <- cbind(ESS_GPS_ori, Innov_Chickens)

# Apply zone-level interventions
ESS_Chickens$Dist_CG_chicken[ESS_Chickens$saq02a %in% c('Gamo Gofa', 'Sidama', 'Jimma', 'Misrak Shewa', 'Mirab Gojjam', 'Semen Gonder', 'Mehakelawi')] <- 0

# B/ Large ruminants crossbred
Innov_LargeR <- Innov_GPS[Innov_GPS$CGinovation == 'Large ruminants crossbred', 1:9]
coordinates(Innov_LargeR) <- ~ x_c + y_c
knn_result <- FNN::get.knnx(data = coordinates(Innov_LargeR), query = coordinates(ESS_GPS), k = nrow(Innov_LargeR))
Innov_LargeR <- data.frame(
  nn.idx.1 = knn_result$nn.index[, 1],
  nn.dists.1 = knn_result$nn.dist[, 1]
)

# Calculate proximity counts
dist_data_largeR <- knn_result$nn.dist
Innov_LargeR$N_20_CG_LargeR <- rowSums(dist_data_largeR <= 0.180)
Innov_LargeR$N_50_CG_LargeR <- rowSums(dist_data_largeR <= 0.452)
Innov_LargeR$N_100_CG_LargeR <- rowSums(dist_data_largeR <= 0.904)

# Keep relevant columns and convert distance to km
Innov_LargeR <- Innov_LargeR[names(Innov_LargeR) %in% c('nn.idx.1','nn.dists.1', 'N_20_CG_LargeR','N_50_CG_LargeR', 'N_100_CG_LargeR')]
names(Innov_LargeR)[2] <- "Dist_CG_LargeR"
Innov_LargeR$Dist_CG_LargeR <- Innov_LargeR$Dist_CG_LargeR * 110.56
ESS_LargeR <- cbind(ESS_GPS_ori, Innov_LargeR)

# Apply zone-level interventions
ESS_LargeR$Dist_CG_LargeR[ESS_LargeR$saq02a %in% c('Sidama', 'Mehakelawi', 'Misrakawi', 'Mirab Gojjam', 'Semen Gonder', 'Debub Wello', 'Mirab Shewa', 'Misrak Shewa')] <- 0

# C/ Small ruminants crossbred
Innov_SmallR <- Innov_GPS[Innov_GPS$CGinovation == 'Small ruminants crossbred', 1:9]
coordinates(Innov_SmallR) <- ~ x_c + y_c
knn_result <- FNN::get.knnx(data = coordinates(Innov_SmallR), query = coordinates(ESS_GPS), k = nrow(Innov_SmallR))
Innov_SmallR <- data.frame(
  nn.idx.1 = knn_result$nn.index[, 1],
  nn.dists.1 = knn_result$nn.dist[, 1]
)

# Calculate proximity counts
dist_data_smallR <- knn_result$nn.dist
Innov_SmallR$N_20_CG_SmallR <- rowSums(dist_data_smallR <= 0.180)
Innov_SmallR$N_50_CG_SmallR <- rowSums(dist_data_smallR <= 0.452)
Innov_SmallR$N_100_CG_SmallR <- rowSums(dist_data_smallR <= 0.904)

# Keep relevant columns and convert distance to km
Innov_SmallR <- Innov_SmallR[names(Innov_SmallR) %in% c('nn.idx.1','nn.dists.1', 'N_20_CG_SmallR','N_50_CG_SmallR', 'N_100_CG_SmallR')]
names(Innov_SmallR)[2] <- "Dist_CG_SmallR"
Innov_SmallR$Dist_CG_SmallR <- Innov_SmallR$Dist_CG_SmallR * 110.56
ESS_SmallR <- cbind(ESS_GPS_ori, Innov_SmallR)

# Apply zone-level interventions
ESS_SmallR$Dist_CG_SmallR[ESS_SmallR$saq02a %in% c('Gamo Gofa', 'Sidama', 'Jimma', 'Misrakawi', 'Debub Wello', 'Mirab Shewa')] <- 0

# D/ Avocado trees
Innov_Avocado <- Innov_GPS[Innov_GPS$CGinovation == 'Avocado trees', 1:9]
coordinates(Innov_Avocado) <- ~ x_c + y_c
knn_result <- FNN::get.knnx(data = coordinates(Innov_Avocado), query = coordinates(ESS_GPS), k = nrow(Innov_Avocado))
Innov_Avocado <- data.frame(
  nn.idx.1 = knn_result$nn.index[, 1],
  nn.dists.1 = knn_result$nn.dist[, 1]
)

# Calculate proximity counts
dist_data_avocado <- knn_result$nn.dist
Innov_Avocado$N_20_CG_Avocado <- rowSums(dist_data_avocado <= 0.180)
Innov_Avocado$N_50_CG_Avocado <- rowSums(dist_data_avocado <= 0.452)
Innov_Avocado$N_100_CG_Avocado <- rowSums(dist_data_avocado <= 0.904)

# Keep relevant columns and convert distance to km
Innov_Avocado <- Innov_Avocado[names(Innov_Avocado) %in% c('nn.idx.1','nn.dists.1', 'N_20_CG_Avocado','N_50_CG_Avocado', 'N_100_CG_Avocado')]
names(Innov_Avocado)[2] <- "Dist_CG_Avocado"
Innov_Avocado$Dist_CG_Avocado <- Innov_Avocado$Dist_CG_Avocado * 110.56
ESS_Avocado <- cbind(ESS_GPS_ori, Innov_Avocado)

# Apply zone-level interventions
ESS_Avocado$Dist_CG_Avocado[ESS_Avocado$saq02a == 'Jimma'] <- 0

# E/ DTMZ varieties
Innov_DTMZ <- Innov_GPS[Innov_GPS$CGinovation == 'DTMZ varieties', 1:9]
coordinates(Innov_DTMZ) <- ~ x_c + y_c
knn_result <- FNN::get.knnx(data = coordinates(Innov_DTMZ), query = coordinates(ESS_GPS), k = nrow(Innov_DTMZ))
Innov_DTMZ <- data.frame(
  nn.idx.1 = knn_result$nn.index[, 1],
  nn.dists.1 = knn_result$nn.dist[, 1]
)

# Calculate proximity counts
dist_data_DTMZ <- knn_result$nn.dist
Innov_DTMZ$N_20_CG_DTMZ <- rowSums(dist_data_DTMZ <= 0.180)
Innov_DTMZ$N_50_CG_DTMZ <- rowSums(dist_data_DTMZ <= 0.452)
Innov_DTMZ$N_100_CG_DTMZ <- rowSums(dist_data_DTMZ <= 0.904)

# Keep relevant columns and convert distance to km
Innov_DTMZ <- Innov_DTMZ[names(Innov_DTMZ) %in% c('nn.idx.1','nn.dists.1', 'N_20_CG_DTMZ','N_50_CG_DTMZ', 'N_100_CG_DTMZ')]
names(Innov_DTMZ)[2] <- "Dist_CG_DTMZ"
Innov_DTMZ$Dist_CG_DTMZ <- Innov_DTMZ$Dist_CG_DTMZ * 110.56
ESS_DTMZ <- cbind(ESS_GPS_ori, Innov_DTMZ)

# F/ Conservation Agriculture
Innov_CA <- Innov_GPS[Innov_GPS$CGinovation == 'Conservation Agriculture', 1:9]
coordinates(Innov_CA) <- ~ x_c + y_c
knn_result <- FNN::get.knnx(data = coordinates(Innov_CA), query = coordinates(ESS_GPS), k = nrow(Innov_CA))
Innov_CA <- data.frame(
  nn.idx.1 = knn_result$nn.index[, 1],
  nn.dists.1 = knn_result$nn.dist[, 1]
)

# Calculate proximity counts
dist_data_CA <- knn_result$nn.dist
Innov_CA$N_20_CG_CA <- rowSums(dist_data_CA <= 0.180)
Innov_CA$N_50_CG_CA <- rowSums(dist_data_CA <= 0.452)
Innov_CA$N_100_CG_CA <- rowSums(dist_data_CA <= 0.904)

# Keep relevant columns and convert distance to km
Innov_CA <- Innov_CA[names(Innov_CA) %in% c('nn.idx.1','nn.dists.1', 'N_20_CG_CA','N_50_CG_CA', 'N_100_CG_CA')]
names(Innov_CA)[2] <- "Dist_CG_CA"
Innov_CA$Dist_CG_CA <- Innov_CA$Dist_CG_CA * 110.56
ESS_CA <- cbind(ESS_GPS_ori, Innov_CA)

# G/ OFSP
Innov_OFSP <- Innov_GPS[Innov_GPS$CGinovation == 'OFSP', 1:9]
coordinates(Innov_OFSP) <- ~ x_c + y_c
knn_result <- FNN::get.knnx(data = coordinates(Innov_OFSP), query = coordinates(ESS_GPS), k = nrow(Innov_OFSP))
Innov_OFSP <- data.frame(
  nn.idx.1 = knn_result$nn.index[, 1],
  nn.dists.1 = knn_result$nn.dist[, 1]
)

# Calculate proximity counts
dist_data_OFSP <- knn_result$nn.dist
Innov_OFSP$N_20_CG_OFSP <- rowSums(dist_data_OFSP <= 0.180)
Innov_OFSP$N_50_CG_OFSP <- rowSums(dist_data_OFSP <= 0.452)
Innov_OFSP$N_100_CG_OFSP <- rowSums(dist_data_OFSP <= 0.904)

# Keep relevant columns and convert distance to km
Innov_OFSP <- Innov_OFSP[names(Innov_OFSP) %in% c('nn.idx.1','nn.dists.1', 'N_20_CG_OFSP','N_50_CG_OFSP', 'N_100_CG_OFSP')]
names(Innov_OFSP)[2] <- "Dist_CG_OFSP"
Innov_OFSP$Dist_CG_OFSP <- Innov_OFSP$Dist_CG_OFSP * 110.56
ESS_OFSP <- cbind(ESS_GPS_ori, Innov_OFSP)

# H/ NuME varieties
Innov_NUME <- Innov_GPS[Innov_GPS$CGinovation == 'NuME varieties', 1:9]
coordinates(Innov_NUME) <- ~ x_c + y_c
knn_result <- FNN::get.knnx(data = coordinates(Innov_NUME), query = coordinates(ESS_GPS), k = nrow(Innov_NUME))
Innov_NUME <- data.frame(
  nn.idx.1 = knn_result$nn.index[, 1],
  nn.dists.1 = knn_result$nn.dist[, 1]
)

# Calculate proximity counts
dist_data_NUME <- knn_result$nn.dist
Innov_NUME$N_20_CG_NUME <- rowSums(dist_data_NUME <= 0.180)
Innov_NUME$N_50_CG_NUME <- rowSums(dist_data_NUME <= 0.452)
Innov_NUME$N_100_CG_NUME <- rowSums(dist_data_NUME <= 0.904)

# Keep relevant columns and convert distance to km
Innov_NUME <- Innov_NUME[names(Innov_NUME) %in% c('nn.idx.1','nn.dists.1', 'N_20_CG_NUME','N_50_CG_NUME', 'N_100_CG_NUME')]
names(Innov_NUME)[2] <- "Dist_CG_NUME"
Innov_NUME$Dist_CG_NUME <- Innov_NUME$Dist_CG_NUME * 110.56
ESS_NUME <- cbind(ESS_GPS_ori, Innov_NUME)

# I/ Watershed SLM
Innov_SLM <- Innov_GPS[Innov_GPS$CGinovation == 'Watershed SLM', 1:9]
coordinates(Innov_SLM) <- ~ x_c + y_c
knn_result <- FNN::get.knnx(data = coordinates(Innov_SLM), query = coordinates(ESS_GPS), k = nrow(Innov_SLM))
Innov_SLM <- data.frame(
  nn.idx.1 = knn_result$nn.index[, 1],
  nn.dists.1 = knn_result$nn.dist[, 1]
)

# Calculate proximity counts
dist_data_SLM <- knn_result$nn.dist
Innov_SLM$N_20_CG_SLM <- rowSums(dist_data_SLM <= 0.180)
Innov_SLM$N_50_CG_SLM <- rowSums(dist_data_SLM <= 0.452)
Innov_SLM$N_100_CG_SLM <- rowSums(dist_data_SLM <= 0.904)

# Keep relevant columns and convert distance to km
Innov_SLM <- Innov_SLM[names(Innov_SLM) %in% c('nn.idx.1','nn.dists.1', 'N_20_CG_SLM','N_50_CG_SLM', 'N_100_CG_SLM')]
names(Innov_SLM)[2] <- "Dist_CG_SLM"
Innov_SLM$Dist_CG_SLM <- Innov_SLM$Dist_CG_SLM * 110.56
ESS_SLM <- cbind(ESS_GPS_ori, Innov_SLM)

# J/ Improved sorghum varieties

Innov_Sorghum <- Innov_GPS[Innov_GPS$CGinovation == 'Improved sorghum varieties', 1:9]
coordinates(Innov_Sorghum) <- ~ x_c + y_c
knn_result <- FNN::get.knnx(data = coordinates(Innov_Sorghum), query = coordinates(ESS_GPS), k = nrow(Innov_Sorghum))
Innov_Sorghum <- data.frame(
  nn.idx.1 = knn_result$nn.index[, 1],
  nn.dists.1 = knn_result$nn.dist[, 1]
)

# Calculate proximity counts
dist_data_Sorghum <- knn_result$nn.dist
Innov_Sorghum$N_20_CG_Sorghum <- rowSums(dist_data_Sorghum <= 0.180)
Innov_Sorghum$N_50_CG_Sorghum <- rowSums(dist_data_Sorghum <= 0.452)
Innov_Sorghum$N_100_CG_Sorghum <- rowSums(dist_data_Sorghum <= 0.904)

# Keep relevant columns and convert distance to km
Innov_Sorghum <- Innov_Sorghum[names(Innov_Sorghum) %in% c('nn.idx.1','nn.dists.1', 'N_20_CG_Sorghum','N_50_CG_Sorghum', 'N_100_CG_Sorghum')]
names(Innov_Sorghum)[2] <- "Dist_CG_Sorghum"
Innov_Sorghum$Dist_CG_Sorghum <- Innov_Sorghum$Dist_CG_Sorghum * 110.56
ESS_Sorghum <- cbind(ESS_GPS_ori, Innov_Sorghum)

# K/ PPP for barley seed dissemination
Innov_Barley <- Innov_GPS[Innov_GPS$CGinovation == 'PPP for barley seed dissemination', 1:9]
coordinates(Innov_Barley) <- ~ x_c + y_c
knn_result <- FNN::get.knnx(data = coordinates(Innov_Barley), query = coordinates(ESS_GPS), k = nrow(Innov_Barley))
Innov_Barley <- data.frame(
  nn.idx.1 = knn_result$nn.index[, 1],
  nn.dists.1 = knn_result$nn.dist[, 1]
)

# Calculate proximity counts
dist_data_Barley <- knn_result$nn.dist
Innov_Barley$N_20_CG_Barley <- rowSums(dist_data_Barley <= 0.180)
Innov_Barley$N_50_CG_Barley <- rowSums(dist_data_Barley <= 0.452)
Innov_Barley$N_100_CG_Barley <- rowSums(dist_data_Barley <= 0.904)

# Keep relevant columns and convert distance to km
Innov_Barley <- Innov_Barley[names(Innov_Barley) %in% c('nn.idx.1','nn.dists.1', 'N_20_CG_Barley','N_50_CG_Barley', 'N_100_CG_Barley')]
names(Innov_Barley)[2] <- "Dist_CG_Barley"
Innov_Barley$Dist_CG_Barley <- Innov_Barley$Dist_CG_Barley * 110.56
ESS_Barley <- cbind(ESS_GPS_ori, Innov_Barley)

# create the final dataset using column names 
ESS.Distances <- ESS_GPS_ori

# add each innovation's data by name 
ESS.Distances <- cbind(ESS.Distances, 
                       ESS_LargeR[, grep("Dist_CG_LargeR|N_.*_CG_LargeR", names(ESS_LargeR))],
                       ESS_SmallR[, grep("Dist_CG_SmallR|N_.*_CG_SmallR", names(ESS_SmallR))],
                       ESS_Chickens[, grep("Dist_CG_chicken|N_.*_CG_chicken", names(ESS_Chickens))],
                       ESS_Avocado[, grep("Dist_CG_Avocado|N_.*_CG_Avocado", names(ESS_Avocado))],
                       ESS_DTMZ[, grep("Dist_CG_DTMZ|N_.*_CG_DTMZ", names(ESS_DTMZ))],
                       ESS_CA[, grep("Dist_CG_CA|N_.*_CG_CA", names(ESS_CA))],
                       ESS_OFSP[, grep("Dist_CG_OFSP|N_.*_CG_OFSP", names(ESS_OFSP))],
                       ESS_NUME[, grep("Dist_CG_NUME|N_.*_CG_NUME", names(ESS_NUME))],
                       ESS_SLM[, grep("Dist_CG_SLM|N_.*_CG_SLM", names(ESS_SLM))],
                       ESS_Barley[, grep("Dist_CG_Barley|N_.*_CG_Barley", names(ESS_Barley))],
                       ESS_Sorghum[, grep("Dist_CG_Sorghum|N_.*_CG_Sorghum", names(ESS_Sorghum))])
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
write.csv(ESS.Distances, file.path('data', 'report_data', 'ESS.distances.csv'))


# Figure 6: Map of enumeration areas with at least one household adopter of poultry crossbred in 2015/16 (orange) and 2018/19 (blue) ----
sect3_pp_w4 <- read_dta ("data/raw_data/ESS4_2018-19/Data/PP/sect3_pp_w4.dta")

sect3_pp_w4 <- sect3_pp_w4[!duplicated(sect3_pp_w4$ea_id), ] 
sect3_pp_w4 <- sect3_pp_w4 [, c(1,5)]
GPS1 <- read.dta13 ('data/raw_data/ESS4_2018-19/Data/PP/Version 1 Fieldroster_anonymized.dta')
GPS2 <- read.dta13 ('data/raw_data/ESS4_2018-19/Data/PP/Version 2 Fieldroster_anonymized.dta') 
GPS3 <- read.dta13 ('data/raw_data/ESS4_2018-19/Data/PP/Version 3 Fieldroster_anonymized.dta') 

GPS <- rbind (GPS1, GPS2, GPS3); rm (GPS1, GPS2, GPS3)
GPS <- GPS [, c(1,17,197,198)]

GPS <- merge (sect3_pp_w4, GPS, all.x=TRUE); GPS <- GPS[!is.na (GPS$s3q09__Latitude__anonymized), ]; GPS <- GPS[!duplicated(GPS$ea_id), ] 
GPS$ea_id <- as.numeric(GPS$ea_id)

# Note: replace the 10 lines above by ESS4 EA-level GPS coordinates once released

Maps_4 <- read.csv ("data/raw_data/Auxiliary_data/ESS4_ea level_MAPS.csv") 
Maps_4 <- merge (Maps_4, GPS, all.x=TRUE); #Maps_4 <- Maps_4[!duplicated(Maps_4$ea_id), ] 

# Get ESS3 GPS coordinates
Maps_3 <- read.csv ("data/raw_data/Auxiliary_data/ESS3_ea level_MAPS.csv") 
HouseholdGeovars_Y2 <- read_dta("data/raw_data/ESS2_2013-14/Data/STATA/Pub_ETH_HouseholdGeovars_Y2.dta")
HouseholdGeovars_Y2 <- HouseholdGeovars_Y2 [, c(3,44,45)]
HouseholdGeovars_Y2$ea_id <- as.numeric(HouseholdGeovars_Y2$ea_id)
HouseholdGeovars_Y2 <- HouseholdGeovars_Y2[!duplicated(HouseholdGeovars_Y2$ea_id), ] 

Maps_3 <- merge (HouseholdGeovars_Y2, Maps_3, all.y=TRUE)

zones <- st_read("data/raw_data/Dashboard locations/Zones_Level_2.shp")
zones <- st_set_crs(zones, 4326)   # EPSG:4326 is WGS84

Fig6 <- ggplot() +
  geom_sf(data = zones, colour = "black", fill = NA) +
  geom_point(data = Maps_4[!is.na(Maps_4$sh_ea_poultry_k), ],
             aes(x = s3q09__Longitude__anonymized, y = s3q09__Latitude__anonymized),
             size = 1.8, color = '#4E84C4') +
  geom_point(data = Maps_3[!is.na(Maps_3$sh_ea_poultry), ],
             aes(x = lon_dd_mod, y = lat_dd_mod),
             size = 1.8, color = '#D16103') +
  xlab(" ") + ylab(" ")

# Figure 7: Map of enumeration areas with at least one adopter of HB-1966 barley variety ----
data <- read.csv('data/raw_data/Auxiliary_data/DNA_data_reports.csv') # Sorghum ID, Purity, DNA
cc <- read_dta("data/raw_data/ESS4_2018-19/Data/PP/Croproster_12.02.dta") # S4 + crop cut data
cc <- cc [cc$s4q01b == 1 ,] 

cc$sccq05 [cc$sccq05 %in% c('##N/A##', '')] <- NA
cc$sccq05 [cc$sccq05 %in% c('##N/A##', '')] <- NA
cc$sccq05 [cc$sccq05 == 52108921] <- 1215
cc$sccq05 [cc$sccq05 == 11919186] <- 2577
cc$sccq05 <- as.numeric(cc$sccq05)
data <- merge (data, cc, by.x='ID', by.y='sccq05', all.x=TRUE) # Croproster_12.02.dta / DNA are merged


# Geographic distribution of samples 
GPS1 <- read.dta13 ('data/raw_data/ESS4_2018-19/Data/PP/Version 1 Fieldroster_anonymized.dta')
GPS2 <- read.dta13 ('data/raw_data/ESS4_2018-19/Data/PP/Version 2 Fieldroster_anonymized.dta') 
GPS3 <- read.dta13 ('data/raw_data/ESS4_2018-19/Data/PP/Version 3 Fieldroster_anonymized.dta') 

GPS <- rbind (GPS1, GPS2, GPS3); rm (GPS1, GPS2, GPS3)

data$Field_ID <- paste (data$interview__id, data$Parcelroster__id, data$Fieldroster__id, sep='.', collapse=NULL)
GPS$Field_ID <- paste (GPS$interview__id, GPS$Parcelroster__id, GPS$Fieldroster__id, sep='.', collapse=NULL)
data <- merge (data, GPS, by='Field_ID', all.x=TRUE) 
# Note: replace the 10 lines above by ESS4 EA-level GPS coordinates

table (data$s3q09__Latitude__anonymized) # 
table (data$s3q09__Longitude__anonymized)

# Maps per variety

zones <- st_read("data/raw_data/Dashboard locations/Zones_Level_2.shp")

zones_df <- zones %>%
  st_coordinates() %>%
  as.data.frame() %>%
  rename(long = X, lat = Y) %>%
  mutate(group = paste(L2, L1, sep = "."))  # This creates unique groups per polygon

# Your plotting code remains the same
data.HB <- data[data$subbinReferences == 'RL:HB-1966_B', ]
Fig7 <- ggplot() +
  geom_sf(data = zones, colour = "black", fill = NA) +
  geom_point(data = data.HB, aes(x = s3q09__Longitude__anonymized, y = s3q09__Latitude__anonymized), 
             size = 1.5, color = 'blue') +
  xlab(' ') + ylab(' ') +  
  theme_minimal()  

# Define your title
fig_title <- "figure7"

# Save using the cleaned title
ggsave(
  filename = file.path("outputs", "figures", paste0(fig_title, ".png")),
  plot = Fig7,
  width = 8, height = 6, dpi = 300
)

# Figure 8: Adoption of improved maize varieties in Ethiopia, 2019 ----
data <- read.csv('data/raw_data/Auxiliary_data/DNA_data_reports.csv') # Sorghum ID, Purity, DNA
cc <- read_dta("data/raw_data/ESS4_2018-19/Data/PP/Croproster_12.02.dta")  # S4 + crop cut data
cc <- cc [cc$s4q01b == 2 ,] 

cc$sccq05 [cc$sccq05 %in% c('##N/A##', '')] <- NA
cc$sccq05 [cc$sccq05 %in% c('##N/A##', '')] <- NA
cc$sccq05 [cc$sccq05 == 52108921] <- 1215
cc$sccq05 [cc$sccq05 == 11919186] <- 2577
cc$sccq05 <- as.numeric(cc$sccq05)
data <- merge (data, cc, by.x='ID', by.y='sccq05', all.x=TRUE) 

# Geographic distribution of samples 
GPS1 <- read.dta13 ('data/raw_data/ESS4_2018-19/Data/PP/Version 1 Fieldroster_anonymized.dta')
GPS2 <- read.dta13 ('data/raw_data/ESS4_2018-19/Data/PP/Version 2 Fieldroster_anonymized.dta') 
GPS3 <- read.dta13 ('data/raw_data/ESS4_2018-19/Data/PP/Version 3 Fieldroster_anonymized.dta') 

GPS <- rbind (GPS1, GPS2, GPS3); rm (GPS1, GPS2, GPS3)
data$Field_ID <- paste (data$interview__id, data$Parcelroster__id, data$Fieldroster__id, sep='.', collapse=NULL)
GPS$Field_ID <- paste (GPS$interview__id, GPS$Parcelroster__id, GPS$Fieldroster__id, sep='.', collapse=NULL)
data <- merge (data, GPS, by='Field_ID', all.x=TRUE) 
# Note: replace the 10 lines above by ESS4 EA-level GPS coordinates once released

table (data$s3q09__Latitude__anonymized) # 
table (data$s3q09__Longitude__anonymized)

# Maps per variety
# Read shapefile with sf (replaces readShapePoly and CRS)
zones <- st_read("data/raw_data/Dashboard locations/Zones_Level_2.shp")

data$subbinReferences <- as.character(data$subbinReferences)

# DTMZ, non DTMZ and both
data$CG_Stats.DTMZ <- ifelse (data$subbinReferences %in% c('RM0472017', 'RM0292017'), 1, 0)
data$CG_Stats.nonDTMZ <- ifelse (data$subbinReferences %in% c('BH-140', 'RM0262017','RM0512017', 'KULANI', 'RM0042017', 'RM0482017', 'GIBE1', 'RM0012017', 'RM0022017', 'RM0062017'), 1, 0)

ea_DTMZ <- aggregate (CG_Stats.DTMZ ~ saq03b, data, sum)
ea_nonDTMZ <- aggregate (CG_Stats.nonDTMZ ~ saq03b, data, sum)
ea <- cbind (ea_DTMZ, ea_nonDTMZ); ea <- ea [, -3]

ea$Both <- ifelse (ea$CG_Stats.DTMZ > 0 & ea$CG_Stats.nonDTMZ > 0, 1, 0)

ea$CG_Stats.DTMZ <- ifelse (ea$Both > 0, 0, ea$CG_Stats.DTMZ)
ea$CG_Stats.nonDTMZ <- ifelse (ea$Both > 0, 0, ea$CG_Stats.nonDTMZ)

merge <- data [, names(data) %in% c('saq03b', 's3q09__Latitude__anonymized', 's3q09__Longitude__anonymized')]
ea <- merge (ea, merge, all.y=TRUE)
ea <- ea[!duplicated(ea$saq03b), ]

Fig8 <- ggplot() + 
  geom_sf(data = zones, colour = "black", fill = NA) +
  geom_point(data = ea[ea$CG_Stats.DTMZ > 0, ], 
             aes(x = s3q09__Longitude__anonymized, y = s3q09__Latitude__anonymized), 
             size = 1.5, color = 'darkgoldenrod1') +
  geom_point(data = ea[ea$CG_Stats.nonDTMZ > 0, ], 
             aes(x = s3q09__Longitude__anonymized, y = s3q09__Latitude__anonymized), 
             size = 1.5, color = 'royalblue2') + 
  geom_point(data = ea[ea$Both > 0, ], 
             aes(x = s3q09__Longitude__anonymized, y = s3q09__Latitude__anonymized), 
             size = 1.5, color = 'chartreuse3') +
  xlab(' ') + ylab(' ') +
  theme_minimal()

# Define your title
fig_title <- "figure8"

# Save using the cleaned title
ggsave(
  filename = file.path("outputs", "figures", paste0(fig_title, ".png")),
  plot = Fig8,
  width = 8, height = 6, dpi = 300
)
