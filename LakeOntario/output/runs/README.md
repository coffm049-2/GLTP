To project data onto XY (from Lat Lon) call `xy_fromLonLat.R`. This will make all subsequent analyses more convenient.

Example to project file "2018/file_0001.nc" do the following (make sure you have the Rmodule loaded and any necessary R packages installed, check the libraries used at the beginning of the Rscript to know which are needed)

```bash
Rscript xy_fromLat.R 2018/file_0001.nc
```
The XY coordinates will now be populated in the `2018/file_0001.nc` file. (i.e. no new file is made, the existing file is simply augmented with the new coordinates)

An example bash script is contained in the `convertCoords.sh`
