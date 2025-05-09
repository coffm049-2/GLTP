#!/bin/bash

module load netcdf
module load cdo

# [x] convert to ncdf and select to lake ontario
# - can this be similar to wrf like in to 2018




#!/bin/bash

# Define the directory and extension
DIRECTORY=/work/GLHABS/GreatLakesHydro/LakeOntario/input/2013/met
EXTENSION="grb2"

# Loop through each file with the given extension in the specified directory
for FILE in "$DIRECTORY"/*."$EXTENSION"; do
    # Check if the file exists to avoid errors if no files match the pattern
    if [ -e "$FILE" ]; then
        echo "Processing $FILE"
        # Add your commands here, for example:
        # cat "$FILE"
        cdo -f nc4 sellonlatbox,-80.92,-75.19,42.72,44.49 $FILE $FILE.selected.nc
        # mv "$FILE" /path/to/destination/
    else
        echo "No files with the extension .$EXTENSION found in $DIRECTORY"
    fi
done


# Don't need to convert to FVCOM grid because FVCOM can do that on the fly
# [x] Make sure format looks like wrf format
# - Thinking this shouldn't be helped by subsetting ahead...
#ncremap -m $MAP pressfc.cdas1.201301.grb2.nc4 pressfc.cdas1.201301.regrid.nc

