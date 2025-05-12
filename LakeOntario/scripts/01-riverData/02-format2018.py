import numpy as np 
import pandas as pd
import datetime
from netCDF4 import Dataset

# previously downloaded at concatenated data using the R script
df = pd.read_csv("../../input/2018/rivers2018_temp_tp_flow.csv")
df["dateTime"] = pd.to_datetime(df["dateTime"], utc = False)

dfstLaw = pd.read_csv("../../input/2018/stLaw2018.txt", sep = "\t", header = None)
dfstLaw.columns = ["datetime", "discharge"]
dfstLaw["flow"] = dfstLaw.discharge * 0.0283
dfstLaw["siteName"] = "stlawrence"
dfstLaw["temp"] = 0
dfstLaw["TP"] = 0
dfstLaw["dateTime"] = pd.to_datetime(dfstLaw["datetime"], utc = True)
# [x] Convert date

df = pd.concat([df, dfstLaw], axis = 0)
df["dateTime"] = pd.to_datetime(df["dateTime"], utc = True)
df = df[["siteName", "dateTime", "flow", "temp", "TP"]]


# potentially it's from 1858,11,17
startDate = pd.to_datetime("1858-11-17T00:00:01", utc = True)
df["Itime"] = (df.dateTime- startDate).dt.days
# seeing if we don't need to impute, but can let FVCOM
#df = df.iloc[df.index.repeat(24), :]
df["Itime2"]  = 0
rivers = np.unique(df.siteName)
rivers =rivers[[0,1,2,3,4, 8,9,10,11]]

# Copy each loading scenario as a new set of columns
df = df.pivot(index=["dateTime", "Itime", "Itime2"], columns = ["siteName"], values=  ["flow", "temp", "TP"]).reset_index()

# divide flows to make sure they are spread across multiple nodes
# also make sure values are added to new river names in stlawrence
df["flow", "stlawrenceusa"] = df["flow", "stlawrence"] / 3
df["flow", "stlawrencecan"] = df["flow", "stlawrence"] / 3 * 2
df["TP", "stlawrenceusa"] = df["TP", "stlawrence"]
df["TP", "stlawrencecan"] = df["TP", "stlawrence"]
df["temp", "stlawrencecan"] = df["temp", "stlawrence"]
df["temp", "stlawrenceusa"] = df["temp", "stlawrence"]
df["flow", "niagara-loem"] = df["flow", "niagara-loem"] / 5
df["flow", "niagara-dolan"] = df["flow", "niagara-dolan"] / 5
df["flow", "niagara-notl"] = df["flow", "niagara-notl"] / 5

# divide niagara and st lawrence into number of different nodes
# lsplit flow evenly between them 
# NOTE could try with outter 2 having 1/2 flow
riverNames = {riv : 1 for riv in np.unique(df.columns.get_level_values(1)) if riv not in ["niagara-loem", "niagara-notl", "niagara-dolan", "stlawrencecan", "stlawrenceusa"] and riv !=""}
riverNames["niagara-loem"] = 5
riverNames["niagara-dolan"] = 5
riverNames["niagara-notl"] = 5
# 3 for usa and 6 for canada
riverNames["stlawrenceusa"] = 3 
riverNames["stlawrencecan"] = 6

riverVals = {riv + str(i + 1).zfill(2) : df.loc[:, (slice(None), riv)] for riv, nnodes in riverNames.items() for i in range(nnodes)}

timeDF = df[[("Itime", ""), ("Itime2", "")]]
timeDF.columns = timeDF.columns.get_level_values(0)


fluxDF = np.array([data.loc[:, ("flow", slice(None))] for data in riverVals.values()])[:, :, 0]
tempDF = np.array([data.loc[:, ("temp", slice(None))] for riv, data in riverVals.items()])[:, :, 0]
tp = np.array([data.loc[:, ("TP", slice(None))] for riv, data in riverVals.items()])[:, :, 0]

# https://unidata.github.io/netcdf4-python/#attributes-in-a-netcdf-file
newNC = Dataset("../../input/2018/rivers2018.nc", "w")
newNC.type = "FVCOM TIME SERIES RIVER FILE"
newNC.title = "Rivers"
#templateNC.close()
rivername = newNC.createDimension("namelen", 26)
rivers = newNC.createDimension("rivers", len(riverVals.keys()))
time = newNC.createDimension("time", None)

Itime = newNC.createVariable("Itime", "i", ("time",))
Itime.units= "days since 1858-11-17 00:00:00"
Itime.time_zone = "UTC"
Itime.format = "modified julian day (MJD)"
Itime2 = newNC.createVariable("Itime2", "i", ("time",))
Itime2.units = "msec since 00:00:00"
Itime2.time_zone = "UTC"
flux = newNC.createVariable("river_flux", "f8", ("time","rivers"))
flux.long_name = "River runoff volume flux"
flux.units = "m^3s^-1"
TP = newNC.createVariable("TP", "f8", ("time","rivers"))
TP.units = "mg/L"
river_names = newNC.createVariable("river_names", "S1", ("rivers", "namelen"))
river_names.long_name = "Rivers Name"
temp = newNC.createVariable("river_temp", "f8", ("time", "rivers"))
temp.key =  "0001: ; constant 5; 0002: usgs: station 0431600; 0003: usgs: station 04249000"
temp.long_name = "River runoff temperature"
temp.units = "Celsius"
salt = newNC.createVariable("river_salt", "f8", ("time", "rivers"))
salt.key = "0001: constant 0"
salt.long_name = "River runoff salinity"
salt.units = "PSU"
src_flow = newNC.createVariable("src_flow", "f8", ("time", "rivers"))
src_flow.key = "0001: eccc: station 02HC003; constant 0; 0002: eccc: station 02HC024; constant 0; 0003: recon: station lnr; 0004: recon: station slm (linscale 0.5x + 0.0); constant 3100; 0005: usgs: station 04231600; 0006: usgs: station 04249000; 0007: usgs: station 04250200; 0008: usgs: station 04260500"
src_salt = newNC.createVariable("src_salt", "f8", ("rivers"))
src_salt.key = "0001: constant 0"
src_temp = newNC.createVariable("src_temp", "f8", ("time", "rivers"))

Itime[:] = timeDF.Itime
Itime2[:] = timeDF.Itime2
flux[:,:] = fluxDF.T
src_flow[:,:] = fluxDF.T
temp[:,:] = tempDF.T
src_temp[:,:] = tempDF.T
TP[:,:] = tp.T
salt[:,:] = np.zeros(tempDF.T.shape)
src_flow[:,:] = fluxDF.T
src_salt[:] = 0

# [x] RETURN TO THIS, MIGHT HAVE TO FILL OUT ALL RANDOM VARIABLES IN ORDER FOR IT TO WORK

river_names[:, :] =   np.array([list(x.ljust(26, " ")) for x in riverVals.keys()])
newNC.close()

