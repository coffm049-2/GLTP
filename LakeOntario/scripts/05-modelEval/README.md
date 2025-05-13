
DRamatically reduced what's going on in this directory because of the efficiencies made with smaller model output 
and not having gotten 2018 bouy data yet.

- [01-joinData2Models.R](01-joinData2Models.R) - Join EFDC and FVCOM model data to observed data (need to look into EFDC if it's joining right, it has a lot of missingness
- [02-joinCurrent2Models2018.R](02-joinCurrent2Models2018.R) - same thing but for bouy data (current and high temporal resolution temperature data)[Currently no bouy data for 2018]


After running 01-joinData2Models.Rrun the analysis script in /work/GLHABS/ontarioHydroViz/vizualizing.qmd


