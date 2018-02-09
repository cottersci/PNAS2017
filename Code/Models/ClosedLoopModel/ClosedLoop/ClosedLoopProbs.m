classdef ClosedLoopProbs<Probabilities
	%
	% Extends the behvaor logic in the Probabilites class to 
	% include the cell-cell orientation alignemnt included in 
	% the closed loop models
	%
    
    properties
        Init;
        InitFrames; 
    end
    
    methods
        function obj = ClosedLoopProbs(Mdlb,Mdlr,Mdlst,Init,InitFrames)
	        %
	        % Constructor
	        %
	        %params:
	        %   Mdlb  KNNSampler for sampling next run paramaters
	        %   Mdlr  KNNSampler for sampling reversal angle
	        %   Mdlst KNNSampler for sampling next state
			%   Init  Struct containing:
			%          Init.Mdlr   KNNSampler for sampling next reversal angle during the prerun
			%          Init.Mdlrst KNNSampler for sampling next run state during the prerun
			%          Init.Mdlrb KNNSampler for sampling next run behaviors during the prerun
			%   InitFrames number of frames in the prerun
	        %
            obj@Probabilities(Mdlb,Mdlr,Mdlst);
            obj.Init = Init;
            obj.InitFrames = InitFrames;
        end
        
        function [time,spd,theta1,beta1,dist,state1] = getTransitions(obj,TSS1,phi0,chi,Dn1,rho1,state0)   
	        %
	        % Get the transition probilities for a cell
	        %
	        % Variables:
	        %   TSS1    time since beginning of simulation
	        %   phi0    angle to the nearest aggreagte
	        %   Dn1     distnace to the nearest aggreagte
	        %   rho1    local cell density
	        %   state0  current cell state
			%   chi
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
			
            if(TSS1 < obj.InitFrames)
				% Use different behavior logic during the prerun
                [time,spd,theta1,beta1,dist,state1] = obj.getTransitions__(phi0,Dn1,chi,rho1,state0);
                return
            else
                TSS1 = TSS1 - obj.InitFrames - 1;
            end
            
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
            [neighbor, dist(2)] = obj.Mdlr(s).KNN.sample([chi TSS1 Dn1 phi0]);
			%neighbor = randi(length(obj.Mdlr(s).theta1),1,1); % Uncomment to make reversal angle random
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
        
        function [time,spd,theta1,beta1,dist,state1] = getTransitions__(obj,phi0,Dn1,chi,rho1,state0)   
			%
			% Seperate reversal logic used during the prerun. Uses reveral and beahvoir
			% databases contained within obj.Init
			%
			
            dist = zeros(3,1);

            %Get new state
            if(state0 < 3)
                s0 = 1;
            else
                s0 = 2;
            end
            
            [n, dist(1)] = obj.Init.Mdlst(s0).KNN.sample([rho1]);
            state1 = obj.Init.Mdlst(s0).state1(n);

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
            [neighbor, dist(2)] = obj.Init.Mdlr(s).KNN.sample([chi]);
            %neighbor = randi(length(obj.Init.Mdlr(s).theta1),1,1); % Uncomment to make reversal angle random
            theta1 = obj.Init.Mdlr(s).theta1(neighbor);
            beta1 = atan2(sin(theta1 - phi0),cos(theta1 - phi0));
            
            %Get new beahvior
            [neighbors, dist(3)] = obj.Init.Mdlb(s).KNN.sample([rho1]);
            %neighbors = randi(length(obj.Init.Mdlb(s).T.Rt1),1,1); % Uncomment to make behavior random
            time = obj.Init.Mdlb(s).T.Rt1(neighbors) * 2;
            spd =  obj.Init.Mdlb(s).T.Rs1(neighbors) / 2;
        end
    end
    
end

