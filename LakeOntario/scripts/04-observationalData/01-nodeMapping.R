# TODO 
# [x] Add distance from node to observation
# [ ] Add area for EFDC grid

library(tidyverse)
library(ncdf4)
source("GLENDA.R")

realDatadir <- "../../realData/"

#%% GLENDA
glenda <- .readPivotGLENDA(paste0(realDatadir, "LOglenda.csv")) %>%
  filter(YEAR %in% c(2013, 2018), ANALYTE %in% c("Temperature", "Chlorophyll-a", "Phosphorus, Total as P")) %>%
  distinct(siteID = STATION_ID, lat = LATITUDE, lng = LONGITUDE, siteDepth = STN_DEPTH_M) %>%
  # 20% sample Depths missing, everything else nonmissing
  drop_na() %>%
  mutate(source = "glenda", type = "ctd")

#%% CSMI
csmi <- readxl::read_xlsx(paste0(realDatadir, "L2_SampleEvent.xlsx")) %>%
  distinct(siteID = StationCodeFK, lat = LatitudeDD, lng= LongitudeDD, siteDepth = SiteDepth) %>%
  mutate(source = "csmi", type = "ctd")


bouy <- read_table(paste0(realDatadir, "bouys/bouyCoords.tsv"), skip = 1) %>%
  mutate(siteID = str_remove(filename, "h.*\\.txt$")) %>%
  distinct(siteID, lat, lng=lon, siteDepth = depth) %>%
  mutate(source = "bouy", type = "bouy")

sites <- bind_rows(glenda, csmi, bouy) %>%
  reframe(.by = c(siteID, type, source) , across(c("lat", "lng", "siteDepth"), function(x) mean(x, na.rm = T)))

# match nodes to real data
# Select nodes closest to bouys or chem sites
data <- ncdf4::nc_open("../../output/runs/gridData.nc")
fvcom <- data.frame(
  "nodeDepth" = ncdf4::ncvar_get(data, "h"),
  "lng" = ncdf4::ncvar_get(data, "lon"),
  "lat" = ncdf4::ncvar_get(data, "lat"),
  "area" = ncdf4::ncvar_get(data, "art1")
  ) %>%
  mutate(
    node = 1:nrow(.),
    lng = lng -360,
    )
nc_close(data)

efdc <- read_table("/work/GLFBREEZ/Lake_Ontario/LatLon.txt") %>%
  mutate(node = seq_len(nrow(.))) %>%
  select(node, lat, lng = lon)


sites$node.fvcom <- NA
sites$node.efdc <- NA
sites$dist.fvcom <- NA
sites$dist.efdc <- NA
sites$area <- NA
sites$depth <- NA
sites$lat.fvcom <- NA
sites$lat.efdc <- NA
sites$lng.fvcom <- NA
sites$lng.efdc <- NA
# to develop only looked at some of them
for (loc in seq_len(nrow(sites))) {
  cat(paste0(round(loc / nrow(sites) * 100), '% completed \014'))
  if (loc == nrow(sites)) cat(': Done') else cat('\014')
  fvcomDist <- sqrt(rowSums((sites[c("lat", "lng")][loc, ] - matrix(fvcom[c("lat", "lng")]))**2))
  fvcomNode <- which.min(fvcomDist)
  sites$node.fvcom[loc] <- fvcomNode
  sites$dist.fvcom[loc] <- min(fvcomDist)
  sites$lat.fvcom[loc] <- fvcom$lat[fvcomNode]
  sites$lng.fvcom[loc] <- fvcom$lng[fvcomNode]
  sites$area[loc] <- fvcom$area[fvcomNode]
  sites$depth[loc] <- fvcom$nodeDepth[fvcomNode]

  efdcDist <- rowSums(sqrt((sites[c("lat", "lng")][loc, ] - matrix(efdc[c("lat", "lng")]))**2))
  efdcNode <- which.min(efdcDist)
  sites$node.efdc[loc] <- efdcNode
  sites$dist.efdc[loc] <- min(efdcDist)
  sites$lat.efdc[loc] <- efdc$lat[efdcNode]
  sites$lng.efdc[loc] <- efdc$lng[efdcNode]
}

# pivot longer to project onto plane
sites <- sites %>%
  rename(lat.real = lat, lng.real=  lng) %>%
  pivot_longer(
    c(starts_with("lat"), starts_with("lng"), starts_with("node"), 
    starts_with("dist")),
    names_to = c(".value", "Model"),
    names_pattern = "(.*)\\.(.*)$"
  ) %>%
  drop_na(lat,lng) %>%
  mutate(
    dist = ifelse(is.na(dist) & (Model == "real"), 0, dist),
    node = ifelse(is.na(node) & (Model == "real"), 0, node),
  )


df_sf <- sites  %>% sf::st_as_sf(coords = c("lat", "lng"), crs=  4326)
# this was suggested by Jon to cover the full great lakes making it easier to generalize
df_sf_proj <- sf::st_transform(df_sf, crs = "EPSG:3174")


projected <- as.data.frame(df_sf_proj$geometry) %>%
  mutate(
    geometry = str_remove(geometry, "POINT \\("),
    geometry = str_remove(geometry, "c\\("),
    geometry = str_remove(geometry, "\\)"),
  ) %>%
  separate(geometry, into = c("x", "y"), sep = ", ") %>%
  mutate(across(everything(), function(z) as.numeric(z) / 1000)) %>%
  # x and y are in km
  select(x, y)

test <- cbind(sites, projected) %>%
  pivot_wider(id_cols = c(siteID, siteDepth, area, depth, type, source), names_from = Model, values_from = c(lat, lng, node, dist, x, y)) %>%
  select(-c(dist_real, node_real))
saveRDS(test, paste0(realDatadir, "nodeMap.Rds"))
       
