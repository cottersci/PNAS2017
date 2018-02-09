%% Creates Figure that shows mean cell behaviors over time
%%%
addpath('Libraries/Utils')

% PERSISTENT = true caluclates graph for persistent runs
% PERSISTENT = false calculates graph for non-persistent runs
PERSISTENT = true;

% How many bootstrap samples
% 1000 for publication, set to 10 to keep things moving quickly for testing
NBOOT = 10;

%Number of frames to skip prior to calculating inside aggreagte values
%Set to a frame after aggreagte tracking becomes fairly stable. 
STABLE_AGG_CUTOFF = 160;

% Sliding window size, in frames
WINDOW = 20;

% Inside aggreagte density cutoff (cells/um^2)
DENSITY_CUTOFF = 5.5;

% Publication: setting to true supresses some labeling during plotting
% to make plot publication ready, but less visually readable. 
PUB_READY = false;

%% Boot strapping

%~30 second speedup for BOOT = 1000 on a Quad Core i7 with a pool of 3.
% not worth it.
Options = statset('UseParallel',false); 

% Outside
T = AllDataTable;
T = T(T.rho1 < DENSITY_CUTOFF,:);
if(PERSISTENT)
    T = T(T.state1 < 3,:);
else
    T = T(T.state1 == 3,:);
end
xiOUT = sort(unique(T.TSS1));

bootfun = @(x,y,w) movingmeanxy(x,y,WINDOW,xiOUT);
bootsdrfun = @(x,y,w) movingstderrorxy(x,y,WINDOW,xiOUT);

%%% Weight by the number of runs in each movie
weights = zeros(size(T,1),1);
for curMovie = unique(T.movie)'
    f = strcmp(curMovie,T.movie);
    weights(f) = sum(f);
end
weights = 1 - (weights / sum(weights));

tic
    [bootstatRsciOUTSIDE,bootstatRsOUTSIDE] = bootci(NBOOT,{bootfun,T.TSS1,T.Rs1},'type','cper','Options',Options,'Weights',weights);
toc
tic
    [bootstatRtciOUTSIDE,bootstatRtOUTSIDE] = bootci(NBOOT,{bootfun,T.TSS1,T.Rt1},'type','cper','Options',Options,'Weights',weights);
toc
tic
    [bootstatRdciOUTSIDE,bootstatRdOUTSIDE] = bootci(NBOOT,{bootfun,T.TSS1,T.Rd1},'type','cper','Options',Options,'Weights',weights);
toc

%Inside
T = AllDataTable;
T = T(T.TSS1 > STABLE_AGG_CUTOFF & T.rho1 > DENSITY_CUTOFF,:);
if(PERSISTENT)
    T = T(T.state1 < 3,:);
else
    T = T(T.state1 == 3,:);
end
xiIN = sort(unique(T.TSS1));
bootfun = @(x,y,w) movingmeanxy(x,y,WINDOW,xiIN);
bootsdrfun = @(x,y,w) movingstderrorxy(x,y,WINDOW,xiIN);

weights = zeros(size(T,1),1);
for curMovie = unique(T.movie)'
    f = strcmp(curMovie,T.movie);
    weights(f) = sum(f);
end
weights = 1 - (weights / sum(weights));

tic
    [bootstatRdciINSIDE,bootstatRdINSIDE] = bootci(NBOOT,{bootfun,T.TSS1,T.Rd1},'type','cper','Options',Options,'Weights',weights);
toc
tic
    [bootstatRtciINSIDE,bootstatRtINSIDE] = bootci(NBOOT,{bootfun,T.TSS1,T.Rt1},'type','cper','Options',Options,'Weights',weights);
toc
tic
    [bootstatRsciINSIDE,bootstatRsINSIDE] = bootci(NBOOT,{bootfun,T.TSS1,T.Rs1},'type','cper','Options',Options,'Weights',weights);
toc

%% Figure: Run Distance
figure, hold on;
    plot(xiIN ,mean(bootstatRdINSIDE),'k')
    plot(xiIN,bootstatRdciINSIDE(2,:),'--k')
    plot(xiIN,bootstatRdciINSIDE(1,:),'--k')
    
    plot(xiOUT,mean(bootstatRdOUTSIDE),'b')
    plot(xiOUT,bootstatRdciOUTSIDE(2,:),'--b')
    plot(xiOUT,bootstatRdciOUTSIDE(1,:),'--b')
  
    ax = gca;
    ylim([0 ax.YLim(2)])

    ax.XTick = (0:5) * 2 * 60;
    ax.XTickLabel = (0:5);
    ax.FontSize = 10;
    box on
    
    if(~PUB_READY)
        if(PERSISTENT)
            title('Presistent Run Distance')
        else
            title('Non-presistent Run Distance')
        end
        grid on;
    end

    ylabel('Distance (\mum)')
    xlabel('Time (hr)');
    
    if(PERSISTENT)
        %saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/DistanceVsTime','Size',[9.25,9],'Style','none','Formats',{'png','fig'},'r',600);
    else
        %saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/DistanceVsTimeStopped','Size',[12,13.45],'Style','none','Formats',{'png','fig'},'r',600);
    end
    
