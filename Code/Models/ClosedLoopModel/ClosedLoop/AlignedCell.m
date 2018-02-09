classdef AlignedCell<MyxoCell
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
    end
    
    properties
        ksi;
        chi;
        alignment_strength;
    end
    
    methods
        
        function obj = AlignedCell(field,modelStats,probs,ID,varargin)
	        %
	        %Constructor
	        %
	        % MyxoCell(field,modelStats,probs)
	        %   creates a MyxoCell at a random position within the field
	        %
	        % MyxoCell(filed,modelStats,probs,X,Y)
	        %   creates a MyxoCell at position X,Y within the field
	        %
			
            obj@MyxoCell(field,modelStats,probs,ID);  
        end
       
        function obj = reverse(obj,~,n)
	        %
	        % Reversal Behvaior logic
	        %
			%params:
			% n the current simulation time step
			%
			  
            [density] = obj.field.getDensity(obj.field.wrappedX(obj.location.x),obj.field.wrappedY(obj.location.y));
            [agg_props] = obj.nearestAggProps();

            [ksi,alignment_strength] = obj.field.getAlignment(obj.field.wrappedX(obj.location.x),obj.field.wrappedY(obj.location.y),obj.ori);
            o = atan(sin(obj.ori) / cos(obj.ori)); 
            chi = atan(sin(ksi - o )./cos(ksi - o)); 
            
            [time, spd, revAngle, beta1, ~, state] = obj.probs.getTransitions(n,agg_props.phi,chi,agg_props.dist,density,obj.state);

            stateChange(obj,density,agg_props.phi,chi,ksi,agg_props.dist,revAngle,beta1,n,state,alignment_strength);

%             clf
%             line([0 cos(obj.ori)],[0 sin(obj.ori)],'Color','r','LineStyle','--')
%             line([0 cos(obj.ori + revAngle)],[0 sin(obj.ori + revAngle)],'Color','b','LineStyle','--')  
% 
%             line([0 cos(obj.ori + phi)],[0 sin(obj.ori + phi)],'Color','g');
%             line([0 cos(obj.ori + revAngle + beta1)] * 0.5,[0 sin(obj.ori + revAngle + beta1)] * 0.5,'Color','b');
%             legend('Run 0', ...
%                    'Run 1', ...
%                    'Phi 0', ...
%                    'Beta 1')
%             axis equal
%             xlim([-1 1]);
%             ylim([-1 1]);
%             title(['\phi_{n-1} = ' num2str(rad2deg(phi)) ...
%                    ', \beta_n = ' num2str(rad2deg(beta1)) ...
%                    ', \theta_n = ' num2str(rad2deg(revAngle))]);
%             w = waitforbuttonpress;
            
            obj.stateLength = time;
            obj.speed = spd;
            obj.ori = obj.ori + revAngle;
            obj.field.registerReversal(obj.field.wrappedX(obj.location.x),obj.field.wrappedY(obj.location.y),obj.ori,n);

            %obj.ori = 0; %obj.ori + chi + pi;
            %obj.ori = mod(obj.ori,2*pi);
                                 
            obj.move();
        end
        

        function stateChange(obj,density,phi0,chi,ksi,Dn1,theta1,beta1,TSS1,state,alignment_strength)
           %
           % Called when the agent state changes to update interal agent state and to record the previous
		   % run in modelStats
           %
		   
           if(obj.stepsInState ~= -1) %Avoid reproting the initilizaiton state
               dist = sqrt((obj.xStart - obj.location.x).^2 + ...
                           (obj.yStart - obj.location.y).^2);
               duration = obj.stepsInState / 2;
               speed =  dist / duration;
               obj.modelStats.addRun(obj.ID, ...
                                     duration, ... 
                                     speed, ...
                                     dist, ...
                                     obj.rho1,...
                                     obj.TSS1,...
                                     obj.beta1,...
                                     obj.theta1,...
                                     obj.phi0,...
                                     obj.chi, ...
                                     obj.ksi, ...
                                     obj.alignment_strength,...
                                     obj.Dn1, ...
                                     obj.prev_state, ...
                                     obj.state, ...
                                     [obj.xStart obj.yStart],... 
                                     [obj.location.x obj.location.y],... 
                                     cell2mat(obj.pos')); 
           end
            
            
            obj.xStart = obj.location.x;
            obj.yStart = obj.location.y;
            obj.rho1 = density;
            obj.phi0 = phi0;
            obj.beta1 = beta1;
            obj.Dn1 = Dn1;
            obj.theta1 = theta1;
            obj.TSS1 = TSS1;
            obj.prev_state = obj.state;
            obj.state = state;
            obj.ksi = ksi;
            obj.chi = chi;
            obj.alignment_strength = alignment_strength;
            obj.stepsInState = 1;
            
            obj.pos = {};
        end
        
        function flush(obj)
			%
			% Forces a write of tracks data to model stats.
			% Does not write any run information.
			%
			
           dist = sqrt((obj.xStart - obj.location.x).^2 + ...
                       (obj.yStart - obj.location.y).^2);
           duration = obj.stepsInState / 2;
           speed =  dist / duration;
           obj.modelStats.addRun(obj.ID, ...
                     duration, ... 
                     speed, ...
                     dist, ...
                     obj.rho1,...
                     obj.TSS1,...
                     obj.beta1,...
                     obj.theta1,...
                     obj.phi0,...
                     obj.ksi, ...
                     obj.chi, ...
                     obj.alignment_strength, ...
                     obj.Dn1, ...
                     obj.prev_state, ...
                     obj.state, ...
                     [obj.xStart obj.yStart],... 
                     [obj.location.x obj.location.y],... 
                     cell2mat(obj.pos')); 
            obj.pos = {};
        end
        
    end
    
end

