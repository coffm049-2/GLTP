library(tidyverse)
library(ncdf4)
source("scripts/expLeap.R")


# [x]  Load ice data
df <- list.files("../../realData", pattern = "g.*.dat", full.names=T) %>%
  map(read_table) %>%
  reduce(bind_rows) %>%
  unite("dayyear", Day, Year, sep = "-") %>%
  mutate(Date = lubridate::parse_date_time(dayyear, orders = "%j-%Y"))
  #select(Date, Ont.)
# get coverage on 
# - 02/05/2018 - 11.0%
# - 03/14/2018 - 2.08 %
iceCover <- df %>%
  filter(Date %in% lubridate::parse_date_time(
    c("02/05/18", "03/14/18", "04/10/18", "11/16/18"),
      orders = "%m/%d/%y")) %>% 
  select(Date, Ont.)


# [ ] Take pictures on specified days
# - 02/05/2018 - 11.0%
# - 03/14/2018 - 2.08 %
# - 04/10/2018 - 0
# - 11/16/2018 - 0
# model run (for a single day)
model <- ncdf4::nc_open("../../output/runs/modelIceFeb5.nc")
mean(ncdf4::ncvar_get(model, "aice")) #53% 
mean(ncdf4::ncvar_get(model, "vice")) #9.8%
ncdf4::nc_close(model)


model <- ncdf4::nc_open("../../output/runs/modelIceMar14.nc")
mean(ncdf4::ncvar_get(model, "aice")) # 5.8%
mean(ncdf4::ncvar_get(model, "vice")) # 2.8%
ncdf4::nc_close(model)


model <- ncdf4::nc_open("../../output/runs/modelIceApril10.nc")
mean(ncdf4::ncvar_get(model, "aice")) # 1.6%
mean(ncdf4::ncvar_get(model, "vice")) # 1.7%
ncdf4::nc_close(model)

model <- ncdf4::nc_open("../../output/runs/modelIceNov16.nc")
mean(ncdf4::ncvar_get(model, "aice")) # 0.7%
mean(ncdf4::ncvar_get(model, "vice")) # 0.02%
ncdf4::nc_close(model)

iceCover$model <- c(9.8, 2.8, 1.7, 0.02)
write_csv(iceCover, "tables/iceCoverCompare.csv")
