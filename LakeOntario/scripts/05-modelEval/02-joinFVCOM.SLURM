#!/bin/bash
#SBATCH -J thinModels
#SBATCH --nodes=1
#SBATCH --mem=16gb
#SBATCH -A glhabs
#SBATCH -e thinning_error
#SBATCH -o thinning_out
#SBATCH --partition=ord
#SBATCH -t 5:00:00
#SBATCH --mail-user=coffman.christian@epa.gov
#SBATCH --mail-type=all


cd /work/GLHABS/GreatLakesHydro/LakeOntario/scripts/modelEval
bash

#!/bin/bash
DIR=../../output/runs

Rscript 02-joinReal2Model.R

