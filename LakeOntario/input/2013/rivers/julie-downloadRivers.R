library(tidyverse)
library(dataRetrieval)
library(tidyhydat)

# US information on rivers retrieved from
# https://maps.waterdata.usgs.gov/mapper/index.html

# JM note: lots of missing temp data, Niagara river data was not grabbed...

# [ ] comment out whichever rivers you don't want
usSites <- data.frame(
  "siteID" = c(
  "04231600",
  "04219768",
  "0422018610",
  "04219501", #Original site ID (0421964005) corresponds to NOTL station, data is not weekly nor continuous. USGS flow gauge is Lewiston, NY, site ID = 04219501
  "04249000",
  "04260500",
  "0423205010"
  ),
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

start.date <- "2018-01-01"
end.date <- "2018-12-30"

usdf <- renameNWISColumns(
  readNWISuv(siteNumbers = usSites$siteID,
  parameterCd = c("00060", "00010", "74082"), # discharge, temp, flow 
  startDate = start.date,
  endDate = end.date)) %>% #Viewed data before left_join, niagara site IDs are still missing
  left_join(usSites, by = c("site_no" = "siteID")) %>%
  select(siteName, dateTime, flow = Flow_Inst, temp = Wtemp_Inst) %>%
  mutate(nation = "USA")

View(usdf) #niagara doesn't show up whether NOTL or Lewiston ID is used
   
write_csv(usdf, "/work/GLHABS/GreatLakesHydro/LakeOntario/input/2018/rivers2018.csv")

niaSites <- data.frame(
  "SiteID" = c(
    "0421964005",
    "04219501"
  ),
  "siteName" = c(
    "NOTL",
    "Lewiston"
  )
)

niadf <- renameNWISColumns(
  readNWISuv(siteNumbers = niaSites$SiteID,
             parameterCd = c("00010", "00020", "00060", "00061", "74082"), #water temp, air temp, discharge daily, discharge instant, flow
             startDate = start.date,
             endDate = end.date))
View(niadf)