%% Figure: Run Speed
figure, hold on;
    plot(xiIN ,mean(bootstatRsINSIDE),'k')
    plot(xiIN,bootstatRsciINSIDE(2,:),'--k')
    plot(xiIN,bootstatRsciINSIDE(1,:),'--k')
    
    plot(xiOUT,mean(bootstatRsOUTSIDE),'b')
    plot(xiOUT,bootstatRsciOUTSIDE(2,:),'--b')
    plot(xiOUT,bootstatRsciOUTSIDE(1,:),'--b')
   
    ax = gca;
    ylim([0 ax.YLim(2)])

    ax.XTick = (0:5) * 2 * 60;
    ax.XTickLabel = (0:5);
    ax.FontSize = 10;
    box on
    
    if(~PUB_READY)
        if(PERSISTENT)
            title('Presistent Run Speed')
        else
            title('Non-presistent Run Speed')
        end
        grid on;
    end

    ylabel('Speed (\mum/min)')
    xlabel('Time (hr)');
    
    if(PERSISTENT)
        %saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/SpeedVsTime','Size',[9.25,9],'Style','none','Formats',{'png','fig'},'r',600);
    else
        %saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/SpeedVsTimeStopped','Size',[12,13.45],'Style','none','Formats',{'png','fig'},'r',600);
    end
    
%% Figure: Run Duration
figure, hold on;
    plot(xiIN ,mean(bootstatRtINSIDE),'k')
    plot(xiIN,bootstatRtciINSIDE(2,:),'--k')
    plot(xiIN,bootstatRtciINSIDE(1,:),'--k')
    
    plot(xiOUT,mean(bootstatRtOUTSIDE),'b')
    plot(xiOUT,bootstatRtciOUTSIDE(2,:),'--b')
    plot(xiOUT,bootstatRtciOUTSIDE(1,:),'--b')
   
    ax = gca;
    ylim([0 ax.YLim(2)])

    ax.XTick = (0:5) * 2 * 60;
    ax.XTickLabel = (0:5);
    ax.FontSize = 10;
    box on
    
    if(~PUB_READY)
        if(PERSISTENT)
            title('Presistent Run Duration')
        else
            title('Non-presistent Run Duration')
        end
        grid on;
    end

    ylabel('Duration (min)')
    xlabel('Time (hr)');
    
    if(PERSISTENT)
        %saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/DurationVsTime','Size',[9.25,9],'Style','none','Formats',{'png','fig'},'r',600);
    else
        %saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/DurationVsTimeStopped','Size',[12,13.45],'Style','none','Formats',{'png','fig'},'r',600);
    end
    
%saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/DurationVsTimeStopped','Size',[12,13.45],'Style','none','Formats',{'png','fig'},'r',600);

%% Boot strapping P(non-persistent): Outside
T = AllDataTable;
T = T(T.rho1 < DENSITY_CUTOFF,:);
xi = 1:max(T.TSS1);
%%% Weight by the number of runs in each movie
weights = zeros(size(T,1),1);
for curMovie = unique(T.movie)'
    f = strcmp(curMovie,T.movie);
    weights(f) = sum(f);
end
weights = 1 - (weights / sum(weights));

bootfun1 = @(Ti) sum(Ti.state0 < 3 & Ti.state1 == 3) / sum(Ti.state0 < 3);
bootfun2 = @(Tb,x) bootfun1(Tb(Tb.TSS1 > x - WINDOW & Tb.TSS1 < x + WINDOW,:));
bootfun3 = @(Tb) bootloop(Tb,xi,bootfun2);

tic
    ci_outside = bootci(NBOOT,{bootfun3,T},'type','cper','Weights',weights);
toc

m_outside = mean(ci_outside);

%% Boot strapping P(non-persistent): Inside
T = AllDataTable;
T = T(T.rho1 > 5.5,:);
xi = STABLE_AGG_CUTOFF:max(T.TSS1);
%%% Weight by the number of runs in each movie
weights = zeros(size(T,1),1);
for curMovie = unique(T.movie)'
    f = strcmp(curMovie,T.movie);
    weights(f) = sum(f);
end
weights = 1 - (weights / sum(weights));

bootfun3 = @(Tb) bootloop(Tb,xi,bootfun2);
tic
    ci_inside = bootci(NBOOT,{bootfun3,T},'type','cper','Weights',weights);
toc
m_inside = mean(ci_inside);

%% Figure P(non-persistent)
figure, hold on
    plot((1:max(T.TSS1)),ci_outside','--b')
    plot((1:max(T.TSS1)),m_outside,'-b')

    plot((STABLE_AGG_CUTOFF:max(T.TSS1)),ci_inside','--k')
    plot((STABLE_AGG_CUTOFF:max(T.TSS1)),m_inside,'-k')

    ax = gca;
    
    ylim([0,1])
    ax.YTick = 0:0.25:1;
    ax.YTickLabelRotation = 45;
    ylim([0 ax.YLim(2)])

    ax.XTick = (0:5) * 2 * 60;
    ax.XTickLabel = (0:5);
    ax.FontSize = 10;
    box on
    
    if(~PUB_READY)
        title('Transition Probability')
        grid on;
    end

    ylabel('P(non-persistent)')
    xlabel('Time (hr)');
    
    %saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/TransitionsVsTime','Size',[9.25,9],'Style','none','Formats',{'png','fig'},'r',600);

    

