Tprobs = T;
bootN = 1;

% %%
% % Creates a random sampling (without replacement) of the values in Tprobs
% %%%
rand_sample = 1:length(Tprobs.rho1); %randi(length(Tprobs.rho1),length(Tprobs.rho1) * bootN,1);
%rand_sample1 = randi(length(Tprobs.phi0),length(Tprobs.phi0) * bootN,1);
density_sample = Tprobs.rho1(rand_sample);
time_sample = Tprobs.TSS1(rand_sample);
%area_sample = Tprobs.area(rand_sample);
chi_sample  = Tprobs.chi(rand_sample);
%beta_sample = Tprobs.beta1(rand_sample);
phi_sample = Tprobs.phi0(rand_sample);
dn_sample =   Tprobs.Dn1(rand_sample); %T.Dn2(rand_sample);
state_sample = Tprobs.state0(rand_sample);
%chi_sample = Tprobs.chi(rand_sample);
sampleN = length(rand_sample);

%%
% Creates a random sampling by choosing a random frame and location then
% finding the phi, dn, and density at that location using the APrioriDensityAlignmentField
% class of the model
%%%
Tprobs = T;
sampleN = 11854 * 2;
sampleN = 103442;
rand_sample = zeros(sampleN,1);
field = APrioriDensityAlignmentField(Kmodel,Kmodel(:,:,1),agg_tracks,1) 
density_sample = zeros(sampleN,1);
%time_sample = ceil(rand(sampleN,1) * max(Tprobs.TSS1));
time_sample = ceil(rand(sampleN,1) * 650);
phi_sample  = zeros(sampleN,1);
dn_sample   = zeros(sampleN,1);
state_sample = Tprobs.state0(randi(height(Tprobs),sampleN,1));

p = Progress(sampleN);
for i = 1:sampleN;
    p.d(i);
    locX = rand * 985 + 1;
    locY = rand * 739 + 1;
    
    field.step(time_sample(i));
    [x,y,a,b,or] = field.getNearestAgg(locX,locY);
    
     a = a/2;
     b = b/2;

     V3 = [x - locX, y - locY]';
     V1 = [cos(rand * 2*pi), sin(rand * 2*pi)]';
     cross_product13 = V1(1,:) .* V3(2,:) - V1(2,:).*V3(1,:);
     phi = acos(dot(V1,V3) ./ (sqrt(sum(V1.^2)) .* sqrt(sum(V3.^2)))) .* sign(cross_product13);

     centered_x = locX - x;
     centered_y = locY - y;
     R = [ cos(or)   -sin(or)
           sin(or)   cos(or)];
     xy = R*[centered_x; centered_y];
     xrotated = xy(1);
     yrotated = xy(2);
     t = atan2(yrotated,xrotated);
     dist = sqrt((centered_x).^2+(centered_y).^2) ...
                                    - a*b / sqrt((b*cos(t)).^2+(a*sin(t)).^2);
    
     phi_sample(i) = phi;
     dn_sample(i) = dist;
     density_sample(i) = field.getDensity(locX,locY);
end
p.done();

%%
results.duration = zeros(length(rand_sample),1);
results.speed = zeros(length(rand_sample),1);
results.revAngle = zeros(length(rand_sample),1);
results.distance = zeros(length(rand_sample),1);
results.beta = zeros(length(rand_sample),1);
results.dist = zeros(length(rand_sample),1);
results.state = zeros(length(rand_sample),1);
results.KNNDist = zeros(length(rand_sample),3);

p = Progress(length(rand_sample));
for i = 1:sampleN
    p.d(i);
    [r,s,o,b,dist,state] = probs.getTransitions(time_sample(i),phi_sample(i),chi_sample(i),dn_sample(i),density_sample(i),state_sample(i),1);
    results.duration(i) = r / 2;
    results.speed(i) = s * 2;
    results.revAngle(i) = o;
    results.distance(i) = r * s;
    results.beta(i) = b;
    results.state(i) = state;
    results.dist(i) = s * 2 * r / 2;
    results.KNNDist(i,:) = dist;
    %   
%     [r,s,o] = probsOld.getTransitions(time_sample(i),phi_sample(i),dn_sample(i),density_sample(i),1,1);
%     results.duration(i) = r / 2;
%     results.speed(i) = s * 2;
%     results.revAngle(i) = o;
end
p.done();

%%
figure
subplot(1,3,1) %Duration
[D,XI,kernel] = ksdensity(results.duration);
plot(XI,D);
hold on;
ksdensity(Tprobs.Rt1,'bandwidth',kernel);

title('duration')
legend('Sampled','Distribution')

