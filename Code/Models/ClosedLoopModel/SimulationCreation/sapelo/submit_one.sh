#PBS -S /bin/bash
#PBS -q batch
#PBS -N SimRun1
#PBS -l nodes=1:ppn=4:AMD
#PBS -l walltime=12:00:00
#PBS -l mem=5gb
#PBS -M cotter@uga.edu 
#PBS -m ae

cd $PBS_O_WORKDIR

module load matlab/R2016b

matlab -nodisplay < Models/ClosedLoopModel/SimulationCreation/RunOneSimulation.m > matlab_${PBS_JOBID}.out

