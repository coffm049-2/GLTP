# TODO 
# [x] Add distance from node to observation
# [ ] Add area for EFDC grid

library(tidyverse)
library(ncdf4)
source("GLENDA.R")

realDatadir <- "../../realData/"

sites <- readRDS(paste0(realDatadir, "nodeMap.Rds")) %>%
  mutate(
    dist_fvcom = sqrt((lat_real - lat_fvcom)**2 + (lng_real - lng_fvcom)**2),
    dist_fvcom = sqrt((lat_real - lat_fvcom)**2 + (lng_real - lng_fvcom)**2),
  ) %>%
  select(-c(lat_fvcom, lat_efdc, lng_fvcom, lng_efdc, x_fvcom, y_fvcom, x_efdc, y_efdc)) %>%
  rename(lat = lat_real, lng = lng_real, x = x_real, y = y_real)

#%% GLENDA
glenda <- .readPivotGLENDA(paste0(realDatadir, "LOglenda.csv")) %>%
  filter(YEAR %in% c(2013, 2018)) %>%
  select(uid = VISIT_ID, siteID = STATION_ID, stationDepth = STN_DEPTH_M, lat = LATITUDE, lng = LONGITUDE, sampleDateTime = SAMPLING_DATE, 
    sampleDepth = SAMPLE_DEPTH_M, value = VALUE, analyte = ANALYTE) %>%
  mutate(type = "ctd", source = "glenda", sampleDepth = round(sampleDepth)) %>%
    # 20% sample Depths missing, everything else nonmissing
    drop_na() %>%
    reframe(value = mean(as.numeric(value), na.rm = T),
    type = "wq", source = "glenda", 
    .by = c(uid, siteID, stationDepth, lat,lng, sampleDateTime, sampleDepth, type, source, analyte)) %>%
  pivot_wider(id_cols = c(uid, siteID, stationDepth, lat, lng, sampleDateTime,
    sampleDepth, type, source), values_from = value, names_from = analyte)


#%% CSMI
# ctd data
csmiPos <- readxl::read_xlsx(paste0(realDatadir, "L2_SampleEvent.xlsx")) %>%
  select(Key = EventCodeKey, siteID = StationCodeFK, date= CollectionDate, time = TimeSampled, siteDepth = SiteDepth, lat = LatitudeDD, lng= LongitudeDD) %>%
  mutate(
    date = date(date),
    hour = hour(time), 
    min = minute(time)
  ) %>%
  unite(time, c(hour, min), sep = ":") %>%
  unite(dateTime, c(date, time), sep = " ") %>%
  mutate(dateTime = as.POSIXct(dateTime, format="%Y-%m-%d %H:%M")) %>%
  filter(dateTime > as.POSIXlt("2018-01-01 00:00")) %>%
  filter(dateTime < as.POSIXlt("2018-12-31 00:00")) %>%
  mutate(dateTime = lubridate::round_date(dateTime, "4 hours")) %>%
  distinct(EventCode = Key, stationCode = siteID, lat, lng, dateTime)

csmi <- readxl::read_xlsx(paste0(realDatadir, "L3b_WaterChemistry.xlsx")) %>%
  rename(Key = EventCode, siteID = StationCode, sampleDepth = SampleDepth, temp = T090C,) %>%
  left_join(csmiPos, by = c("Key" = "EventCode", "siteID" = "stationCode")) %>%
  mutate(sampleDepth = round(as.numeric(sampleDepth)), temp = as.numeric(temp)) %>%
  mutate(
    sigma = round((sampleDepth / max(sampleDepth, na.rm = T)) * 20),
    .by = siteID
  ) %>%
  select(uid = Key, siteID, sampleDepth, sigma, sampleDateTime= dateTime, lat,lng, temp) %>%
  reframe(temp = mean(temp, na.rm=  T), .by = c(uid, siteID, sampleDepth, sigma, sampleDateTime, lat, lng)) %>%
  drop_na(lat, sampleDateTime, temp) %>%
  mutate(source = "csmi", type = "ctd")

# Chemistry data (Can't use until we resolve the depth issue)
# chem <- readxl::read_xlsx("realData/L3a_WaterQuality.xlsx") %>%
#   select(uid = EventCode, depths = Depths, tp = TotalPhosphorus_ugL, depthCode = SampleDepthCode) %>%
#   # not sure how to compute depth if data missing (i.e. I could decipher depth codes, but haven't yet)
#   drop_na(depths) %>%
#   left_join(sites, by = "Key") %>%
#   mutate(TP = as.numeric(TP)) %>%
#   separate_longer_delim(depths, delim = ", ") %>%
#   reframe(
#     sampleDepth = mean(as.numeric(depths), na.rm= T), sampleDepthSD = sd(as.numeric(depths), na.rm = T),
#     TP = mean(as.numeric(TP), na.rm = T),
#     .by = c(dateTime, depthCode, Key, siteDepth, lat, lng))  %>%
#   mutate(Type = "wq")


