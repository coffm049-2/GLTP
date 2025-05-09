#!/bin/bash
#SBATCH -J pre2013
#SBATCH --ntasks=24
#SBATCH --mem=100gb
#SBATCH -A glhabs
#SBATCH -e pre2013_error
#SBATCH -o pre2013_out
#SBATCH --partition=ord
#SBATCH -t 35:00:00
#SBATCH --mail-user=coffman.christian@epa.gov
#SBATCH --mail-type=all


# for debugging
# salloc --ntasks=16


# 8 nodes is good becuase it takes up one whole cpua
# 16 tasnks per node on new Atmos setup

# 1 hour to test a week
# 32 hours to get therou 7/30
# 64 hours to assure full year run

# To change how many tasks, only change the number of nodes

cd /work/GLHABS/GreatLakesHydro/LakeOntario
source /work/GLHABS/GreatLakesHydro/physicsModules.sh

mpiexec -n 24 fvcom_modded --casename=runs/pre2013
