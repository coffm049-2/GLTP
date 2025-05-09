from glob import glob
import numpy as np 
import pandas as pd
from netCDF4 import Dataset
import termplotlib as tpl
import math
#from skimage.measure import block_reduce

#%% [ ] Load real data

#%% [ ] Load model data (volume)
nodeThinning = 1
gltedFiles = sorted(glob("/work/GLHABS/GreatLakesHydro/LakeOntario/output/runs/fvcom*.nc"))
output = "/work/GLHABS/GreatLakesHydro/LakeOntario/output/runs/glted_resid.nc"
data = Dataset(gltedFiles[0])

timeData = data.get_variables_by_attributes(name=lambda v: v in ['Itime', 'Itime2'])
nodeData = data.get_variables_by_attributes(name=lambda v: v in ['node', 'lat', 'lon', 'h', 'art1'])
nodeTimeData = data.get_variables_by_attributes(name=lambda v: v in ['zeta', 'vice'])
volData = data.get_variables_by_attributes(name=lambda v: v in ['temp', 'TP'])




grid = np.array([
  data.variables.get("art1"),
  data.variables.get("h"),
  data.variables.get("lat"),
  data.variables.get("lon")
]).T
#grid = (grid- np.min(grid, axis = 0))/(np.max(grid, axis = 0) - np.min(grid, axis = 0))
grid = pd.DataFrame(grid, columns= ["area", "depth", "lat", "lng"])
grid["volume"] = grid.area * grid.depth
grid["nodenumber"] = [*range(grid.depth.shape[0])]
grid = grid.iloc[::nodeThinning, ]

# Set up dimensions and variables
NC = Dataset(output, "w")
dimTime = NC.createDimension("time", None)
dimSig = NC.createDimension("siglay", 20)
dimNode = NC.createDimension("node", math.ceil(grid.shape[0]))
dimEle= NC.createDimension("nele", math.ceil(64453/ (nodeThinning*2)))
# node Variables
nodenumber = NC.createVariable("nodenumber", "i", ("node"))
depth = NC.createVariable("depth", "f8", ("node"))
volume = NC.createVariable("volume", "f8", ("node"))
lat = NC.createVariable("lat", "f8", ("node"))
lng = NC.createVariable("lng", "f8", ("node"))
Date = NC.createVariable("Date", "i", ("time",))
Date.units= "days since 1858-11-17 00:00:00"
Temp = NC.createVariable("temp", "f8", ("time","siglay", "node"))
Temp.units = "deg C"
SurfElev = NC.createVariable("zeta", "f8", ("time", "node"))
SurfElev.units = "m"
SurfElev.long_name = "Water surface elevation"
ice = NC.createVariable("vice", "f8", ("time", "node"))
ice.units = "m"
area = NC.createVariable("art1", "f8", ("node"))
area.units = "m^2"
nodenumber[:] = grid.nodenumber
lat[:] = grid.lat
lng[:] = grid.lng
depth[:] = grid.depth
volume[:] = grid.volume
if includeTP :
  TP = NC.createVariable("TP", "f8", ("time","siglay", "node"))
  TP.units = "mg/L"

# zone variables:
latc = NC.createVariable("latc", "f8", ("nele"))
lonc = NC.createVariable("lonc", "f8", ("nele"))
latc[:] =  data.variables.get("latc")[::(nodeThinning*2)]
lonc[:] =  data.variables.get("lonc")[::(nodeThinning*2)]
v = NC.createVariable("v", "f8", ("time", "siglay", "nele"))
v.units = "meters s-1"
v.long_name = "Northward Water Velocity"
u = NC.createVariable("u", "f8", ("time", "siglay", "nele"))
u.units = "meters s-1"
u.long_name = "Eastward Water Velocity"
print("Finished initial setup")
# Assemble glted data
for index, file in enumerate(modelFiles) :
  print(file)
  data = Dataset(file, "r")
  # For daily files
  # NOTE this is only grabbing average daily values
  # np mean is for smoothing to single days
  # ::20 grabs every 20th node
  Temp[index, :, :] = np.mean(data.variables.get("temp")[:,:,::nodeThinning], axis=0)
  Date[index] = data.variables.get("Itime")[0]
  SurfElev[index, :] = np.mean(data.variables.get("zeta")[:,::nodeThinning], axis=0)
  u[index, :, :] = np.mean(data.variables.get("u")[:,:,::(nodeThinning * 2)], axis = 0)
  v[index, :, :] = np.mean(data.variables.get("v")[:,:,::(nodeThinning * 2)], axis = 0)
  ice[index, :] = np.mean(data.variables.get("vice")[:,::nodeThinning], axis=0)
  if includeTP :
    TP[index, :, :] = np.mean(data.variables.get("TP")[:,:,::nodeThinning], axis=0)
  data.close()

NC.close()


#%% [ ] Join data
#%% [ ] create residuals

#%% [ ] save residuals (fill with NAs)

#%% [ ] save minimal file to see if full model run is feasible to save together