#%% bouys
# Note the temps are reported in Celsius
# DPD - Dominant wave period (seconds) is the period with the maximum wave energy. See the Wave Measurements section.
# APD - Average wave period (seconds) of all waves during the 20-minute period. See the Wave Measurements section.
# MWD - The direction from which the waves at the dominant period (DPD) are coming. The units are degrees from true North, increasing clockwise, with North as 0 (zero) degrees and East as 90 degrees. See the Wave Measurements section.
bouySites <- read_table("../../realData/bouys/bouyCoords.tsv", skip = 1) %>%
  mutate(siteID = str_extract(filename, "^.{5}")) %>%
  reframe(.by = siteID, across(c("lat", "lon", "depth"), function(x) mean(x, na.rm = T)))
bouy <- readRDS(paste0(realDatadir, "/bouys/bouy.Rds")) %>%
  mutate(type = "bouy", source = "bouy", sigma= 1) %>%
  rename(siteID = Station) %>%
  left_join(bouySites)
# bouy <- list.files(paste0(realDatadir, "bouys"), "*.txt", full.names=T) %>%
#   map(., function(x)
#     read_table(x, 
#       col_names = c("#YY",  "MM",   "DD",   "hh",   "mm",
#         "WDIR", "WSPD", "GST",  "WVHT", "DPD", "APD",  "MWD",  "PRES", "ATMP", "WTMP", "DEWP", "VIS",  "TIDE"),
#       col_types = cols(
#         .default = "_",
#         `#YY` = "d",  MM = "d", DD = "d",   hh = "d",   mm = "d",
#         WTMP = "d", APD = "d", MWD = "d", DPD = "d"),
#          skip = 2
#         ) %>%
#       mutate(Station = basename(x))
#     ) %>%
#   reduce(bind_rows) %>%
#   mutate(Year = stringr::str_extract(Station, "2013|2018"),
#   across(where(is.numeric), function (x) ifelse(x== 999, NA, x))) %>%
#   mutate(
#     hh = ifelse(mm < 30, hh, hh+1),
#     mm = "00"
#     ) %>%
#   reframe(.by = c(MM, DD, hh, Station, Year), wTemp = mean(WTMP, na.rm = T), wDir = mean(MWD, na.rm = T)) %>%
#   left_join(siteInfo, by = c("Station" = "filename")) %>%
#   # round to nearest hour
#   # format date
#   unite(date, c(Year, MM, DD), sep = "/") %>%
#   mutate(mm = "00") %>%
#   unite(time, c(hh, mm), sep = ":") %>%
#   unite(dateTime, c(date, time), sep = " ") %>%
#   mutate(
#     dateTime = as.POSIXlt(dateTime),
#     # Extract station name
#     Station = stringr::str_remove(Station, "h20.{2}\\.txt$")
#   ) %>%
#   filter(year(dateTime) %in% c(2013, 2018)) %>%
#   # only keep when either wtemp or wDir observed
#   filter(!is.na(wTemp) | !is.na(wDir)) %>%
#   select(sampleDateTime = dateTime, siteID = Station, temp = wTemp, wAngle = wDir, lat, lng = lon, stationDepth = depth, sampleDepth) %>%
#   pivot_longer(c(temp, wAngle), names_to = "analyte", values_to = "value") %>%
#   drop_na(value) %>%
#   mutate(type = "bouy", source = "bouy", sampleDepth = ifelse(is.na(sampleDepth), 1.3, sampleDepth))

#%% combine
full <- bind_rows(glenda, csmi, bouy) %>% 
  mutate(
    lng = coalesce(lng,lon),
    sampleDateTime = coalesce(sampleDateTime, dateTime),
    depth = coalesce(depth, stationDepth),
    temp = coalesce(temp, Temperature, wTemp),
    sigma = ifelse(is.na(sigma), 1, sigma),
    depth = coalesce(depth, stationDepth),
    depth = ifelse(is.na(depth), 1, depth),
  ) %>%
  select(siteID, lat, lng, sampleDateTime, sampleDepth, type, source, depth, temp, tp = `Phosphorus, Total as P`, chla = `Chlorophyll-a`, wDir, sigma) %>%
  mutate(
    sampleDepth = round(sampleDepth),
    sampleDateTime = lubridate::round_date(sampleDateTime, "4 hours")
  ) %>%
  reframe(.by = -c(wDir, tp, temp, chla), across(c("wDir", "tp", "temp", "chla"), function(x) mean(x, na.rm = T))) %>%
  nest_by(lat,lng, type, source, siteID, depth) %>%
  drop_na() %>%
  left_join(sites, by = "siteID", suffix = c("", ".remove")) %>%
  unnest(data) %>%
  select(-ends_with("remove")) %>%
  filter(year(sampleDateTime) ==2018) %>%
  mutate(sigma = case_when(
    sigma ==0 ~ 1,
    sigma >20 ~ 20,
    .default = sigma
  )) %>%
  saveRDS(paste0(realDatadir, "realDataWsites.Rds"))
