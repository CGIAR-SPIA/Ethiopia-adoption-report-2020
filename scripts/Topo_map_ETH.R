# Function to check and install packages if needed
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) {
    install.packages(new_packages, dependencies = TRUE)
  }
  invisible(sapply(packages, library, character.only = TRUE))
}

# List of required packages
required_packages <- c(
  "geodata",
  "rnaturalearth",
  "tidyverse",
  "sf",
  "terra",
  "ggspatial"
)

# Install and load packages
install_if_missing(required_packages)


# get country boundaries for Ethiopia
ethiopia <- ne_countries(country = "Ethiopia", returnclass = "sf")

# get topography data for Ethiopia using geodata
topo_eth <- elevation_30s(country = "ETH", path = tempdir())

# OPTIMIZATION: Aggregate the raster to reduce resolution and speed up rendering
topo_eth_agg <- aggregate(topo_eth, fact = 3, fun = mean)  # Reduce resolution by factor of 3

# Convert to data frame for ggplot
topo_eth_df <- as.data.frame(topo_eth_agg, xy = TRUE) %>% 
  na.omit() %>% 
  as_tibble() %>% 
  rename(alt = 3) %>%  # The elevation column
  mutate(alt = as.numeric(alt))

# Get regional boundaries for Ethiopia
reg_rename <- gadm(country = "ETH", level = 1, path = tempdir()) %>% 
  st_as_sf()

# Calculate region centroids for labels
region_centroids <- st_centroid(reg_rename) %>% 
  mutate(
    x = st_coordinates(.)[,1],
    y = st_coordinates(.)[,2],
    name = NAME_1  # Regional names
  )

# Create custom elevation categories with Amharic names
topo_eth_df <- topo_eth_df %>%
  mutate(
    elev_category = cut(alt, 
                        breaks = c(-Inf, 500, 1500, 2300, 3200, 3700, Inf),
                        labels = c("< 500 (Bereha)", 
                                   "500 - 1,500 (Kola)", 
                                   "1,501 - 2,300 (Woyna Dega)",
                                   "2,301 - 3,200 (Dega)",
                                   "3,201 - 3,700 (High Dega)",
                                   "> 3,701 (Wurch)"),
                        include.lowest = TRUE)
  )

# Define colors for elevation zones
elev_colors <- c(
  "< 500 (Bereha)" = "#DC143C",           # Dark red
  "500 - 1,500 (Kola)" = "#FA8072",       # Light coral
  "1,501 - 2,300 (Woyna Dega)" = "#F4A460", # Sandy brown
  "2,301 - 3,200 (Dega)" = "#F0E68C",     # Khaki
  "3,201 - 3,700 (High Dega)" = "#B0C4DE", # Light steel blue
  "> 3,701 (Wurch)" = "#4169E1"           # Royal blue
)

# Create ggplot topography map
topo_map_eth <- ggplot(topo_eth_df) +
  geom_tile(aes(x = x, y = y, fill = elev_category)) +  # Use geom_tile instead of geom_raster
  scale_fill_manual(
    values = elev_colors,
    name = "Elevation in m (Agroecological zone)",
    guide = guide_legend(
      title.position = "top",
      title.hjust = 0.5,
      reverse = TRUE
    )
  ) +
  geom_sf(data = reg_rename, fill = NA, color = "black", linewidth = 0.5) +
  geom_text(
    data = region_centroids, 
    aes(x, y, label = name),
    size = 4, color = "black", fontface = "bold"
  ) +
  annotation_scale(location = "bl", width_hint = 0.3, 
                   style = "ticks", line_width = 1) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    legend.position = "right",
    legend.key.height = unit(1, "cm"),
    legend.key.width = unit(0.6, "cm"),
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 9),
    #legend.background = element_rect(fill = "white", color = "black", linewidth = 0.5)
  ) +
  coord_sf()

# Display the map
print(topo_map_eth)
# Save the map
ggsave("outputs/figures/figure1.png", topo_map_eth, height = 6, width = 8, dpi = 400, bg = "white")