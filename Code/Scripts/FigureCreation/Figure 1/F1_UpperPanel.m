%% Creates Figure that shows cell beahvior distributions
%%%
addpath('Libraries/Utils')

%Number of frames to skip prior to calculating inside aggreagte values
%Set to a frame after aggreagte tracking becomes fairly stable. 
STABLE_AGG_CUTOFF = 160;

% Inside aggreagte density cutoff (cells/um^2)
DENSITY_CUTOFF = 5.5;

%% Run Durations
T = AllDataTable;
Tin = T(T.rho1 > DENSITY_CUTOFF,:);
Tout = T(T.rho1 < DENSITY_CUTOFF,:);
figure, [pos,group_box_pos] = gboxplot({
                       {Tin.Rt1(Tin.state1 < 3), Tin.Rt1(Tin.state1 == 3)},
                       {Tout.Rt1(Tout.state1 < 3), Tout.Rt1(Tout.state1 == 3)}
                      }',{'In','Out'})       
h=findobj(gca,'tag','Outliers');
delete(h)

hold on;
plot(group_box_pos{1}(1),mean(Tin.Rt1(Tin.state1 < 3)),'*','MarkerSize',3.5,'Color',color_chooser(1));
plot(group_box_pos{1}(2),mean(Tin.Rt1(Tin.state1 == 3)),'*','MarkerSize',3.5,'Color',color_chooser(2));
plot(pos(1),mean(Tin.Rt1),'o','MarkerSize',3.5,'Color','m');
plot(group_box_pos{2}(1),mean(Tout.Rt1(Tout.state1 < 3)),'*','MarkerSize',3.5,'Color',color_chooser(1));
plot(group_box_pos{2}(2),mean(Tout.Rt1(Tout.state1 == 3)),'*','MarkerSize',3.5,'Color',color_chooser(2));
plot(pos(2),mean(Tout.Rt1),'o','MarkerSize',3.5,'Color','m');
legend off
ax = gca;
ax.FontSize = 10;
xlabel('Run Duration (min)')
%saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/DurationBoxPlot','Size',[9.25,9],'Style','none','Formats',{'png','fig'},'r',600);

%% Run Speeds
T = AllDataTable;
Tin = T(T.rho1 > 5.5,:);
Tout = T(T.rho1 < 5.5,:);
figure, [pos,group_box_pos] = gboxplot({
                       {Tin.Rs1(Tin.state1 < 3), Tin.Rs1(Tin.state1 == 3)},
                       {Tout.Rs1(Tout.state1 < 3), Tout.Rs1(Tout.state1 == 3)}
                      }',{'In','Out'})       
h=findobj(gca,'tag','Outliers');
delete(h)

hold on;
plot(group_box_pos{1}(1),mean(Tin.Rs1(Tin.state1 < 3)),'*','MarkerSize',3.5,'Color',color_chooser(1));
plot(group_box_pos{1}(2),mean(Tin.Rs1(Tin.state1 == 3)),'*','MarkerSize',3.5,'Color',color_chooser(2));
plot(pos(1),mean(Tin.Rs1),'o','MarkerSize',3.5,'Color','m');
plot(group_box_pos{2}(1),mean(Tout.Rs1(Tout.state1 < 3)),'*','MarkerSize',3.5,'Color',color_chooser(1));
plot(group_box_pos{2}(2),mean(Tout.Rs1(Tout.state1 == 3)),'*','MarkerSize',3.5,'Color',color_chooser(2));
plot(pos(2),mean(Tout.Rs1),'o','MarkerSize',3.5,'Color','m');
legend off
ax = gca;
%ylim([0 ax.YLim(2)])
ax.FontSize = 10;
ylabel('Run Speed (\mum/min)')
%saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/SpeedBoxPlot','Size',[9.25,9],'Style','none','Formats',{'png','fig'},'r',600);

%% Run Distances
T = AllDataTable;
Tin = T(T.rho1 > 5.5,:);
Tout = T(T.rho1 < 5.5,:);
figure, [pos,group_box_pos] = gboxplot({
                       {Tin.Rd1(Tin.state1 < 3), Tin.Rd1(Tin.state1 == 3)},
                       {Tout.Rd1(Tout.state1 < 3), Tout.Rd1(Tout.state1 == 3)}
                      }',{'In','Out'})       
h=findobj(gca,'tag','Outliers');
delete(h)

hold on;
plot(group_box_pos{1}(1),mean(Tin.Rd1(Tin.state1 < 3)),'*','MarkerSize',3.5,'Color',color_chooser(1));
plot(group_box_pos{1}(2),mean(Tin.Rd1(Tin.state1 == 3)),'*','MarkerSize',3.5,'Color',color_chooser(2));
plot(pos(1),mean(Tin.Rd1),'o','MarkerSize',3.5,'Color','m');
plot(group_box_pos{2}(1),mean(Tout.Rd1(Tout.state1 < 3)),'*','MarkerSize',3.5,'Color',color_chooser(1));
plot(group_box_pos{2}(2),mean(Tout.Rd1(Tout.state1 == 3)),'*','MarkerSize',3.5,'Color',color_chooser(2));
plot(pos(2),mean(Tout.Rd1),'o','MarkerSize',3.5,'Color','m');
legend off
ax = gca;
%ylim([0 ax.YLim(2)])
ax.FontSize = 10;
ylabel('Run Distance (\mum)')
%saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/DistanceBoxPlot','Size',[9.25,9],'Style','none','Formats',{'png','fig'},'r',600);

%% P(non-persistent)
T = AllDataTable;

Ti = T(T.rho1 > 5.5,:);
P_stop_in  = sum(Ti.state0 < 3 & Ti.state1 == 3) / sum(Ti.state0 < 3);
Ti = T(T.rho1 < 5.5,:);
P_stop_out = sum(Ti.state0 < 3 & Ti.state1 == 3) / sum(Ti.state0 < 3);

figure,
    b = bar([1,2],[P_stop_in,P_stop_out]);
    xlim([0.5,2.5])
    b(1).FaceColor = 'k';
      ylim([0 1])
      ax = gca;
      ax.XLimMode = 'Manual'
      box on
      ax.XTickLabel = {'In','Out'};
      ax.YTick = 0:0.25:1;
      ax.YTickLabelRotation = 45;
      ylabel('P(non-presistent)')
    grid on;
%saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/StopProb','Size',[9.25,9],'Style','none','Formats',{'png','fig'},'r',600);