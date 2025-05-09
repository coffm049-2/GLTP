# [x] Join efdc depths in corectly
# [x] Join efdc time setteps in correctly 
# April 10 is day 100
# November 16 is day 320

library(tidyverse)
library(ncdf4)
#source("scripts/expLeap.R")
obsDf <- readRDS("../../realData/realDataWsites.Rds") %>%
  mutate(
    .by = siteID,
    across(c("lat", "lng", "depth", "siteDepth", "area", "node_fvcom", "node_efdc", "dist_fvcom", "dist_efdc", "x", "y"), function(x) mean(x, na.rm = T))
  )

startDateTime <- ymd_h("2018-04-01 0")
endDateTime <- ymd_h("2018-09-30 0")
startIdx <- round(24 * (startDateTime - lubridate::ymd_hm("2018-01-01 00:01"))[[1]])
stopIdx <- round(24 * (endDateTime - lubridate::ymd_hm("2018-01-01 00:01"))[[1]]) + 1

tempDf <- readRDS("fvcomTempMat.Rds")


# NOTE subsetting data then pivoting will make this work 
hourSeq <- data.frame(
# NOTE  temporary to work on janurary data while sim is running
###### MAKE SURE TO CHANGE
  "dateTime" = seq(
    from = startDateTime,
    by = "1 hours",
    to = endDateTime)) %>%
  mutate(time = seq_len(nrow(.)))

tempDf <- tempDf %>% 
  left_join(hourSeq, by = "time") %>%
  select(-time) %>%
  pivot_longer(-c(sigma, dateTime), names_to = "node_fvcom", values_to = "temp_fvcom") %>%
  drop_na(temp_fvcom) %>%
  mutate(node_fvcom = as.numeric(node_fvcom)) %>%
# [x] Expand for full comparison of efdc and fvcom (need lat anndd longs to join)
  left_join(obsDf, by = c("node_fvcom", "dateTime" = "sampleDateTime", "sigma"), suffix = c(".fvcom", ".real"))  %>%
  mutate(
    across(c("lat", "lng", "depth", "siteDepth", "area", "dist_fvcom", "dist_efdc", "x", "y"), function(x) mean(x, na.rm = T)),
    across(c("type", "source", "siteID", "node_efdc"), function(x) {
      t <- table(x)
      ifelse(length(t) == 0, NA, names(sort(t, decreasing=T)[1]))
    }),
    .by = node_fvcom
  ) %>%
  drop_na(node_efdc, node_fvcom)
  

# EFDC is from April 1 to sept 30 

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
    dateTime = round_date(dateTime, "hours"),
  )
ncdf4::nc_close(temp)

setdiff(unique(tempDf$dateTime), unique(efdcTemp$dateTime))
# all nodes are matched
# setdiff(unique(tempDf$node_efdc), unique(efdcTemp$node_efdc))
setdiff(unique(tempDf$sigma), unique(efdcTemp$sigma_2))


fullDat <- tempDf %>%
  # EFDC is from April 1 to sept 30 
  filter(
    # select one week bookending measurements
    dateTime >= ymd_h("2018-04-01 0"),
    dateTime <= ymd_h("2018-09-30 0"),
    ) %>%
  mutate(
    node_efdc = as.numeric(node_efdc),
    dateTime = round_date(dateTime, "hours")
  ) %>%
  left_join(efdcTemp, by = c("node_efdc", "dateTime", "sigma")) %>%
  left_join(efdcTemp, by = c("node_efdc", "dateTime", "sigma" = "sigma_2")) %>%
  mutate(
    temp_efdc = coalesce(temp_efdc.x, temp_efdc.y),
    sigma = coalesce(sigma, sigma_2),
    dateTime = round_date(dateTime, "4 hours")
  ) %>%
  reframe(
    .by = c(sigma, dateTime, node_fvcom, node_efdc, lat, lng, type, source, siteID, depth, sampleDepth, siteDepth, area, 
      node_efdc, dist_fvcom, dist_efdc, x,y),
    across(c(temp_fvcom, temp_efdc, temp, tp, wDir, chla), function(x) mean(x, na.rm = T))
  ) %>%
  select(
    dateTime,
    area, lng, lat, x,y,
    sampleDepth, depth, siteDepth, sigma,
    temp_fvcom, temp_efdc, temp_real = temp,
    node_fvcom, node_efdc,
    type, source, siteID,
    chla, tp, wDir,
    dist_fvcom, dist_efdc
  )  %>%
  drop_na(lng)
# fullDat %>%
#   reframe(across(everything(), function(x) mean(is.na(x))))
# fullDat %>% reframe(mean(is.na(temp.efdc)), .by = sigma)

saveRDS(fullDat, "nodeMatchedData.Rds")
