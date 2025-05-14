# README

Notes and scripts for the Great Lakes Models. I will also try to write READMEs for each directory with more specific instructions

## Contents
- [FVCOM executable](fvcom_modded)
- [Nooa 2018 model results](noaaModel)
- [output](output) - directory storing the relevant simulation outputs
    - Data stored in subdirectores to keep scenarios separate
- [PTrack](Lagrangian particle tracking executable)
- [Observational data for real world evaluation](realData)
- [scripts](scripts) most scripts needed to preprocess, run, and evaluate the models
- [input](input) - stores all inputs necessary for the model (except run files) and are stored by year
- [oldModels](oldModels) - Directory storing old FVCOM executables beauasI was too scared to delete them just in case...
- [partTracking](partTracking) - run files for particle tracking expeirments
- [runs](runs) - Run files for simulation scenarios separated by year
- [venv](venv) - python virtual environemnt needed to run the Python scripts (.py)
- [xxxModules.sh](xxxModules.sh) - scripts to load the necessary environment for the simulations. Load in bash by calling `source xxxModules.sh`


Other Links:
- [visit-tp-compare](https://github.com/l3-hpc/visit-tp-compare) - create images and movies from TP model or TP-(as function of LEEM) model
- [shiny-le](https://github.com/l3-hpc/shiny-le) - Code for R Shiny app
- [visit-scripts](https://github.com/l3-hpc/visit-scripts) - general visit scripts, [including a script](https://github.com/l3-hpc/visit-scripts/blob/main/sample-movie-scripts/README_LE.MD) to make images and movies of every LEEM variable
- [BIO_TP](https://github.com/l3-hpc/BIO_TP) - the TP bio model for FVCOM
- [shiny-le/README.md](https://github.com/l3-hpc/shiny-le/blob/main/README.md): Readme has notes to create netCDF with TP derived from LEEM quantities


# General order of operations
Also, check the directories where these scripts are stored because the each have an additional README file with additional information
0. [Get pip](scripts/get-pip.py)
1. Compile data
    a. Meteorological - Got this all from NOAA and Michigan Tech
    b. [Rivers](scripts/01-riverData/README.md)
        - Download using Julie's script
        - Format- `scripts/riverData/*`
        - Make namelist file make sure to choose the right river names for your scneario
            - Most rivers stay the same, Niagara hase different scenarios so their names are somehitng like "dolanNiagara01"
    c. [Initial conditions](scripts/02-makeInits/README.md)
        - `scripts/02-makeInits`
        - LOTP (script `02-lotp2fvcom.jl` returns and output that is ready for FVCOM after adding the first line "DATA" to the file)
            - `/work/GLFBREEZ/Lake_Ontario/Initial_Conditions/2013/Initial_Conditions_2013_final.nc`
            - `/work/GLFBREEZ/Lake_Ontario/Initial_Conditions/2018/Initial_Conditions_2018.nc`
        - LOEM (script `01a-loem2fvcom.jl 01b-icsForTom.jl` first one converts from nc to csv, second eliminates depth so Tom can transform to FVCOM grid)
            - `/work/GLFBREEZ/LOEM/2013_simulation/inputs/ic.inp`
            - `/work/GLFBREEZ/LOEM/2018_simulation/Inputs/ic.inp`
        - After making the initial conditions to copy it to the "NUTRIENT_INI_1.dat" and "DETRITUS_INI_1.dat" files in input directory
            - This means that you will need to remember to swap out this file when changing between 2013 and 2018
2. Create run files and scripts
    a. run files (`runs/YEAR/scenario_run.nml`)
        - Set begin and end dates `START_DATE END_DATE`
        - Note that we ran up to April 1st then are restarting for each scenario
            - If hotstart make sure to set `STARTUP_TYPE = hotstart, STARTUP_FILE STARTUP_UV_TYPE STARTUP_TURB_TYPE STARTUP_TS_TYPE`
        - Set correct river file `RIVER_INFO_FILE`
    b. river files (`input/YEAR/riversYear.nc`)
    c. slurm scripts copy a previous SLURM script and find and replace for you new scenario
        - `:%s/OLDRUN/NEWRUN/` followed by enter
    d. Coreolis file- do to quirks about FVCOM you will need to create a new coreolis file each time you make a new run file
        - Say you have "runs/2013/newRun_run.nml" you then need to make sure to have "input/2013/newRun_cor.dat". You can just copy one of the old _cor files to the new position because it doens't change
3. [Run model](scripts/03-submitRuns)
    - test for a couple time steps 
        - Do this interactively `salloc -n 24` then submit the script right in terminal
    - test it for 2 weeks before entire run (using a batch submission)
4. Create Visit videos
    - Make sure you remembner to project the output files from [LatLon to xy](output/runs/REAMDE.md)
    - Not too much help here besides Lisa's scripts above...
5. [Assemble observational data](scripts/04-observationalData)



# Model considerations
- Always check model with a 2 week run first before simulating the entire run
- Want to compare cold start (with constant initial conditions) to hot start (with modeled initial conditions)
- Initial conditions derived from Limnotech's LOEM model
    - Also, want it from Previous TP model
- 

## Niagara 
- vertical mixing
	- from limnotech "qser.inp"
	- Niagara is deep compared to immediate outlet into lake
	- limnotech modeled this as only the top half of the niagara as flowing 
- horizontal
	- boundaries 1/2 flow of other nodes (not implemented)
nodes listed from west to east
841
842
843
844
845



## st lawrence 
- Grabbed flow from USGS and split in half to cover canada
nodes list from north to south
North nodes
22542
22541
22539
22270
22269
21986
21987
21685
21371
21046

South nodes
15386
15383
15384
15385


# Particle Tracking
- It's functional and lives at
	- Don't have viz or analysis scripts
- `/work/GLHABS/Particle_Tracking`


