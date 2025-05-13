library(tidyverse)
library(ncdf4)


#bouys <- read_table("../../realData/bouys/bouyCoords.tsv", skip = 1)
fvcom <- nc_open("../../output/runs/2013/dolanHot_0001.nc")


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

