%%%
% Prepares data from AllDataTable to be used in model and creates a Probabilites object for use in model.
%%%
addpath('Models/ModelBase')
addpath('Models/ModelBase/Analysis')
addpath('Models/OpenLoopModel/OpenLoop')
addpath('Models/OpenLoopModel/SimulationCreation')
addpath('Libraries/Utils')

load '/Volumes/Scratch/Chris/Paper2_Rippling/Results/Development/WT in WT/AllDataTable.mat'
load '/Volumes/Scratch/Chris/Paper2_Rippling/Results/Development/WT in WT/AllData.mat'
load '/Volumes/Scratch/Chris/Paper2_Rippling/Results/Development/WT in WT/10282015/Kum.mat'
set = 1;

%% Generate Probs
%%%%%%%%%%%%%%%%%%
[Mdlb, Mdlr, Mdlst, Init] = create_search_trees(AllDataTable(AllDataTable.set == set,:));

probs = Probabilities(Mdlb,Mdlr,Mdlst);

%% Concatonate densites and tracks to align them between movies
Kmodel = Kum(:,:,AllData{set}.AlignedStart:AllData{set}.AlignedStop);
agg_tracks = AllData{set}.agg_tracks;
agg_tracks = subStruct(agg_tracks,agg_tracks.frame >= AllData{set}.AlignedStart & agg_tracks.frame <= AllData{set}.AlignedStop);
agg_tracks.frame = agg_tracks.frame - AllData{set}.AlignedStart;

%%
% The follwoing code is an example of how to create a closed loop model and
% tests all major fuctions of the simulation code.
%
% The model view shows the detected aggreagtes, however these
% are not correct since there are only 100 agents. The bandwith of 14 is 
% optimized for estiamteing the biofilm density in simulations with 10000 
% cells. But 10000 cells is very slow to for testing purposes.
%

f = Kmodel(:,:,1);
f(f < 0) = 1-8;
E = OpenLoop(Kmodel,f,probs,agg_tracks,100); 

%Test that simulation starts
E.loop(5)

%Test field view
E.view('on')
E.loop(5)
E.view('off');

%Test non-prerun probabilites
E.loop(50)

 %Test saving simulation
data = E.exportData();
sim_tracks = CreateSimTracks(E.exportTracks());

 
 
 
 
