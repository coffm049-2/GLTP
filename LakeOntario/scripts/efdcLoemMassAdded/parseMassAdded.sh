#!/bin/bash -l

FILEPATH=/work/GLFBREEZ/LOEM/2013_simulation/inputs/output_rca/rca.out
#FILEPATH=/work/GLFBREEZ/LOEM/2013_simulation/outputs/rca.out
grep "TOTAL MASS" $FILEPATH | awk '{print $6,$8, $(NF+1)="Original"}' > totalMassAdded.txt


FILEPATH=/work/GLFBREEZ/LOEM/2013_simulation/inputs/output/rca.out
grep "TOTAL MASS" $FILEPATH | awk '{print $6,$8, $(NF+1)="Atmos"}'  >> totalMassAdded.txt
