library(tidyverse)
library(dataRetrieval)
library(tidyhydat)

# US information on rivers retrieved from
# https://maps.waterdata.usgs.gov/mapper/index.html

usSites <- data.frame(
  "siteID" = c(
  "04231600",
  "04219768",
  "0422018610",
  "0421964005",
  "04249000",
  "04260500",
  "0423205010"),
  "siteName" = c(
    "genessee",
    "eighteenmile",
    "oakorchard",
    "niagara",
    "oswego",
    "black", #watertown
    "irondequoit"
  )
)



pcode <- readNWISpCode("all")
# temperature
pcode %>%
  filter(grepl("phosphorus", parameter_nm)) %>%
  filter(grepl("total", parameter_nm)) %>%
  filter(!grepl("soil", parameter_nm)) %>%
  filter(!grepl("sediment", parameter_nm)) %>%
  distinct(parameter_nm)
  #filter(parameter_cd %in% c("00060", "00010", "74082")) 

pcode %>%
  filter(grepl("phosphorus", parameter_nm)) %>%
  distinct(parameter_cd, parameter_nm)

start.date <- "2013-01-01"
end.date <- "2013-12-30"

usdf <- renameNWISColumns(
  readNWISuv(siteNumbers = usSites$siteID,
  parameterCd = c("00060", "00010", "74082"), # discharge, temp, flow 
  startDate = start.date,
  endDate = end.date
  )) %>%
  left_join(usSites, by = c("site_no" = "siteID")) %>%
  select(siteName, dateTime, flow = Flow_Inst, temp = Wtemp_Inst) %>%
  mutate(nation = "USA")
   

# for canadian
# https://wateroffice.ec.gc.ca/search/real_time_e.html
canSites <- data.frame(
  "siteID" = c(
"02HC003",
"02HA031",
"02HK010"),
  "siteName" = c(
    "humber", # weston
    "twelve_mile_creek", # near power glen
    "trent" # at trenton
  )
)

param_id %>%
  filter(grepl("temp", Name_En, ignore.case= T)) %>%
  distinct(Parameter, Name_En)
pCode <- c(5, 40)



# HYDAT database
candf <- hy_daily_flows(
  station_number = canSites$siteID,
  start_date = start.date,
  end_date = end.date
) %>%
  left_join(canSites, by = c("STATION_NUMBER" = "siteID")) %>%
  select(siteName, dateTime = Date, flow = Value) %>%
  mutate(nation = "CAN")

# impute geographically until no missingness
df <- bind_rows(usdf, candf) %>%
  mutate(season = quarter(dateTime, fiscal_start = 3)) %>%
  mutate(
    .by = c(siteName, season),
    across(c(temp, flow), function(x) 
      ifelse(is.na(x), mean(x, na.rm = T), x))
  ) %>% 
  mutate(
    .by = c(nation, season),
    temp = ifelse(is.na(temp), mean(temp, na.rm = T), temp)
  ) %>%
  mutate(
    .by = c(season),
    temp = ifelse(is.na(temp), mean(temp, na.rm = T), temp)
  )

write_csv(df, "rivers2013.csv")

