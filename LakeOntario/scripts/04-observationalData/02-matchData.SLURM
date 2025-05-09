#!/bin/csh
#SBATCH -J matchData
#SBATCH -t 08:00:00
#SBATCH --ntasks=1
#SBATCH -A glhabs
#SBATCH --mem=0
#SBATCH -e stderr.%j
#SBATCH -o stdout.%j

bash
source ~/.bashrc
cd /work/GLHABS/GreatLakesHydro/LakeOntario/scripts/processData
Rscript combineModelSites.R
