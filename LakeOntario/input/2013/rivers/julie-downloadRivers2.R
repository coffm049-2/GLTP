library(tidyverse)
library(dataRetrieval)
library(tidyhydat)

#JM note:  slightly modified original script to add NOTL to Canadian sites

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
    "oakorchard", #no temp data earlier than 2020, not pulled
    "niagara", #NOTL station, currently failing to pull data
    "oswego",
    "black", #watertown
    "irondequoit"
  )
)

pcode <- readNWISpCode("all") #grabbing all pcodes
View(pcode)
pcode %>%
  filter(grepl("phosphorus", parameter_nm)) %>%
  filter(grepl("total", parameter_nm)) %>% #find total phos param number
  filter(!grepl("soil", parameter_nm)) %>% #exclude soil and sediment TP
  filter(!grepl("sediment", parameter_nm)) %>%
  distinct(parameter_nm, parameter_cd) #no water measurements of TP ("dry atmospheric deposition")
  #filter(parameter_cd %in% c("00060", "00010", "74082")) 

pcode %>%
  filter(grepl("phosphorus", parameter_nm)) %>%
  distinct(parameter_cd, parameter_nm) %>% View()
#00665 - unfiltered phosphorus, water (mg/L)
#00666 - filtered phosphorus, water (mg/L)
#01072 - filtered phosphorus, water (mg/L)
#52527 - unfiltered phosphorus, water (mg/L)
#52635 - unfiltered phosphorus, water (mg/L)

start.date <- "2018-01-01"
end.date <- "2018-12-30"

#added each phosphorous param id and none were added for the time periods/locations needed
usdf <- renameNWISColumns(
  readNWISuv(siteNumbers = usSites$siteID,
  parameterCd = c("00060", "00010", "74082"), # discharge, temp, flow
  startDate = start.date,
  endDate = end.date
  )) %>%
  left_join(usSites, by = c("site_no" = "siteID")) %>%
  select(siteName, dateTime, flow = Flow_Inst, temp = Wtemp_Inst) %>%
  mutate(nation = "USA") 
   
#convert cfs -> cms: 1 cfs = 0.0283 cms
usdf$flow_cfs <- usdf$flow

usdf$flow <- usdf$flow_cfs * 0.0283
View(usdf)

# for canadian
# https://wateroffice.ec.gc.ca/search/real_time_e.html
canSites <- data.frame(
  "siteID" = c(
"02HC003",
"02HA031",
"02HK010",
"02HA003"), #added Niagara Queenstown station
  "siteName" = c(
    "humber", # weston
    "twelve_mile_creek", # near power glen
    "trent", # at trenton
    "niagara" #at Queenstown  
  )
)

param_id %>%
  filter(grepl("temp", Name_En, ignore.case= T)) %>%
  distinct(Parameter, Name_En) %>% View()
pCode <- c(5, 40) #5 = temperature, 40 = discharge, hourly mean

# HYDAT database
candf <- hy_daily_flows(
  station_number = canSites$siteID,
  start_date = start.date,
  end_date = end.date) %>%
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

df_clean <- subset(df, select = -flow_cfs)
head(df_clean)

write_csv(df_clean, "rivers2018_JM.csv")

