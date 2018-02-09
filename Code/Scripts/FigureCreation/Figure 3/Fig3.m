%%%
% Creates Figures on cell bias towards aggreagtes
%%%
addpath('Libraries/Utils')

% PERSISTENT = true caluclates graph for persistent runs
% PERSISTENT = false calculates graph for non-persistent runs
PERSISTENT = true;

% How many bootstrap samples
% 1000 for publication, set to 10 to keep things moving quickly for testing
NBOOT = 50;

%Number of frames to skip prior to calculating inside aggreagte values
%Set to a frame after aggreagte tracking becomes fairly stable. 
STABLE_AGG_CUTOFF = 160;

% Sliding window size, in um
WINDOW = 10;

% Inside aggreagte density cutoff (cells/um^2)
DENSITY_CUTOFF = 5.5;

% Publication: setting to true supresses some labeling during plotting
% to make plot publication ready, but less visually readable. 
PUB_READY = false;

xi = [-50:1:150];

%% Pub Figure: Distance
T = AllDataTable;
T = T(~isnan(T.Dn1),:);
T = T(T.TSS1 > STABLE_AGG_CUTOFF,:);

if(PERSISTENT)
    T = T(T.state1 < 3,:);
else
    T = T(T.state1 == 3,:);
end

bootfun = @(x,y) movingmeanxy(x,y,WINDOW,xi);
bootsdrfun = @(x,y) movingstderrorxy(x,y,WINDOW,xi);

%%% Weight by the number of runs in each movie
weights = zeros(size(T,1),1);
for curMovie = unique(T.movie)'
    f = strcmp(curMovie,T.movie);
    weights(f) = sum(f);
end
weights = 1 - (weights / sum(weights));

tic
    [bootstatciTOWARDS,bootstatuTOWARDS] = bootci(NBOOT,{bootfun,T.Dn1(cos(T.beta1) > 0),T.Rd1(cos(T.beta1) > 0)},'type','student','stderr',bootsdrfun,'Weights',weights(cos(T.beta1) > 0));
toc
tic
    [bootstatciAWAY,bootstatuAWAY]       = bootci(NBOOT,{bootfun,T.Dn1(cos(T.beta1) < 0),T.Rd1(cos(T.beta1) < 0)},'type','student','stderr',bootsdrfun,'Weights',weights(cos(T.beta1) < 0));
toc

figure, hold on 
    clear h
    h(1) = plot(xi,mean(bootstatuTOWARDS),'Color',[0.4941    0.1843    0.5569])
    plot(xi,bootstatciTOWARDS(2,:),'--','Color',[0.4941    0.1843    0.5569])
    plot(xi,bootstatciTOWARDS(1,:),'--','Color',[0.4941    0.1843    0.5569])

    h(2) = plot(xi,mean(bootstatuAWAY),'Color',[0.4667    0.6745    0.1882])
    plot(xi,bootstatciAWAY(2,:),'--','Color',[0.4667    0.6745    0.1882])
    plot(xi,bootstatciAWAY(1,:),'--','Color',[0.4667    0.6745    0.1882])

    if(~PUB_READY)
        ylabel('Distance (\mum)')
        xlabel('Distance to Aggregate Boundary (\mum)')
        grid on
        legend(h,'Towards','Away')
    end

    ax = gca;
    xlim([min(xi),max(xi)]);
    ylim([0,ax.YLim(2)])
    ax.FontSize = 10;
    box on

if(PERSISTENT)
    %saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/RdVsAngle','Size',[20.5,13],'Style','none','Formats',{'png','fig'},'r',600);
else
    %saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/RdVsAngleStopped','Size',[20.5,13],'Style','none','Formats',{'png','fig'},'r',600);
end

%% Pub Figure: Duration
T = AllDataTable;
T = T(~isnan(T.Dn1),:);
T = T(T.TSS1 > STABLE_AGG_CUTOFF,:);

if(PERSISTENT)
    T = T(T.state1 < 3,:);
else
    T = T(T.state1 == 3,:);
end

bootfun = @(x,y) movingmeanxy(x,y,WINDOW,xi);
bootsdrfun = @(x,y) movingstderrorxy(x,y,WINDOW,xi);

%%% Weight by the number of runs in each movie
weights = zeros(size(T,1),1);
for curMovie = unique(T.movie)'
    f = strcmp(curMovie,T.movie);
    weights(f) = sum(f);
end
weights = 1 - (weights / sum(weights));

tic
    [bootstatciTOWARDS,bootstatuTOWARDS] = bootci(NBOOT,{bootfun,T.Dn1(cos(T.beta1) > 0),T.Rt1(cos(T.beta1) > 0)},'type','student','stderr',bootsdrfun,'Weights',weights(cos(T.beta1) > 0));
toc
tic
    [bootstatciAWAY,bootstatuAWAY]       = bootci(NBOOT,{bootfun,T.Dn1(cos(T.beta1) < 0),T.Rt1(cos(T.beta1) < 0)},'type','student','stderr',bootsdrfun,'Weights',weights(cos(T.beta1) < 0));
toc

