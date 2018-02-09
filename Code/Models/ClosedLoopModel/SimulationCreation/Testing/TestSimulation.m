%%%
% Prepares data from AllDataTable to be used in model and creates a Probabilites object for use in model.
%%%
addpath('Libraries/Utils/')
addpath('Models/ModelBase')
addpath('Models/ModelBase/Analysis/')
addpath('Models/ClosedLoopModel/ClosedLoop')
addpath('Models/ClosedLoopModel/SimulationCreation')

%load '../Data/WTinWT/AllDataTable.mat'

%% Generate Probs
%%%%%%%%%%%%%%%%%%
PRERUN_LENGTH = 40;

[Mdlb, Mdlr, Mdlst, Init] = create_search_trees(AllDataTable);

probs = ClosedLoopProbs(Mdlb,Mdlr,Mdlst,Init,PRERUN_LENGTH);

%%
% The follwoing code is an example of how to create a closed loop model and
% tests all major fuctions of the simulation code.
%
% The model view shows the detected aggreagtes, however these
% are not correct since there are only 100 agents. The bandwith of 14 is 
% optimized for estiamteing the biofilm density in simulations with 10000 
% cells. But 10000 cells is very slow to for testing purposes.
%

E = ClosedLoop(probs,100,'bandwidth',14); 

%Test that simulation starts
E.loop(5)

%Test field view
E.view('on')
E.loop(5)
E.view('off');

%Test non-prerun probabilites
E.loop(PRERUN_LENGTH + 10)

 %Test saving simulation
data = E.exportData();
sim_tracks = CreateSimTracks(E.exportTracks());

 
 
 
 
