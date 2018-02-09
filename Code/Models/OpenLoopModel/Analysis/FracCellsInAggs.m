%% Calculate Simulation Fraction of cells inside aggreagte curves
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('Models/ModelBase/Analysis')
addpath('Libraries/Utils')
Nruns = 1;
Nreps = 2;

SAVE_RESULTS = false;
folder_name = '/Users/cotter/GitHub/CotterPNAS2017/Code/Models/OpenLoopModel/Results/OL_WT_no_beta_stopped/Results/OL_WT_no_beta_stopped/';

prerun_length = 0;
simFracCurves = zeros(599 + prerun_length,Nruns * Nreps);

for run = 1:Nruns
    run
    for rep = 1:Nreps
        %%
        load([folder_name '/sim_tracks-' num2str(run) '-' num2str(rep) '.mat']);
        sim_tracks = CreateSimTracks(sim_tracks);
        sim_tracks.in_agg = sim_tracks.density > 5.5;

        sim_inside  = subStruct(sim_tracks,sim_tracks.in_agg > 0);
        sim_inside_count  = histc(sim_inside.frame,min(sim_tracks.frame):max(sim_tracks.frame));
        sim_total_count   = histc(sim_tracks.frame,min(sim_tracks.frame):max(sim_tracks.frame));
        %simFracCurves(:,set,run) = sim_inside_count ./ (sim_total_count);
        simFracCurves(:,rep + (Nreps * (run - 1))) = sim_inside_count ./ (sim_total_count);
    end
end

if(SAVE_RESULTS)
    save([ folder_name '/simFracCurves'],'simFracCurves')
end

%% Plot Sim Frac Curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prerun_length = 1;
sim_frac_mean = mean(simFracCurves(prerun_length:end,:),2) .* 100;
sim_frac_std = std(simFracCurves(prerun_length:end,:),[],2) .* 100;

load 'Data/Csga in WT/ConCurves.mat';
ucsga = mean(conCurves,1)' .* 100;
scsga = std(conCurves,[],1)' .* 100;

load 'Data/WTinWT/ConCurves.mat'
uwt = mean(conCurves,1)' .* 100;
swt = std(conCurves,[],1)' .* 100;

figure, clf, hold on;
    xi = (1:length(sim_frac_mean)) / 2 / 60
    boundedline(xi,sim_frac_mean,[sim_frac_std,sim_frac_std],'--','cmap',color_chooser(2),'alpha')

    xi = (1:length(conCurves)) / 2 / 60;
    boundedline(xi,uwt,[swt,swt],'-','cmap',color_chooser(1),'alpha')
    boundedline(xi,ucsga,[scsga,scsga],'-','cmap',color_chooser(2),'alpha')

    xlim auto
    ax = gca;
    ylim([0 ax.YLim(2)])
    xlim([0 520/2/60])
    %ax.XTick = 0:5;
    %ax.YTick = 0:10:70
    ylabel('% Cells Inside Aggregates');
    xlabel('Time (hr)')
    box on;
    %title(' '); %Gives room for ylabel

%%
    saveFigures('SaveAs',[ folder_name '/FracCurves'], ...
                   'Size',[20,20], ...
                   'Style','none', ...
                   'Formats',{'png','fig'}, ...
                   'r',600);