full <- readRDS(paste0(realDatadir, "realDataWsites.Rds"))

fvcomMatchedNodes <- full %>% distinct(node_fvcom) %>% arrange(node_fvcom) %>%
  pull(node_fvcom)


fvcom <- ncdf4::nc_open("../../output/runs/2018/scenario1_0001.nc")
fvcomTime <- data.frame(
  "days" = ncdf4::ncvar_get(fvcom, "time")) %>%
  mutate(time = seq_len(nrow(.))) %>%
  mutate(
    simDays = floor(days),
    simhours = hours(round((days - simDays) * 24)),
    simDays = days(simDays),
    simTime = simDays + simhours,
    dateTime = ymd("1970-01-01") + simTime,
  ) %>%
  select(time, dateTime) 
fvcomData <- reshape2::melt(ncdf4::ncvar_get(fvcom, "temp")[fvcomMatchedNodes, ,]) %>%
  rename(node = Var1, sigma= Var2, time = Var3, temp = value)

fvcomData$tp <- reshape2::melt(ncdf4::ncvar_get(fvcom, "TP")[fvcomMatchedNodes, ,]) %>%
  rename(node = Var1, sigma= Var2, time = Var3, tp = value) %>% pull(tp)

fvcomNodeDF <- data.frame("node" = fvcomMatchedNodes) %>%
  mutate(num = 1:n())

test <- fvcomData %>%
  left_join(fvcomNodeDF, by = c("node"= "num")) %>%
  select(-node) %>% 
  rename(node = node.y) %>%
  # only keep nodes with matching data
  filter(node %in% unique(full$node_fvcom)) %>% 
  left_join(fvcomTime) %>%
  mutate(
    dateTime = round_date(dateTime, "4 hours")
  ) %>%
  reframe(
    .by = c(node, sigma, dateTime),
    across(c("temp", "tp"), function(x) mean(x, na.rm = T))
  )
nc_close(fvcom)

################ PICK UP HERE

efdcPos <- read_table("/work/GLFBREEZ/Lake_Ontario/LatLon.txt") %>%
  mutate(node = seq_len(nrow(.)))
  left_join(read_table("/work/GLFBREEZ/Lake_Ontario/IJ_Depth_NZ.txt", col_names = c("I", "J", "depth", "maxSigma")))
efdcTime <- read_table("/work/GLFBREEZ/Lake_Ontario/Time_intervals.txt", col_names = "day") %>%
  mutate(
    simDays = floor(day),
    simhours = hours(round((day - simDays) * 24)),
    simDays = days(simDays),
    simTime = simDays + simhours,
    time = seq_len(nrow(.)),
    dateTime = ymd("2018-04-01") + simTime
  ) %>%
  select(time, dateTime)


efdc <- ncdf4::nc_open("/work/GLFBREEZ/Lake_Ontario/Temp.nc")
efdcData <- reshape2::melt(ncdf4::ncvar_get(efdc, "Temp")) %>%
  dplyr::rename(I = Var1, J = Var2, sigma= Var3, time= Var4, temp = value) %>%
  drop_na()  %>%
  left_join(efdcPos) %>%
  # only include values which actually had observed data
  filter(node %in% unique(full$node_efdc)) %>%
  left_join(efdcTime) %>%
  select(-c(I, J, XCent, YCent, time)) %>%
  rename(lng= lon) %>%
  arrange(lat, lng, sigma) %>%
  mutate(dateTime = round_date(dateTime, "4 hours")) %>%
  reframe(
    .by = -temp, temp = mean(temp, na.rm = T)
  )
nc_close(efdc)


full %>% 
  left_join(fvcomData,
    by = c("node_fvcom" = "node", "sampleDateTime" = "dateTime", "sigma"), 
    suffix = c(".real", ".fvcom")) %>%
  left_join(efdcData %>% select(-c(lat, lng)),
    by = c("node_efdc" = "node", "sampleDateTime" = "dateTime", "sigma"),
    suffix = c(".real", ".efdc")
  ) %>%
  mutate(siteDepth = coalesce(siteDepth, depth)) %>%
  select(-depth) %>%
  rename(temp.efdc = temp) %>%
  saveRDS(paste0(realDatadir, "simDataWsites.Rds"))


