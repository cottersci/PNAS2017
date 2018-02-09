function [Mdlb, Mdlr, Mdlst, Init] = create_search_trees(AllDataTable)
    %
    % Creates the samplers used by the Probabilites class
    % to sample the run databased based on a set of dependencies
    % 
    
    addpath('Models/ModelBase')

    T = AllDataTable;
    T = T(~isnan(T.theta1),:); %Remvoes 5 runs that move no distance, leaving theta, phi, and beta undefined
                               %Since there is so few, they sould have no effect on aggregation and are easiest
                               %just to remove. 

    % Create search trees
    T.cos_beta1 = cos(T.beta1);
    T.cos_phi0 = cos(T.phi0);

    clear Mdlst
    Ti = T(T.state0 < 3,:);
    Mdlst(1).KNN = KNNSampler([
                               Ti.TSS1, ...
                               Ti.rho1, ...
                               Ti.cos_phi0, ...
                               Ti.Dn1 ...
                            ]);         
    Mdlst(1).state1 = Ti.state1;
    Ti = T(T.state0 == 3,:);
    Mdlst(2).KNN = KNNSampler([
                               Ti.TSS1, ...
                               Ti.rho1, ...
                               Ti.cos_phi0, ...
                               Ti.Dn1 ...
                            ]);         
    Mdlst(2).state1 = Ti.state1;

    clear Mdlr;
    clear Mdlb;
    Ti = T(T.state0 < 3 & T.state1 < 3,:);
    % Mdlr(1).KNN = KNNSampler([Ti.TSS1 Ti.Dn1 Ti.phi0]);
    Mdlr(1).KNN = KNNSampler([Ti.TSS1 Ti.Dn1 Ti.phi0]);
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
    Mdlr(2).KNN = KNNSampler([Ti.TSS1 Ti.Dn1 Ti.phi0]);
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
    Mdlr(3).KNN = KNNSampler([Ti.TSS1 Ti.Dn1 Ti.phi0]);
    Mdlr(3).theta1 = Ti.theta1;

    Mdlb(3).KNN = KNNSampler([
                               Ti.TSS1, ...
                               Ti.rho1, ...
                               Ti.cos_beta1, ...
                               Ti.Dn1 ...
                            ]);         
    Mdlb(3).T = Ti;

    %%% Prerun Probs
    %%%%%%%%%%%%%%%%%%%%%%
    T = T(T.TSS1 <= 20,:); 

    clear Init
    %%% State Choise %%%
    % Was moving
    Ti = T(T.state0 < 3,:);
    Init.Mdlst(1).KNN = KNNSampler([
                               Ti.rho1, ...
                            ]);         
    Init.Mdlst(1).state1 = Ti.state1;

    % Was Stopped
    Ti = T(T.state0 == 3,:);
    Init.Mdlst(2).KNN = KNNSampler([
                               Ti.rho1, ...
                            ]);         
    Init.Mdlst(2).state1 = Ti.state1;

    %%% Bevhaior/Reversal Choise %%%
    % Moving to Moving
    Ti = T(T.state0 < 3 & T.state1 < 3,:);
    Init.Mdlr(1).KNN = KNNSampler([Ti.chi]);
    Init.Mdlr(1).theta1 = Ti.theta1;

    Init.Mdlb(1).KNN = KNNSampler([
                               Ti.rho1, ...
                            ]);         
    Init.Mdlb(1).T = Ti;

    %Moving To stop
    Ti = T(T.state0 < 3 & T.state1 == 3,:);
    Init.Mdlr(2).KNN = KNNSampler([Ti.chi]);
    Init.Mdlr(2).theta1 = Ti.theta1;

    Init.Mdlb(2).KNN = KNNSampler([
                                Ti.rho1, ...
                            ]);         
    Init.Mdlb(2).T = Ti;

    %Stop To moving
    Ti = T(T.state0 == 3 & T.state1 < 3,:);
    Init.Mdlr(3).KNN = KNNSampler([Ti.chi]);
    Init.Mdlr(3).theta1 = Ti.theta1;

    Init.Mdlb(3).KNN = KNNSampler([
                                Ti.rho1, ...
                            ]);         
    Init.Mdlb(3).T = Ti;

end