figure, hold on 
    clear h
    h(1) = plot(xi,mean(bootstatuTOWARDS),'Color',[0.4941    0.1843    0.5569])
    plot(xi,bootstatciTOWARDS(2,:),'--','Color',[0.4941    0.1843    0.5569])
    plot(xi,bootstatciTOWARDS(1,:),'--','Color',[0.4941    0.1843    0.5569])

    h(2) = plot(xi,mean(bootstatuAWAY),'Color',[0.4667    0.6745    0.1882])
    plot(xi,bootstatciAWAY(2,:),'--','Color',[0.4667    0.6745    0.1882])
    plot(xi,bootstatciAWAY(1,:),'--','Color',[0.4667    0.6745    0.1882])

    if(~PUB_READY)
        ylabel('Duration (min)')
        xlabel('Distance to Aggregate Boundary (\mum)')
        grid on
        legend(h,'Towards','Away')
    end

    ax = gca;
    xlim([min(xi),max(xi)]);
    ylim([0,ax.YLim(2)])
    ax.FontSize = 10;
    box on

if(PERSISTENT)
    %saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/RdVsAngle','Size',[20.5,13],'Style','none','Formats',{'png','fig'},'r',600);
else
    %saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/RdVsAngleStopped','Size',[20.5,13],'Style','none','Formats',{'png','fig'},'r',600);
end

%% Pub Figure: Speed
T = AllDataTable;
T = T(~isnan(T.Dn1),:);
T = T(T.TSS1 > STABLE_AGG_CUTOFF,:);

if(PERSISTENT)
    T = T(T.state1 < 3,:);
else
    T = T(T.state1 == 3,:);
end

bootfun = @(x,y) movingmeanxy(x,y,WINDOW,xi);
bootsdrfun = @(x,y) movingstderrorxy(x,y,WINDOW,xi);

%%% Weight by the number of runs in each movie
weights = zeros(size(T,1),1);
for curMovie = unique(T.movie)'
    f = strcmp(curMovie,T.movie);
    weights(f) = sum(f);
end
weights = 1 - (weights / sum(weights));

tic
    [bootstatciTOWARDS,bootstatuTOWARDS] = bootci(NBOOT,{bootfun,T.Dn1(cos(T.beta1) > 0),T.Rs1(cos(T.beta1) > 0)},'type','student','stderr',bootsdrfun,'Weights',weights(cos(T.beta1) > 0));
toc
tic
    [bootstatciAWAY,bootstatuAWAY]       = bootci(NBOOT,{bootfun,T.Dn1(cos(T.beta1) < 0),T.Rs1(cos(T.beta1) < 0)},'type','student','stderr',bootsdrfun,'Weights',weights(cos(T.beta1) < 0));
toc

figure, hold on 
    clear h
    h(1) = plot(xi,mean(bootstatuTOWARDS),'Color',[0.4941    0.1843    0.5569])
    plot(xi,bootstatciTOWARDS(2,:),'--','Color',[0.4941    0.1843    0.5569])
    plot(xi,bootstatciTOWARDS(1,:),'--','Color',[0.4941    0.1843    0.5569])

    h(2) = plot(xi,mean(bootstatuAWAY),'Color',[0.4667    0.6745    0.1882])
    plot(xi,bootstatciAWAY(2,:),'--','Color',[0.4667    0.6745    0.1882])
    plot(xi,bootstatciAWAY(1,:),'--','Color',[0.4667    0.6745    0.1882])

    if(~PUB_READY)
        ylabel('Speed (\mum/min)')
        xlabel('Distance to Aggregate Boundary (\mum)')
        grid on
        legend(h,'Towards','Away')
    end

    ax = gca;
    xlim([min(xi),max(xi)]);
    ylim([0,ax.YLim(2)])
    ax.FontSize = 10;
    box on

if(PERSISTENT)
    %saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/RdVsAngle','Size',[20.5,13],'Style','none','Formats',{'png','fig'},'r',600);
else
    %saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/RdVsAngleStopped','Size',[20.5,13],'Style','none','Formats',{'png','fig'},'r',600);
end

%% Figure: P(non-persistent) THIS IS VERY SLOW!!!!
bootfun1 = @(Ti) sum(Ti.state0 < 3 & Ti.state1 == 3) / sum(Ti.state0 < 3);
bootfun2 = @(Tb,x) bootfun1(Tb(Tb.Dn1 > x - WINDOW & Tb.Dn1 < x + WINDOW,:));
bootfun3 = @(Tb) bootloop(Tb,xi,bootfun2);

T = AllDataTable;
T = T(cos(T.phi0) > 0,:);

%%% Weight by the number of runs in each movie
weights = zeros(size(T,1),1);
for curMovie = unique(T.movie)'
    f = strcmp(curMovie,T.movie);
    weights(f) = sum(f);
end
weights = 1 - (weights / sum(weights));

tic
    ci_towards = bootci(NBOOT,{bootfun3,T},'type','cper','Weights',weights);
toc
m_towards = bootfun3(T);

T = AllDataTable;
T = T(cos(T.phi0) < 0,:);

%%% Weight by the number of runs in each movie
weights = zeros(size(T,1),1);
for curMovie = unique(T.movie)'
    f = strcmp(curMovie,T.movie);
    weights(f) = sum(f);
end
weights = 1 - (weights / sum(weights));

tic
    ci_away = bootci(NBOOT,{bootfun3,T},'type','cper','Weights',weights);
toc
m_away = bootfun3(T);

figure, hold on
    plot(xi,ci_towards','--','Color',[0.4941    0.1843    0.5569])
    h(1) = plot(xi,m_towards,'-','Color',[0.4941    0.1843    0.5569])
    
    plot(xi,ci_away','--','Color',[0.4667    0.6745    0.1882])
    h(2) = plot(xi,m_away,'-','Color',[0.4667    0.6745    0.1882])
    box on;
    
    if(~PUB_READY)
        ylabel('P(non-persistent)')
        xlabel('Distance to Aggregate Boundary (\mum)')
        grid on
        legend(h,'Towards','Away')
    end

    
