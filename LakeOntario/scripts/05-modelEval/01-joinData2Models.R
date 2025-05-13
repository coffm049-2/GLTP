# [x] Join efdc depths in corectly
# [x] Join efdc time setteps in correctly 
# April 10 is day 100
# November 16 is day 320

library(tidyverse)
library(ncdf4)
#source("scripts/expLeap.R")



# [x] Load real data
obsDf <- readRDS("../../realData/realDataWsites.Rds") %>%
  # make sure only one result per space and time
  mutate(
    .by = siteID,
    across(c("lat", "lng", "depth", "siteDepth", "area", "node_fvcom", "node_efdc", "dist_fvcom", "dist_efdc", "x", "y"), function(x) mean(x, na.rm = T)),
    sampleDateTime = floor_date(sampleDateTime, "4 hours")
  )


nodeLatLng <- obsDf %>% distinct(node_efdc, node_fvcom, lat,lng)

  
# restrict toto maximum sttart  datte and  minimum end date (whichh are both frormo EFFDC)
startDateTime <- ymd_h("2018-04-01 0")
endDateTime <- ymd_h("2018-10-01 0")

# for pipeline building
# startDateTime <- min(round_date(obsDf$sampleDateTime,  "days"))
# endDateTime <- max(round_date(obsDf$sampleDateTime, "days"))

startIdx <- round(24 * (startDateTime - lubridate::ymd_hm("2018-01-01 00:00"))[[1]])
stopIdx <- round(24 * (endDateTime - lubridate::ymd_hm("2018-01-01 00:00"))[[1]]) + 1



fvcomFile <- ncdf4::nc_open("../../output/runs/2013/dolanHot_0001.nc")
fvcomNodes <- sort(unique(obsDf$node_fvcom))

tempDF <- ncdf4::ncvar_get(fvcomFile, "temp")[fvcomNodes, , ] %>%
  reshape2::melt(., value.name="temp") %>%
  rename(node = Var1, sigma = Var2, time = Var3) %>%
  mutate(
    node = rep(fvcomNodes, max(time, na.rm = T) *20),
  ) 

dates <- seq(startDateTime, endDateTime, length.out = length(unique(tempDF$time,na.rm =T)))
tempDF$dateTime <- dates[tempDF$time]
tempDF <- tempDF %>%
  left_join(obsDf, by = c("node" = "node_fvcom", "dateTime" = "sampleDateTime", "sigma"), suffix = c("_fvcom", "")) %>%
  left_join(nodeLatLng, by = c("node" = "node_fvcom")) %>%
  mutate(lat = coalesce(lat.x, lat.y), lng = coalesce(lng.x, lng.y), node_efdc = coalesce(node_efdc.x, node_efdc.y)) %>%
  select(-ends_with(".x"), -ends_with(".y")) %>%
  mutate(
    dateTime = floor_date(dateTime, "4 hours")
    ) %>%
  # make sure one observation per space time 
  # at 4 hour resolution
  reframe(
    .by = c(dateTime, node, node_efdc, sigma),
    across(c(temp_fvcom, depth, sampleDepth, wDir, tp, temp, chla, siteDepth, area, dist_fvcom, dist_efdc, x, y, lat, lng), function(x) mean(x,na.rm = T)),
    type = unique(type)[1],
    siteID = unique(siteID)[1],
    source = unique(source)[1],
  )

ncdf4::nc_close(fvcomFile)


efdcTime <- data.frame("dateTime" = seq(
    from = ymd_h("2018-04-01 00"),
    length.out = 1219,
    to = ymd_h("2018-09-30 00"))) %>%
  mutate(
    time = seq_len(nrow(.)),
    dateTime = round_date(dateTime, "hours")
  )

temp <- ncdf4::nc_open("/work/GLFBREEZ/Lake_Ontario/Temp.nc")
efdcTemp <- read_table("/work/GLFBREEZ/Lake_Ontario/LatLon.txt") %>%
  mutate(node_efdc = seq_len(nrow(.))) %>%
  filter(node_efdc %in% obsDf$node_efdc) %>%
  select(node_efdc, I,J) %>%
  arrange(I, J) %>%
  mutate(d = map2(.x = I, .y = J, .f = \(i,j) {
    ncdf4::ncvar_get(temp, "Temp", start = c(i, j, 1, 1), count = c(1, 1, 10, 1219))%>%
    reshape2::melt() %>%
    dplyr::rename(sigma = Var1, time = Var2, temp_efdc = value) %>%
    left_join(efdcTime, by = "time")
  }, .progress=  T)) %>%
  unnest(cols = "d") %>%
  # to loosely match on depth and time
  # accounting for fact efdc is slightly more sparse
  mutate(
    sigma = sigma * 2,
    sigma_2 = sigma -1
  ) %>%
  select(node_efdc, dateTime, sigma, sigma_2, temp_efdc) %>%
  filter(
    # select one week bookending measurements
    dateTime >= ymd("2018-04-01"),
    dateTime <= ymd("2018-09-30"),
  ) %>%
  drop_na() %>%
  mutate(
    dateTime = floor_date(dateTime, "4 hours"),
  ) %>%
  reframe(temp_efdc = mean(temp_efdc, na.rm = T), .by = c(node_efdc, dateTime,sigma, sigma_2))

test <- left_join(tempDF, efdcTemp, by = c("sigma", "dateTime", "node_efdc")) %>%
  left_join(efdcTemp, by = c("sigma_2", "dateTime", "node_efdc"))  %>% 
  mutate(
    temp_efdc = coalesce(temp_efdc.x, temp_efdc.y),
    sigma = coalesce(sigma.x, sigma.y, sigma_2),
  ) %>%
  select(-ends_with(".x"), -ends_with(".y"), -sigma_2) %>%
  rename(node_fvcom = node) %>%
  mutate(dateTime = round_date(dateTime, "4 hours")) %>%
  reframe(
    .by = c(node_fvcom, node_efdc, dateTime, sigma, lat, lng, x, y),
    across(c(wDir, tp, temp, chla, temp_fvcom, temp_efdc, siteDepth, dist_fvcom, dist_efdc, depth, area), function(x) mean(x, na.rm = T))
  )

saveRDS(test, "joinedData.Rds")
