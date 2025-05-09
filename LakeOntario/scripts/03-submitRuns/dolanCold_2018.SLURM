#!/bin/bash
#SBATCH -J dolanCold2018
#SBATCH --ntasks=32
#SBATCH --mem=100gb
#SBATCH -A glhabs
#SBATCH -e dolanCold2018_error
#SBATCH -o dolanCold2018_out
#SBATCH --partition=ord
#SBATCH -t 65:00:00
#SBATCH --mail-user=maurer.julie@epa.gov
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

mpiexec -n 31 fvcom_modded --casename=runs/2018/dolanCold
