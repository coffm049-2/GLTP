
Initial conditions for biological model
- init20XXloem.dat Taken from Limnotech models
  - Selected only relevant species
  - `01a-loem2fvcom.jl` converts from loem 2 fvcom but keeps depth
  - `01b-icsForTom.jl` removes depth so Tom can convert from EFDC to FVCOM grid
    - It's OK to assume uniform distribution across water column dpeth
  - After Tom converts

- `02-lotp2fvcom.jl`  converts lotp IC directly to FVCOM format
  - copy and paste the output to `input/NUTRIENT_INI_1.dat` and `input/DETRITUS_INI_1.dat` for model run
  - make sure to add the single line at the top of the file saying "DATA"
  - So the final IC file will look like

```bash
DATA
0.1 0.5 ...
...
0.5 0.1 ...
```
