###
# Wrapper script for submission_script.sh that copies code
# to Results/JOB_NAME then runs qsub on that code. 
#
# Useful for keeping a history of what code a simulation was run on
# and if one wants to submit mutiple jobs with different code bases
# without needing to wait for the jobs to start
#
# Should be run from the Code/ directory.
###

if [ "$#" -ne 2 ]; then
    echo "usage: run_batch.sh JOB_NAME DATA_FOLDER"
    exit
fi

JOB_NAME=${1}
DATA_FOLDER=$(readlink -m ${2})

RESULTS_FOLDER=Results/$JOB_NAME

mkdir -p $RESULTS_FOLDER/Models
mkdir -p $RESULTS_FOLDER/Libraries
mkdir -p $RESULTS_FOLDER/Results

cp -r Models/ClosedLoopModel $RESULTS_FOLDER/Models/
cp -r Models/ModelBase $RESULTS_FOLDER/Models/
cp -r Libraries/Utils $RESULTS_FOLDER/Libraries/

cd $RESULTS_FOLDER
qsub -v data_loc=$DATA_FOLDER -N $JOB_NAME Models/ClosedLoopModel/SimulationCreation/sapelo/submission_script.sh