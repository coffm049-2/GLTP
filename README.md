# README

Notes and scripts for the Great Lakes Models

## Contents

### Lake Erie

In the Lake Erie folder
- [Restarts](https://github.com/l3-hpc/GreatLakes/blob/main/LakeErie/Restarts.md): How to create a restart file to set the initial conditions(ICs) to match LEEM ICs.
- [run](LakeErie/run.md) - notes for compiling and running on Expanse at SDSC
- [submit.sh](LakeErie/submit.sh) - SLURM batch script for Expanse

**data**
- [TP_ZOO_Loads.csv](LakeErie/data/TP_ZOO_Loads.csv): Phosphorus loading, including Zooplankton component

**scripts**
- [add-tp-river-loads.R](LakeErie/scripts/add-tp-river-loads.R): R script to add TP loads to river forcing file
- [ncks_clip_forcing.sh](LakeErie/scripts/ncks_clip_forcing.sh): Clip forcing files in order to run FVCOM as 'restart' from March 1


Other Links:
- [visit-tp-compare](https://github.com/l3-hpc/visit-tp-compare) - create images and movies from TP model or TP-(as function of LEEM) model
- [shiny-le](https://github.com/l3-hpc/shiny-le) - Code for R Shiny app
- [visit-scripts](https://github.com/l3-hpc/visit-scripts) - general visit scripts, [including a script](https://github.com/l3-hpc/visit-scripts/blob/main/sample-movie-scripts/README_LE.MD) to make images and movies of every LEEM variable
- [BIO_TP](https://github.com/l3-hpc/BIO_TP) - the TP bio model for FVCOM
- [shiny-le/README.md](https://github.com/l3-hpc/shiny-le/blob/main/README.md): Readme has notes to create netCDF with TP derived from LEEM quantities

Other Notes:

- For VisIt, comparing with LEEM:
```
DefineScalarExpression("TP_tot", "RPOP + LPOP + RDOP + LDOP + PO4T + LPIP + RPIP + (ZOO1 + ZOO2 + ZOO3)/50.0")
```

