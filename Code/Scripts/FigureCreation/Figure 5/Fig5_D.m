%%%
% Creates Figure comparing Run Vector direction with direction to nearest aggreagte centroid
%%%
addpath('Libraries/Utils')

% How many bootstrap samples
% 1000 for publication, set to 10 to keep things moving quickly for testing
NBOOT = 10;

% Sliding window size, in um
WINDOW = 10;

%Number of frames to skip prior to calculating inside aggreagte values
%Set to a frame after aggreagte tracking becomes fairly stable. 
STABLE_AGG_CUTOFF = 160;

% Publication: setting to true supresses some labeling during plotting
% to make plot publication ready, but less visually readable. 
PUB_READY = false;

xi = [-30:1:100];

%% Bootstrapping
T = AllDataTable;
T = T(~isnan(T.Dn1),:);
T = T(~isnan(T.theta1),:);
T = T(T.TSS1 > STABLE_AGG_CUTOFF,:);

bootfun = @(x,y) movingmeanxy(x,y,WINDOW,xi);
bootsdrfun = @(x,y) movingstderrorxy(x,y,WINDOW,xi);
weights = zeros(size(T,1),1);
for curMovie = unique(T.movie)'
    f = strcmp(curMovie,T.movie);
    weights(f) = sum(f);
end
weights = 1 - (weights / sum(weights));

%Real
tic 
    [bootstatci,bootstatu] = bootci(NBOOT,{bootfun,T.Dn1,cos(2 * T.beta1)},'type','student','stderr',bootsdrfun,'Weight',weights);
toc

%Random
x = T.beta1(randperm(height(T))); %This is dummy data. 

tic 
    [bootstatci_rand,bootstatu_rand] = bootci(NBOOT,{bootfun,T.Dn1,cos(2 * x)},'type','student','stderr',bootsdrfun);
toc

%% Figure
figure, hold on 
    uRd = mean(bootstatu);
    plot(xi,uRd,'b')
    plot(xi,bootstatci(2,:),'--b')
    plot(xi,bootstatci(1,:),'--b')

    uRd = mean(bootstatu_rand);
    plot(xi,uRd,'k')
    plot(xi,bootstatci_rand(2,:),'--k')
    plot(xi,bootstatci_rand(1,:),'--k')

    if(~PUB_READY)
        xlabel('Distance to Aggregate Boundary (\mum)')
        ylabel('Alignment to Aggregates')
        grid on
    end

    ax = gca;
    maxylim = max(abs(ax.YLim));
    box on
    ylim([-maxylim maxylim])
    xlim(xi([1,end]))
    ax.FontSize = 10;

%saveFigures('SaveAs','/Users/cotter/Desktop/NewData/Good/Figures/RunBehaviors/AlignmentVsDistnaceToAgg','Size',[20.5,13],'Style','none','Formats',{'png','fig'},'r',600);