subplot(1,3,2) %Speed
[D,XI,kernel] = ksdensity(results.speed);
plot(XI,D);
hold on;
ksdensity(Tprobs.Rs1,'bandwidth',kernel);
title('speed')
legend('Sampled','Distribution')

subplot(1,3,3) %Angle
[D,XI,kernel] = ksdensity(results.revAngle);
plot(XI,D);
hold on;
ksdensity(Tprobs.theta1,'bandwidth',kernel);
title('Rev Angle')
legend('Sampled','Distribution')
xlim([-pi pi])
%%
TOWARDS = 1;
AWAY = 2;
xi = [-40:1:100];
uRd = NaN(length(xi),2);
uRd_sim = NaN(length(xi),2);
WINDOW = 10;


uRd_sim(:,TOWARDS) = movingmeanxy(dn_sample(cos(results.beta) > 0 & time_sample > 160 & results.state < 3), results.duration(cos(results.beta) > 0 & time_sample > 160 & results.state < 3),WINDOW,xi);
uRd_sim(:,AWAY)    = movingmeanxy(dn_sample(cos(results.beta) < 0 & time_sample > 160 & results.state < 3), results.duration(cos(results.beta) < 0 & time_sample > 160 & results.state < 3),WINDOW,xi);

uRd(:,TOWARDS) =    movingmeanxy(Tprobs.Dn1(cos(Tprobs.beta1) > 0 & Tprobs.TSS1 > 160 & Tprobs.state1 < 3),      Tprobs.Rt1(cos(Tprobs.beta1) > 0 & Tprobs.TSS1 > 160 & Tprobs.state1 < 3),WINDOW,xi);
uRd(:,AWAY)    =    movingmeanxy(Tprobs.Dn1(cos(Tprobs.beta1) < 0 & Tprobs.TSS1 > 160 & Tprobs.state1 < 3),      Tprobs.Rt1(cos(Tprobs.beta1) < 0 & Tprobs.TSS1 > 160 & Tprobs.state1 < 3),WINDOW,xi);

figure, hold on;
    %Distribution
    h1 = plot(xi,uRd(:,TOWARDS),'b-')
    plot(xi,uRd(:,AWAY),'b--')

    %Sample
    h2 = plot(xi,uRd_sim(:,TOWARDS),'r-')
    plot(xi,uRd_sim(:,AWAY),'r--')
    
    ax = gca;
    ylim([0 ax.YLim(2)])
    legend([h1 h2], {'Distribution','Sample'})

%%
figure, hold on,
    x = atan(sin(phi_sample)./cos(phi_sample));
    y = atan(sin(results.revAngle)./cos(results.revAngle));
    %scatterDensity(x,y);
    [u,xi] = movingmeanxy(x,y,0.5);
    h1 = plot(xi,u,'LineWidth',2,'Color','r')
    
    t = Tprobs; %(Tprobs.TSS1 < 361,:);
    x = atan(sin(t.phi0)./cos(t.phi0));
    y = atan(sin(t.theta1)./cos(t.theta1));
    %scatterDensity(x,y);
    [u,xi] = movingmeanxy(x,y,0.5);
    h2 = plot(xi,u,'LineWidth',2,'Color','b')
    legend([h1 h2], {'Sampled','Distribution'})
 
%%
figure(99), 
    cla, hold on
    
    WINDOW = 25;
    fun = @(x,y,xi) movingmeanxy(x,cos(2 * y),WINDOW,xi);
    
    xi = 1:10:max(Tprobs.TSS1);
    %nematic_beta = atan(sin(T.beta1)./cos(T.beta1));
    plot(xi,fun(Tprobs.TSS1,Tprobs.beta1,xi),'--b','LineWidth',2)
    
    xi = 1:10:max(time_sample);
    %nematic_beta = atan(sin(data.beta1)./cos(data.beta1));
    plot(xi,fun(time_sample,results.beta,xi),'-r')
    
    title('Average nematic alignment')
    legend('Real','Simulation')
    xlabel('Time (frames)')
    ylabel('Nematic Alignmnet Strength')
   
%%
figure(101), 
    cla, hold on
    
    WINDOW = 25;
    xi = -40:1:100;
    fun = @(x,y) movingmeanxy(x,cos(2 * y),WINDOW,xi);
    
    %nematic_beta = atan(sin(T.beta1)./cos(T.beta1));
    plot(xi,fun(Tprobs.Dn1,Tprobs.beta1),'--b','LineWidth',2)
    
    %nematic_beta = atan(sin(data.beta1)./cos(data.beta1));
    plot(xi,fun(dn_sample,results.beta),'-r')
    
    title('Average nematic alignment')
    legend('Real','Simulation')
    ylabel('Nematic Alignmnet Strength')
    xlabel('Distance From Aggreagte Boundary (\mum)')