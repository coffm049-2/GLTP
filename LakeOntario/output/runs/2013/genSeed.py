import numpy as np 
import pandas as pd
import datetime
from netCDF4 import Dataset
import random
# previously downloaded at concatenated data using the R script

particleCycles = 50
locations = 3

# set of nodes to use
nodes = np.sort(random.sample(list(range(1,34396)), locations))


fvcomGrid = Dataset("/work/GLHABS/GreatLakesHydro/LakeOntario/output/runs/2013/notlHotvisitTest_0001.nc")


# https://unidata.github.io/netcdf4-python/#attributes-in-a-netcdf-file
newNC = Dataset("lagParticles.nc", "w")
newNC.type = "Particle release file"
newNC.title = "Particles"
#templateNC.close()



number = newNC.createDimension("number", locations)
numbers = newNC.createVariable("number", "i", ("number", ))
numbers.units= "none"
ID = newNC.createVariable("ID", "i", ("number", ))
ID.units= "none"
x = newNC.createVariable("x", "f8", ("number", ))
x.units= "meters"
y = newNC.createVariable("y", "f8", ("number", ))
y.units= "meters"
z = newNC.createVariable("z", "f8", ("number", ))
z.units= "meters"

release = newNC.createVariable("release", "f8", ("number", ))
release.units="MJD"
end = newNC.createVariable("end", "f8", ("number", ))
end.units="MJD"

# MJD for test 2013 -  15796 15802

numbers[:] =  list(range(locations))
ID[:] =  list(range(locations))
x[:] = fvcomGrid.variables["x"][nodes]
y[:] = fvcomGrid.variables["y"][nodes]
z[:] = np.repeat(5, locations)
release[:] = np.repeat(15796, locations)
end[:] = np.repeat(15802, locations)

newNC.close()


