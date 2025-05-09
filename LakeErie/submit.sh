#!/bin/bash
#SBATCH --job-name="le_leem"
#SBATCH --output="qstdout.%j"
#SBATCH --error="qsterr.%j"
#SBATCH --partition=compute
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128
#SBATCH --account=ncs124
#SBATCH -t 3:00:00

module load cpu/0.15.4
module load intel/19.1.1.217
module load intel-mpi/2019.8.254
module load netcdf-c/4.7.4
module load netcdf-fortran/4.5.3

#2node
/usr/bin/time -v mpirun -n 256 ./fvcom --casename=leem > leem_sinkout.out
echo "seff"
seff $SLURM_JOB_ID
echo "sacct"
sacct --jobs=$SLURM_JOB_ID --format=nnodes,ncpu,ntasks,maxrss,cputime,avecpu,maxdiskread,maxdiskwrite,maxpages
