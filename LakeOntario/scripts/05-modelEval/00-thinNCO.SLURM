#!/bin/bash
#SBATCH -J thinModels
#SBATCH --nodes=1
#SBATCH --mem=8gb
#SBATCH -A glhabs
#SBATCH -e thinning_error
#SBATCH -o thinning_out
#SBATCH --partition=ord
#SBATCH -t 36:00:00
#SBATCH --mail-user=coffman.christian@epa.gov
#SBATCH --mail-type=all

# Fixed NOAA zip files
# https://superuser.com/questions/839711/cannot-open-large-concatenated-zip-file-with-unzip-though-it-opened-fine-with-a
# in shell
# cd /work/GLHABS/GreatLakesHydro/LakeOntario/noaaModel
# for i in {1..7}
# do
#   zip -FF 20180${i}.zip -O 20180${i}.fixed.zip
# done
# unzip '*.fixed.zip'
# rm *.fixed.zip


cd /work/GLHABS/GreatLakesHydro/LakeOntario/scripts/modelEval

module load nco
#!/bin/bash
DIR=../../output/runs

# DONE 
# ncks -v lat,lon,h,art1 $DIR/fvcom_0001.nc \
#   -O --output $DIR/gridData.nc
# ncks -v latc,lonc $DIR/fvcom_0001.nc \
#   -O --output $DIR/neleData.nc

# [ ] compare ice coverage for Aril 10 (day 100, 11am) and november 16 (day 320, 11pm)
# [ ] Take picture
# [ ] compute ice coverage

# Already done
# don't subset variables becuase it breaks Visi
# ncra $DIR/fvcom_0001.nc \
#   --dmn time,$((100 * 24 + 11)) \
#   -O --output $DIR/modelIceApril10.nc
# ncra $DIR/fvcom_0001.nc \
#   --dmn time,$((320 * 24 + 23)) \
#   -O --output $DIR/modelIceNov16.nc
# # # 2/5 - 36 
# ncra $DIR/fvcom_0001.nc \
#   --dmn time,$((36 * 24 + 12)) \
#   -O --output $DIR/modelIceFeb5.nc
# # 3/14 - 073
# ncra $DIR/fvcom_0001.nc \
#   --dmn time,$((73 * 24 + 12)) \
#   -O --output $DIR/modelIceMar14.nc

while read node ; do
  # full time for node matched model
  echo "$node"
  ncrcat -v temp $DIR/fvcom_0001.nc \
    -O --output $DIR/node${node}Temp.nc \
    --dmn node,$node
done < ../../realData/fvcomCompareNodes

# Need to load each node time series using a loop


# thinned data for vizualization of model comparison with map
# grab temperature at 12 noon
ncrcat -v temp $DIR/fvcom_0001.nc \
  -O --output $DIR/daytimeVolData.nc \
  --dmn node,1,34395,20 \
  --dmn time,12,,24
#--dmn time,12,,24


#%% ZONAL matched data

#    --dmn node,1,34395,50

# full data for zonal matched model
# ncrcat -v latc,lonc,u,v $DIR/fvcom_0*.nc \
#   -O --output $DIR/vecData.nc

# thin data for zonal matched model
# ncrcat -v latc,lonc,u,v $DIR/fvcom_0*.nc \
#   -O --output $DIR/vecData.nc
#    --dmn node,1,34395,50


# Create daily averages
# i
