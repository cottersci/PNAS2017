% Calculate agg props
addpath('Libraries/Utils')
addpath('Libraries/LAPTracker/')
addpath('Models/ModelBase/Analysis')
%%%%%%%%%%%

Nruns = 3;
nCells = 10000;
bandwidth = 14;
Nreps = 3;
folder_name = '/Users/cotter/GitHub/CotterPNAS2017/Code/Models/OpenLoopModel/Results/OpenLoop_CsgA';

AGG_DESNITY_CUTOFF = 2.32; %Cutoff density for detecting aggreagtes
                            %in cells/um^2
AVE_CELL_DENSITY = 1.12; %Average cell density within the field of view
                        %in cells/um^2

%%%%%%%%%%
bwd = ([bandwidth bandwidth] ./ [986 740]).^2;
p = Progress(Nruns);
AggProps = table();
for run = 1:Nruns
    for rep = 1:Nreps
        p.d(run);
        %% Load simulation results
        load([folder_name '/sim_tracks-' num2str(run) '-' num2str(rep) '.mat'])
        sim_tracks = CreateSimTracks(sim_tracks);

        %% Calculate density from agent locations
        K = zeros(2^10,2^10,max(sim_tracks.frame));
        p = Progress(max(sim_tracks.frame));
        for t = 1:max(sim_tracks.frame)
           p.d(t);
           a = subStruct(sim_tracks,sim_tracks.frame == t);

           [~, d, ~] = kde2d([a.x a.y],2^10,[0 0],[986 740],bwd(1),bwd(2));
           K(:,:,t) = imresize(d * AVE_CELL_DENSITY * 2^10 * 2^10,[2^10 2^10]);   
        end
        p.done()

        %% Track aggreagtes
        [agg_tracks,stable_aggs,unstable_aggs] = trackAggregates(K,AGG_DESNITY_CUTOFF);
        save([folder_name '/agg_tracks_with_area-' num2str(run) '-' num2str(rep)],'agg_tracks','stable_aggs','unstable_aggs');

        %% Calculate agg properties
        real_aggs = subStruct(agg_tracks,ismember(agg_tracks.id,union(stable_aggs,unstable_aggs)));

        T = table();

        T.majorAxis    = real_aggs.majorAxis;
        T.minorAxis    = real_aggs.minorAxis;
        T.orientation  = real_aggs.orientation;
        T.id           = real_aggs.id;
        T.area         = real_aggs.area;
        T.eccentricity = real_aggs.eccentricity;
        T.mean_density = real_aggs.meanIntensity;
        T.frame        = real_aggs.frame;
        T.movie        = repmat([num2str(run) '-' num2str(rep)],length(real_aggs.frame),1);

        AggProps = [AggProps; T];
    end
end %run loop

save([folder_name '/AggProps.mat'],'AggProps')