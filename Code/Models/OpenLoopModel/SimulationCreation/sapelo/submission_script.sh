#PBS -S /bin/bash
#PBS -q batch
#PBS -l nodes=1:ppn=16:AMD
#PBS -l walltime=24:00:00
#PBS -l mem=10gb
#PBS -M cotter@uga.edu 
#PBS -m ae

####
# Submission script for BatchRun on a qsub cluster
# qsub -v data_loc='PATH/TO/ALLDATA/FILES' -N JOB_NAME Models/OpenLoopModel/SimulationCreation/sapelo/submission_script.sh 
#
# where data_loc is the path to AllData.mat and AllDataTable.mat and
# JOB_NAME is the name of the job
#
# Results are placed in ./Results/JOB_NAME/
#
# qsub should be run from inside the Code folder.
####

cd $PBS_O_WORKDIR

module load matlab/R2016b

mkdir -p Results

matlab -nojvm -nodisplay -nosplash \
     -r "addpath('Models/OpenLoopModel/SimulationCreation/'); BatchRunSimulations('Results/$PBS_JOBNAME/','${data_loc}')"  \
     > matlab_${PBS_JOBNAME}_${PBS_JOBID}.out

