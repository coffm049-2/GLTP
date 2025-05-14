#!/bin/csh
#SBATCH -J matchData
#SBATCH -t 00:30:00
#SBATCH --ntasks=1
#SBATCH -A glhabs
#SBATCH --mem=32gb
#SBATCH -e stderr.%j
#SBATCH -o stdout.%j

# salloc --mem=32gb

bash
source ~/.bashrc
cd /work/GLHABS/GreatLakesHydro/LakeOntario/scripts/04-observationalData
Rscript combineModelSites.R
