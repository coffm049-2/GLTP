# [x] Join efdc depths in corectly
# [x] Join efdc time setteps in correctly 
# April 10 is day 100
# November 16 is day 320

library(tidyverse)
library(ncdf4)
#source("scripts/expLeap.R")

# [x] Load real data
obsDf <- readRDS("../../realData/realDataWsites.Rds") %>%
  mutate(
    .by = siteID,
    across(c("lat", "lng", "depth", "siteDepth", "area", "node_fvcom", "node_efdc", "dist_fvcom", "dist_efdc", "x", "y"), function(x) mean(x, na.rm = T))
  )

  
# restrict toto maximum sttart  datte and  minimum end date (whichh are both frormo EFFDC)
startDateTime <- ymd_h("2018-04-01 0")
endDateTime <- ymd_h("2018-09-30 0")

# for pipeline building
# startDateTime <- min(round_date(obsDf$sampleDateTime,  "days"))
# endDateTime <- max(round_date(obsDf$sampleDateTime, "days"))

startIdx <- round(24 * (startDateTime - lubridate::ymd_hm("2018-01-01 00:01"))[[1]])
stopIdx <- round(24 * (endDateTime - lubridate::ymd_hm("2018-01-01 00:01"))[[1]]) + 1



fvcomFile <- ncdf4::nc_open("../../output/runs/fvcom_0001.nc")
fvcomNodes <- sort(unique(obsDf$node_fvcom))
tempDf <- data.frame(matrix(nrow  = (stopIdx  - startIdx) * 20, ncol= length(fvcomNodes)))
names(tempDf)  <- fvcomNodes

for (node in fvcomNodes) {
  print(node)
  temp <- reshape2::melt(
   # each file only has one node
   # node siglay, time
    ncdf4::ncvar_get(fvcomFile, "temp", start = c(node, 1, startIdx), count = c(1, 20, stopIdx - startIdx))
  ) %>%
  rename(sigma = Var1, time = Var2, temp = value)

  tempDf[,deparse(node)] <- temp  %>% pull(temp)
}

tempDf$sigma <- temp$sigma
tempDf$time <- temp$time

ncdf4::nc_close(fvcomFile)

saveRDS(tempDf, "fvcomTempMat.Rds")
