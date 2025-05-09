#!/bin/csh
#SBATCH -J test_visit
#SBATCH -t 00:10:00
#SBATCH --ntasks=1
#SBATCH -A glhabs
#SBATCH -e stderr.%j
#SBATCH -o stdout.%j
cd /work/GLHABS/visit-for-fvcom
module load visit
visit -cli -nowin -s plot_any.py
