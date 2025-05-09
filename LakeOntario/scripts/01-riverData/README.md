These files take rivers csvs and create river netcdfs appropriate for FVCOM


If you change the compiled river csv file just make sure to update on the 4th line 
`df = pd.read_csv("../../input/2013/rivers/rivers2013_TP_JM_narm_lotpflows.csv")`

run from the command line in this directory with

```bash
source ../../physicsModules.sh
julia 01-format2013.py
julia 02-format2018.py
```

This will store river2013.nc and rivers2018.nc in `input/2013/rivers/rivers2013.nc` and `input/2018/rivers2018.nc`.

If you're adding new rivers make sure to update the corresponding river name files at 

- `input/2013/rivers/<scenario>2013.nml`
- `input/2018/<scenario>2018.nml`

