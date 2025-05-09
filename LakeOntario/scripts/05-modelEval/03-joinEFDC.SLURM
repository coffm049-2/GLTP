#!/bin/bash
#SBATCH -J joinEFDC
#SBATCH --nodes=1
#SBATCH --mem=16gb
#SBATCH -A glhabs
#SBATCH -e joinEFDC_error
#SBATCH -o joinEFDC_out
#SBATCH --partition=ord
#SBATCH -t 6:00:00
#SBATCH --mail-user=coffman.christian@epa.gov
#SBATCH --mail-type=all


cd /work/GLHABS/GreatLakesHydro/LakeOntario/scripts/modelEval
bash

#!/bin/bash
DIR=../../output/runs

Rscript 03-joinEFDC.R

