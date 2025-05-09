Run FVCOM (with the bio model on) until March 1st, get a restart dump with metadata from that date:
```
/expanse/lustre/projects/ncs124/llowe/HYDRO/run/restart/leem_restart_0001.nc
```

Run FVCOM one timestep, have a restart dump at the same time as the run start.  This is to get the TP initial conditions from the DETRITUS file into netCDF format.
```
/expanse/lustre/projects/ncs124/llowe/HYDRO/run/output/leem_restart_0001.nc
```

Copy somewheres safe:
```
cd
mkdir leem_restart
cd leem_restart
cp /expanse/lustre/projects/ncs124/llowe/HYDRO/run/restart/leem_restart_0001.nc ./leem_restart_march1.nc
cp /expanse/lustre/projects/ncs124/llowe/HYDRO/run/output/leem_restart_0001.nc ./leem_restart_jan1.nc
```

Replace TP values in March 1st with that of first timestep.  First, make a copy of the one to write to.
```
cp leem_restart_march1.nc restart_tp.nc
```

This replaces the TP values from March 1st with those of January first (the initial conditions).
```
ncks -A -v TP leem_restart_jan1.nc restart_tp.nc
```

Copy it to the input directory for the runs
```
cp restart_tp.nc /expanse/lustre/projects/ncs124/llowe/FVCOM/simulations/input/
```

Save a copy locally and look at it in VisIt to check things.  Check both TP and temperature.
