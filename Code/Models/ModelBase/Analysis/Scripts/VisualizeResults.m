addpath('Libraries/Utils')
addpath('Models/ModelBase/Analysis')


%% Cell movement
sim_tracks = CreateSimTracks(sim_tracks);

figure
for i = 1:max(sim_tracks.frame)
    st = subStruct(sim_tracks,sim_tracks.frame == i);
    
    hold on
    plot(st.x(st.density > 2.3),st.y(st.density > 2.3),'or')
    plot(st.x(st.density <= 2.3),st.y(st.density <= 2.3),'ob')

    title(i);
    drawnow
    cla
    %pause(0.2);
end

%% Frac in vs out of aggreagtes

sim_tracks.in_agg = sim_tracks.density > 5.5; %in_out_agg(sim_tracks,agg_tracks);

sim_inside  = subStruct(sim_tracks,sim_tracks.in_agg > 0);
sim_inside_count  = histc(sim_inside.frame,min(sim_tracks.frame):max(sim_tracks.frame));
sim_total_count   = histc(sim_tracks.frame,min(sim_tracks.frame):max(sim_tracks.frame));
simFracCurve = sim_inside_count ./ (sim_total_count);

figure, hold on
    xi = (1:length(simFracCurve)) / 2 / 60;
    plot(xi,simFracCurve .* 100);

    u = mean(conCurves,2) * 100;
    s = std(conCurves,[],2) .* 100;
    xi = (1:length(conCurves)) / 2 / 60;
    %boundedline(xi,u,s,'alpha','cmap',color_chooser(2))
    plot(xi,u,'-','Color',color_chooser(2));
    plot(xi,u+s,'--','Color',color_chooser(2));
    plot(xi,u-s,'--','Color',color_chooser(2));
    
    
%% Visualize Cell Alignmnet
at = subStruct(sim_tracks,sim_tracks.frame == 80);

x = at.x;
y = at.y;
o = at.o;

figure
l = 5;           
line([x - l * cosd(o) x + l * cosd(o)]', ...
     [y - l * sind(o) y + l * sind(o)]');