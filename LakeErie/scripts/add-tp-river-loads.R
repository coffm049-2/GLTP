#-- add-tp-river-loads.R
#L3, 2023
# Starts with 2013_leem_fine_river_data.nc

#To read netCDF model file
library(ncdf4)

# Location of Original 'just hydro' river forcing file
hydrofile <- "/Users/lllowe/LakeErie/TPmodel/simulations/input/full_year/2013_leem_fine_river_data_original_hydro.nc"
# New river file with added TP loads
tpfile <- "/Users/lllowe/LakeErie/TPmodel/simulations/input/full_year/2013_leem_fine_river_data.nc"
#--Riverloads file, this xlsx Wilson emailed me on April 11, I exported the first sheet as CSV
loadsfile <- file.path("~/LakeErie/TPmodel/data/TP_ZOO_Loads.csv")

#Check file paths
if (!file.exists(hydrofile)) stop("Original river loads file not found, exiting")
if (!file.exists(loadsfile)) stop("TP loads spreadsheet not found, exiting")

# Copy the original netCDF file, since we will append to the file
file.copy(hydrofile,tpfile,overwrite=TRUE)

#read the file
ncdata <- nc_open(tpfile,write=TRUE,readunlim=FALSE)

# Get Data, Times (MJD, days since 1858-11-17 00:00:00)
time <- ncvar_get(ncdata, "Times", start=c(1,1), count=c(-1,-1))
time <- as.POSIXct(time, format="%Y-%m-%dT%H:%M:%S", tz="GMT")
nt <- length(time)
rivnames <- ncvar_get(ncdata, "river_names", start=c(1,1), count=c(-1,-1))
nr <- length(rivnames)

#--Open csv with TP loads
# First row is node numbers
df<- read.csv(loadsfile,skip=1)
#First two columns are date/time, last two are outflows
df <- df[,3:(dim(df)[2]-2),]
#Add an extra row, because it is Jan 1 to Jan 1
df[(dim(df)[1]+1),] <- df[(dim(df)[1]),]
#df should be 366(days)x80(rivers)
dim(df)
#Make sure it matches netCDF file
if (nr!=dim(df)[2]) stop("TP and netcdf: Number of rivers doesn't match")
if (nt!=dim(df)[1]) stop("TP and netcdf: Number of dates doesn't match")

#Start making the new array to put in netCDF file
# Define netCDF dimensions
dimrivers <- ncdata$dim[['rivers']]
dimtime <- ncdata$dim[['time']]

#Used for missing value
mv2 <- 1.e30

# Define the new variable
TP <- ncvar_def( name="TP", units="mg/L", dim=list(dimrivers, dimtime), missval=mv2, longname="river total phosphorus load")
ncdata <- ncvar_add( ncdata, TP )

# write the values
values <- array(0, dim=c(nr,nt))
for(itime in 1:nt){
  for(iriv in 1:nr){
    values[iriv,itime] <- as.numeric(df[itime,iriv])
  }
}

#Add the values to the nc file
ncvar_put(ncdata, varid="TP", vals=values, start=c(1,1), count=c(-1,-1), verbose=FALSE )

#Close netCDF file and clear data
nc_close(ncdata)
rm(ncdata)

#Old river file is 367.3KB and new one is 481.8KB

#Reopen the file and take a look
#read the file
ncdata <- nc_open(tpfile,write=FALSE,readunlim=FALSE)
time <- ncvar_get(ncdata, "Times", start=c(1,1), count=c(-1,-1))
time <- as.POSIXct(time, format="%Y-%m-%dT%H:%M:%S", tz="GMT")
names <- ncvar_get(ncdata, "river_names", start=c(1,1), count=c(-1,-1))
tploads <- ncvar_get(ncdata, "TP", start=c(1,1), count=c(-1,-1))
flows <- ncvar_get(ncdata, "river_flux", start=c(1,1), count=c(-1,-1))
#Check a few
plot(time,tploads[1,],type='l')
points(time,df[,1])
plot(time,tploads[40,],type='l')
points(time,df[,40])
plot(time,tploads[80,],type='l')
points(time,df[,80])

#Close netCDF file
nc_close(ncdata)
