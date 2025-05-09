library(ncdf4)
library(sp)
library(rgdal)

args <- commandArgs(trailingOnly = TRUE)


nc <- nc_open(filename = args[1], write = TRUE)

lat <- ncvar_get(nc, varid = "lat")
lon <- ncvar_get(nc, varid = "lon")

latc <- ncvar_get(nc, varid = "latc")
lonc <- ncvar_get(nc, varid = "lonc")

zone <- 17 

lonlat <- data.frame(ID = 1:length(lon), Lon = lon, Lat = lat)
coordinates(lonlat) <- c("Lon", "Lat")

proj4string(lonlat) <- CRS("+proj=longlat +datum=WGS84")
res <- spTransform(lonlat, CRS(paste("+proj=utm +zone=",zone," ellps=WGS84",sep='')))
df <- as.data.frame(res)

lonclatc <- data.frame(ID = 1:length(lonc), Lonc = lonc, Latc = latc)
coordinates(lonclatc) <- c("Lonc", "Latc")

proj4string(lonclatc) <- CRS("+proj=longlat +datum=WGS84")
resc <- spTransform(lonclatc, CRS(paste("+proj=utm +zone=",zone," ellps=WGS84",sep='')))
dfc <- as.data.frame(resc)


# Write data
ncvar_put(nc, varid = "x", df$Lon)
ncvar_put(nc, varid = "y", df$Lat)

ncvar_put(nc, varid = "xc", dfc$Lonc)
ncvar_put(nc, varid = "yc", dfc$Latc)

ncatt_put(nc, varid = 0, attname = "CoordinateSystem", attval = "Cartesian")
ncatt_put(nc, varid = 0, attname = "CoordinateProjection", attval = "none")

nc_close(nc)
