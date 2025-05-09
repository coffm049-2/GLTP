# TODO 
# [x] Add distance from node to observation
# [ ] Add area for EFDC grid

library(tidyverse)
library(ncdf4)


fvcom <- ncdf4::nc_open("../../output/runs/2018/gridData.nc")
data <- data.frame(
  "lat" = ncdf4::ncvar_get(fvcom, "lat"),
  "lng" = ncdf4::ncvar_get(fvcom, "lon") - 360
) %>%
  mutate(node = 1:nrow(.))
write_csv(data, "fvcomGrid.csv")
nc_close(fvcom)

