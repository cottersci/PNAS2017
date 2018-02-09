Nruns = 1;
folder_name = 'bandSearch6';  

%%% Setup Variables
prs = 0;
p = Progress(Nruns);
set = 2;

load([fnames{set} 'first_frame_um.mat']);
mkdir(['/Users/cotter/Desktop/NewData/Good/Results/ClosedLoop/' folder_name '/']);
addpath('/Users/cotter/Desktop/NewData/Good/Code/ModelBase')
addpath('/Users/cotter/Desktop/NewData/Good/Code/ClosedLoopModel/ClosedLoop')

%%% Create Probabilities
%T = AllDataTable(strcmp(AllDataTable.movie, AllData{set}.set),:);
T = AllDataTable;
T = T(~isnan(T.theta1),:); %Remvoes 4 runs that move no distance, leaving theta, phi, and beta undefined
                           %Since there is so few, they sould have no effect on aggregation and are easiest
                           %just to remove. 
                           
% Create search trees
T.cos_beta1 = cos(T.beta1);

clear Mdlst
Ti = T(T.state0 < 3,:);
Mdlst(1).KNN = KNNSampler([
                           Ti.TSS1, ...
                           Ti.rho1, ...
                           Ti.Dn1 ...
                        ]);         
Mdlst(1).state1 = Ti.state1;
Ti = T(T.state0 == 3,:);
Mdlst(2).KNN = KNNSampler([
                           Ti.TSS1, ...
                           Ti.rho1, ...
                           Ti.Dn1 ...
                        ]);         
Mdlst(2).state1 = Ti.state1;

clear Mdlr;
clear Mdlb
Ti = T(T.state0 < 3 & T.state1 < 3,:);
% Mdlr(1).KNN = KNNSampler([Ti.TSS1 Ti.Dn1 Ti.phi0]);
Mdlr(1).KNN = KNNSampler([Ti.chi]);
Mdlr(1).theta1 = Ti.theta1;

Mdlb(1).KNN = KNNSampler([
                           Ti.TSS1, ...
                           Ti.rho1, ...
                           Ti.cos_beta1, ...
                           Ti.Dn1 ...
                        ]);         
Mdlb(1).T = Ti;

Ti = T(T.state0 < 3 & T.state1 == 3,:);
%Mdlr(2).KNN = KNNSampler([Ti.TSS1 Ti.Dn1 Ti.phi0]);
Mdlr(2).KNN = KNNSampler([Ti.chi]);
Mdlr(2).theta1 = Ti.theta1;

Mdlb(2).KNN = KNNSampler([
                           Ti.TSS1, ...
                           Ti.rho1, ...
                           Ti.cos_beta1, ...
                           Ti.Dn1 ...
                        ]);         
Mdlb(2).T = Ti;

Ti = T(T.state0 == 3 & T.state1 < 3,:);
%Mdlr(3).KNN = KNNSampler([Ti.TSS1 Ti.Dn1 Ti.phi0]);
Mdlr(3).KNN = KNNSampler([Ti.chi]);
Mdlr(3).theta1 = Ti.theta1;

Mdlb(3).KNN = KNNSampler([
                           Ti.TSS1, ...
                           Ti.rho1, ...
                           Ti.cos_beta1, ...
                           Ti.Dn1 ...
                        ]);         
Mdlb(3).T = Ti;


%probs = Probabilities(Mdlb,Mdlr,Mdlst)
probs = ClosedLoopProbs(Mdlb,Mdlr,Mdlst)

%%
%%% Run Simulations 1
for bandw = [6 8 10 12 14 16]
    bandw

    %% Run Simulation
    E = ClosedLoop(probs,10000,'bandwidth',bandw);
    E.loop(600);

    %% Save Results
    data = E.exportData();
    sim_tracks =  TrajectoryAnalysis.CreateSimTracks(E.exportTracks());
    save(['/Users/cotter/Desktop/NewData/Good/Results/ClosedLoop/' folder_name '/sim_tracks-' num2str(bandw)],'sim_tracks');
    save(['/Users/cotter/Desktop/NewData/Good/Results/ClosedLoop/' folder_name '/sim_data-'  num2str(bandw)],'data');

    %% Cleanup
    prs = prs + 1;
end

%%
% Loads mutiple simulation results and calculates the fraction of cells inside/total for each simulation
%%%
simFracCurves = zeros(599 + 250,length([13 14 18]));
c = 1;
for bandw = [6 8 10 12 14 16]
    bandw
    load(['/Users/cotter/Desktop/NewData/Good/Results/ClosedLoop/' folder_name '/sim_tracks-' num2str(bandw) '.mat'])

    sim_tracks.in_agg = sim_tracks.density > 5.5;

    sim_inside  = subStruct(sim_tracks,sim_tracks.in_agg > 0);
    sim_inside_count  = histc(sim_inside.frame,min(sim_tracks.frame):max(sim_tracks.frame));
    sim_total_count   = histc(sim_tracks.frame,min(sim_tracks.frame):max(sim_tracks.frame));
    simFracCurves(:,c) = sim_inside_count ./ (sim_total_count);
    c = c+1;
end

save(['/Users/cotter/Desktop/NewData/Good/Results/ClosedLoop/' folder_name '/fracCurves'],'simFracCurves');

%%
figure,
    plot(simFracCurves)
    legend('8','10','11','12','14','16','18')
    ylabel('Fraction of cells inside aggregates')
    xlabel('Time (frames)')