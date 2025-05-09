library(tidyverse)
library(ncdf4)


#bouys <- read_table("../../realData/bouys/bouyCoords.tsv", skip = 1)
fvcom <- nc_open("../../output/runs/fvcom_0001.nc")


#  neleCoords <- data.frame(
#    "lng" = ncvar_get(fvcom, "lon"),
#    "lat" = ncvar_get(fvcom, "lat")
#  ) %>%
#    mutate(lng = lng -360)
#  
#  
#  bouys$node.fvcom <- NA
#  bouys$dist.fvcom <- NA
#  bouys$lat.fvcom <- NA
#  bouys$lng.fvcom <- NA
#  for (loc in seq_len(nrow(bouys))) {
#    cat(paste0(round(loc / nrow(bouys) * 100), '% completed \014'))
#    if (loc == nrow(bouys)) cat(': Done') else cat('\014')
#    neleCoordsDist <- sqrt(rowSums((bouys[c("lat", "lon")][loc, ] - matrix(neleCoords[c("lat", "lng")]))**2))
#    neleCoordsNode <- which.min(neleCoordsDist)
#    bouys$node.fvcom[loc] <- neleCoordsNode
#    bouys$dist.fvcom[loc] <- min(neleCoordsDist)
#    bouys$lat.fvcom[loc] <- neleCoords$lat[neleCoordsNode]
#    bouys$lng.fvcom[loc] <- neleCoords$lng[neleCoordsNode]
#  }
#  
#  
#  saveRDS(bouys, "neleMatchedBouys.Rds")
bouys <- readRDS("neleMatchedBouys.Rds") %>%
  distinct() %>%
  filter(!grepl("2013", filename, ignore.case= T))

bouyData <- readRDS(paste0("../../realData/bouys/bouy.Rds")) %>%
  drop_na(wDir) %>% 
  left_join(bouys)

# nele = 28, siglay = 1-20, time=1-8016
vel <- data.frame(
  "u" = ncvar_get(fvcom, "u", start = c(28,1,1), count= c(1,1,8016)), 
  "v" = ncvar_get(fvcom, "v", start = c(28,1,1), count= c(1,1,8016)),
  "dateTime" = ymd_h("2018-01-01 00") + hours(seq_len(8016))
  ) %>%
  left_join(bouyData, by = c("dateTime")) %>%
  mutate(
    across(c(lat, lon, depth, sampleDepth, node.fvcom, dist.fvcom, lat.fvcom, lng.fvcom), function(x) mean(x, na.rm = T)),
    across(c(Station, filename), function(x) names(sort(table(x), decreasing=T))[1])
  )

saveRDS(vel, "neleMatchedBouys.Rds")

