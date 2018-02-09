%%%
% Creates Figure of run alignment with neighboring runs. 
%%%
addpath('Libraries/Utils')

% How many bootstrap samples
% 1000 for publication, set to 10 to keep things moving quickly for testing
NBOOT = 10;

% Sliding window size, in um
WINDOW = 20;

% Publication: setting to true supresses some labeling during plotting
% to make plot publication ready, but less visually readable. 
PUB_READY = false;

%%
% Run Vector Alignment vs Distnace from the aggreagte boundary
T = AllDataTable;
T = T(~isnan(T.Dn1),:);
T = T(~isnan(T.theta1),:);
T = T(~isnan(T.neighbor_alignment),:);

% Weight by the number of runs in each movie
weights = zeros(size(T,1),1);
for curMovie = unique(T.movie)'
    f = strcmp(curMovie,T.movie);
    weights(f) = sum(f);
end
weights = 1 - (weights / sum(weights));

xi = [1:max(T.TSS1)];

bootfun = @(x,y) movingmeanxy(x,y,WINDOW,xi);

%Real
tic 
    [bootstatci,bootstatu] = bootci(NBOOT,{bootfun,T.TSS1,T.neighbor_alignment},'type','per','Weight',weights);
toc

%Random
Trand = zeros(height(T),1);

for i = 1:height(T)
    Trand(i) = mean(cos(2 * (T.orientation1(i) - T.orientation1(randi(height(T),3,1)))));
end

tic 
    [bootstatci_rand,bootstatu_rand] = bootci(NBOOT,{bootfun,T.TSS1,Trand},'type','per','Weight',weights);
toc

%%
figure, hold on 
    uRd = mean(bootstatu);
    xi = [1:max(T.TSS1)] / 60 / 2;
    plot(xi,uRd,'b')
    plot(xi,bootstatci(2,:),'--b')
    plot(xi,bootstatci(1,:),'--b')

    uRd = mean(bootstatu_rand);
    plot(xi,uRd,'k')
    plot(xi,bootstatci_rand(2,:),'--k')
    plot(xi,bootstatci_rand(1,:),'--k')

    ax = gca;

    if(~PUB_READY)
        xlabel('Time (hr)')
        ylabel('Neighbor Alignment')
    end

    maxylim = max(abs(ax.YLim));
    box on
    ylim([-maxylim maxylim])
    ax.FontSize = 10;

%saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/AlignmentWithNeighbors','Size',[20.5,13],'Style','none','Formats',{'png','fig'},'r',600);