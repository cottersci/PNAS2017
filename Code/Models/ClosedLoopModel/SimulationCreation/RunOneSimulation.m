%%% Setup Variables
%%%%%%%%%%%%%%%%%%%
addpath('Models/ModelBase')
addpath('Models/ClosedLoopModel/ClosedLoop')
addpath('Models/ModelBase/SimulationCreation')
addpath('Libraries/Utils')

DATA_LOCATION = 'Data/WTinWT/';
RESULTS_LOCATION = 'Results/';
folder_name = 'FOLDER_NAME';
prerun = 180;
Nruns = 3;

load([DATA_LOCATION 'AllDataTableAligned.mat'])
prs = 0;
mkdir([RESULTS_LOCATION folder_name]);

%%% Generate Probs
%%%%%%%%%%%%%%%%%%  
[Mdlb, Mdlr, Mdlst, Init] = create_search_trees(AllDataTable);
probs = ClosedLoopProbs(Mdlb,Mdlr,Mdlst,Init,prerun);

%%% Run Simulations
%%%%%%%%%%%%%%%%%%%
E = ClosedLoop(probs,10000,'bandwidth',14);
E.loop(600 + prerun);

%% Save Results
data = E.exportData();
sim_tracks =  E.exportTracks();
save([RESULTS_LOCATION folder_name '/sim_tracks-' num2str(run)],'sim_tracks');
save([RESULTS_LOCATION folder_name '/sim_data-'  num2str(run)],'data');