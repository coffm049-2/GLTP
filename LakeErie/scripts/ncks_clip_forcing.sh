# L3, 2023
# ncks.sh: commands to clip forcing files
# To use hotstart for fvcom, clip forcing files to match the first day
# This is for bash-like shells.  For csh-like shells replace "export=" with "setenv "
# You also have to have ncks in your path.  A 'module load netcdf' usually has that.
#Note:
# I recommend pasting these one by one, rather than actually running it as a script,
#    since there is no error checking and you should stop if you get an error.
#    Also to prevent accidentally overwrite something.
# But to run as a script, change paths then do "source ncks_clip_forcing.sh"

# Path to full year FVCOM model inputs (input_hydro)
export ORIGDIR="/Users/lllowe/LakeErie/TPmodel/simulations/input/full_year"
#Check it
echo $ORIGDIR
ls -lh $ORIGDIR

# Clipped inputs for running TP model
export TPDIR="/Users/lllowe/LakeErie/TPmodel/simulations/input"
#Check it
echo $TPDIR
ls -lh $TPDIR

#Get subset of original forcing files to allow restart dumps
#This is for Jan 1 - March 1st for non-leap year, until the next Jan 1
ncks -d time,1416,8782 $ORIGDIR/2013_leem_fine_forcing.nc $TPDIR/2013_leem_fine_forcing.nc
ncks -d time,59,365 $ORIGDIR/2013_leem_fine_julian_obc.nc $TPDIR/2013_leem_fine_julian_obc.nc
ncks -d time,59,365 $ORIGDIR/2013_leem_fine_river_data.nc $TPDIR/2013_leem_fine_river_data.nc

#Check it
ls -lh $TPDIR
