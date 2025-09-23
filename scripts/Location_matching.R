
# ---
# Title: "Matching ESS EAs to the closest location of CGIAR research activities per innovation"
# Author email: "f.kosmowski@cgiar.org"
# Date: "June 2020"
# last editted by M.Kirinyet@cgiar.org on 23/09/2025
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

required_packages(c("readxl", "haven", "dplyr", "sp", "FNN", "ggplot2", "sf", "nabor", "class"))

# Set file paths
data_dir <- "data"
raw_data_dir <- file.path(data_dir, "raw_data")
processed_data_dir <- file.path(data_dir, "processed")
dashboard_dir <- file.path(raw_data_dir, "Dashboard locations")
ess3_dir <- file.path(raw_data_dir, "ESS3_2015-16", "Data", "STATA")
ess4_dir <- file.path(raw_data_dir, "ESS4_2018-19", "Data", "HH")

# Create processed directory if it doesn't exist
if (!dir.exists(processed_data_dir)) {
  dir.create(processed_data_dir, recursive = TRUE)
}

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

# Create unique EA coordinates (script works at EA level)
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
  ggtitle('Figure 5: Location of CGIAR projects in Ethiopia by core domain, 1999-2019') +
  facet_wrap(~ CGcore, ncol = 3) +
  theme_minimal() +
  theme(
    axis.text = element_text(size = 8),
    strip.text = element_text(size = 10),
    plot.title = element_text(size = 12)
  ) +
  labs(x = "", y = "")

print(Figure5)

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
write.csv(ESS.Distances, file.path('data', 'processed', 'ESS.distances.csv'))





#############           TBC