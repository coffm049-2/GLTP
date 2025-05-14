
# Directory contents
- [archive](archive) - old files no longer relevant
- [GLENDA.R](GLENDA.R) - function to process Glenda data
- [01-nodeMapping.R](01-nodeMapping.R) - map the observational data to FVCOM and EFDC nodes
- [02-matchData.SLURM](02-matchData.SLURM) - match all observational data to the model output. Calls `matchData.R`
- [02-matchData.R](02-matchData.R) - match all observational data to the model output
- [03-joinCurrent2Models2018.R](03-joinCurrent2Models2018.R) - joining current data to compare with bouy datas. defunct for now for lack of bouy data


After joining the data follow up with summaries and vizualilzations in the `/work/GLHABS/ontarioHydroViz/`
