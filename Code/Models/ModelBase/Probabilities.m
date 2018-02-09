classdef Probabilities
    %
    % Contains the behavoir logic for deciding what the next
    % behavoir of a MyxoCell should be
    %

    properties
        Mdlb;  % KNNSampler for sampling next run paramaters
        Mdlr;  % KNNSampler for sampling reversal angle
        Mdlst; % KNNSampler for sampling next state
    end

    methods

        %
        % Constructor
        %
        % Variables:
        %   Mdlb:  KNNSampler for sampling next run paramaters
        %   Mdlr:  KNNSampler for sampling reversal angle
        %   Mdlst: KNNSampler for sampling next state
        %
        function obj = Probabilities(Mdlb,Mdlr,Mdlst)
            obj.Mdlb = Mdlb;
            obj.Mdlr = Mdlr;
            obj.Mdlst = Mdlst;
        end

        %
        % Get the transition probilities for a cell
        %
        % Variables:
        %   TSS1    time since beginning of simulation
        %   phi0    angle to the nearest aggreagte
        %   Dn1     distnace to the nearest aggreagte
        %   rho1    local cell density
        %   state0  current cell state
        %
        % returns
        %   time    duration of next run
        %   spd     speed of next run
        %   theta1  reversal angle prior to next run
        %   beta1   angle between next run and nearest aggreagte
        %   dist    distance between chosen run from run database and the
        %            current cell state for (1) Mdlst, (2) Mdlr, and (3) Mdlb
        %   state1  state of next run
        %
        function [time,spd,theta1,beta1,dist,state1] = getTransitions(obj,TSS1,phi0,Dn1,rho1,state0)
            dist = zeros(3,1);

            %Get new state
            if(state0 < 3)
                s0 = 1;
            else
                s0 = 2;
            end

            [n, dist(1)] = obj.Mdlst(s0).KNN.sample([TSS1, ...
                                               rho1, ...
                                               cos(phi0), ...
                                               Dn1]);
            state1 = obj.Mdlst(s0).state1(n);

            if (state0 < 3 && state1 < 3)
                s = 1;
            elseif(state0 < 3 && state1 == 3)
                s = 2;
            elseif(state0 == 3 && state1 < 3)
                s = 3;
            else
                error('Bad Transition');
            end

            %Get new reversal angle
            [neighbor, dist(2)] = obj.Mdlr(s).KNN.sample([TSS1 Dn1 phi0]);
            %neighbor = randi(length(obj.Mdlr(s).theta1),1,1);
            theta1 = obj.Mdlr(s).theta1(neighbor);
            beta1 = atan2(sin(theta1 - phi0),cos(theta1 - phi0));

            %Get new beahvior
            [neighbors, dist(3)] = obj.Mdlb(s).KNN.sample([TSS1, ...
                                               rho1, ...
                                               cos(beta1), ...
                                               Dn1]);

            time = obj.Mdlb(s).T.Rt1(neighbors) * 2;
            spd =  obj.Mdlb(s).T.Rs1(neighbors) / 2;
        end
    end

end
