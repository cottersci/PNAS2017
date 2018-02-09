classdef MyxoCell<handle
  %
  % The Most Basic Type of Agent
  %

    properties (Constant)
        MOVING  = 0;
        FORWARD = 1;  %Forward Persistent state
        REVERSE = 2;  %Reverse Persistent state
        STOPPED = 3;  %Non-persistent state
		EPS = 1e-8;   %Small constant to avoid floating-point rounding errors
    end

    properties
        ID; %Agent ID

        %%%
        % Current agent state

        location = XYLocation();   %Location of the agent in um
        ori = 0;                   %agent orientation in rads
        speed = 3;                 %Run Speed (Rs1)
        state = 0;                 %State of the agent
        prev_state = 1;            %Previous state of the agent
        stateCount = 1             %Number of states this agent has seen
        stepsInState = 0;          %Number of steps in current state
        stateLength = 0;           %State duration (Rd1)
        pos                        %Cell trajectory since last state change
        dead = false;              %Dead cells no longer move or report their
                                   % information to ModelStats, effectively
                                   % making them dead

        %%%

        %%%
        % Variables used to make decisions on current run cell state
        % names relate to the names used in AllDataTable

        rho1 = 0;
        xStart;
        yStart;
        beta1 = 0;
        phi0 = 0;
        theta1 = 0;
        Dn1 = 0;
        TSS1 = 1;

        %%%

        %%%
        %Model objects

        field;                     %The field the cell is part of
        modelStats;
        probs;

        %%%

    end

    methods

        %
        %Constructor
        %
        % MyxoCell(field,modelStats,probs)
        %   creates a MyxoCell at a random position within the field
        %
        % MyxoCell(filed,modelStats,probs,X,Y)
        %   creates a MyxoCell at position X,Y within the field
        %
        function obj = MyxoCell(field,modelStats,probs,ID,varargin)
            obj.field = field;
            obj.ID = ID;
            obj.ori = rand * 2 * pi;

            if(nargin < 5) %MyxoCell(field,modelStats,probs,ID)
                obj.location.x = rand * field.xSize;
                obj.location.y = rand * field.ySize;
            else           %MyxoCell(field,modelStats,probs,ID,X,Y)
                obj.location.x = varargin{1};
                obj.location.y = varargin{2};
            end

            assert(obj.location.x > 0 & obj.location.x <= field.xSize, 'Cell X pos out of bounds');
            assert(obj.location.x > 0 <= field.ySize, 'Cell Y pos out of bounds');

            obj.modelStats = modelStats;
            obj.probs = probs;
            obj.stateLength = -1;
            obj.state = ceil(rand * 3);
            obj.stepsInState = -1;
            obj.pos = {};
        end

        %
        % Called by the Engine when a model step occurs
        %
        % Variables:
        %   n: Current step, counting from beginning of simulation
        function obj = step(obj,n)
            if(obj.dead); return; end

            %Cell movement logic
            density = obj.field.getDensity(obj.field.wrappedX(obj.location.x),obj.field.wrappedY(obj.location.y));

            obj.pos{end + 1} = [obj.location.x,obj.location.y, rad2deg(obj.ori), density, n-1, obj.speed, obj.state, obj.stateCount, obj.ID];

            if(obj.stepsInState == obj.stateLength)
                obj.reverse(density,n);
                obj.stepsInState = 1;
                obj.stateCount = obj.stateCount + 1;
            else
                obj.move();
                obj.stepsInState = obj.stepsInState + 1;
            end
        end

        %
        % Move logic
        %
        function obj = move(obj)
            %Update cell location
            obj.location.x = obj.location.x + obj.speed * cos(obj.ori);
            obj.location.y = obj.location.y + obj.speed * sin(obj.ori);
        end

        %
        % Reversal behavior logic
        %
        % Chooses the next cell state, does not have to be a reversal
        %
        % Variables:
        %   n: Current step, counting from beginning of simulation
        %
        function obj = reverse(obj,~,n)
            [density] = obj.field.getDensity(obj.field.wrappedX(obj.location.x),obj.field.wrappedY(obj.location.y));
            [agg_props] = obj.nearestAggProps();

            [time, spd, revAngle, beta1, ~, state] = obj.probs.getTransitions(n,agg_props.phi,agg_props.dist,density,obj.state);

            stateChange(obj,density,agg_props.phi,agg_props.dist,revAngle,beta1,n,state)

%           %%%%
%           % Cell position debugging
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
%           %%%%

            obj.stateLength = time;
            obj.speed = spd;
            obj.ori = obj.ori + revAngle;
            %obj.ori = mod(obj.ori,2*pi);

            obj.move();
        end

        %
        %Called when the cell state changes, passes information to ModelStats
        %
        function stateChange(obj,density,phi0,Dn1,theta1,beta1,TSS1,state)
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

            obj.stepsInState = 1;

            obj.pos = {};
        end

       %
       % Nearest aggregate logic
       %
       % returns a struct containing the following properties for the
       % nearest aggregate:
       %  agg_props.x Aggregate Centroid
       %  agg_props.y Aggregate Centroid
       %  agg_props.a Major Axis
       %  agg_props.b Minor Axis
       %  agg_props.or Orientation (as returned by regionprops)
       %  agg_props.dist Distance to aggreagte boundary
       %     boundary calculated as an ellipse with centroid (x,y) and
       %     major axise (a) and minor axis (b)
       %  agg_props.phi angle enclose between orientation of cell and
       %     vector pointing to centroid of the nearest aggreagte
       %
       function [agg_props] = nearestAggProps(obj)
         [todial_x,todial_y] = obj.getWrappedPosition();

         [agg_props] = obj.field.getNearestAgg(todial_x,todial_y);

         if(isnan(agg_props.b))
             agg_props.dist = NaN;
             agg_props.phi = NaN;
             return
         end

		     [agg_props.phi,agg_props.dist] = obj.calculateAngles(todial_x,todial_y,agg_props);
       end

  	   %
  	   % Calculates distance (dist) and angle (phi) to aggregate
  	   %
  	   function [phi,dist] = calculateAngles(obj,cell_x,cell_y,agg_props)
             a = agg_props.a/2;
             b = agg_props.b/2;

             V3 = [agg_props.x - cell_x, agg_props.y - cell_y]';
             V1 = [cos(obj.ori), sin(obj.ori)]';
             cross_product13 = V1(1,:) .* V3(2,:) - V1(2,:).*V3(1,:);
             phi = acos(dot(V1,V3) ./ (sqrt(sum(V1.^2)) .* sqrt(sum(V3.^2)) + obj.EPS)) .* sign(cross_product13);

             centered_x = cell_x - agg_props.x;
             centered_y = cell_y - agg_props.y;
             R = [ cos(agg_props.or)   -sin(agg_props.or)
                   sin(agg_props.or)   cos(agg_props.or)];
             xy = R*[centered_x; centered_y];
             xrotated = xy(1);
             yrotated = xy(2);
             t = atan2(yrotated,xrotated);
             dist = sqrt((centered_x).^2+(centered_y).^2) ...
                                            - a*b / sqrt((b*cos(t)).^2+(a*sin(t)).^2);

    %              figure(2)
    %              clf
    %              hold on;
    %              plot(todial_x,todial_y,'*')
    %              plot(x,y,'o');
    %              line([todial_x todial_x + V1(1)],[todial_y todial_y + V1(2)],'Color','b');
    %              axis equal
    %
    %              figure(1)
    %              clf
    %              line([0 V3(1)],[0 V3(2)],'Color','r');
    %              line([0 cos(obj.ori + phi)],[0 sin(obj.ori + phi)],'Color','k');
    %              line([0 V1(1)],[0 V1(2)],'Color','b');
    %              legend('Aggregate','Angle To Aggregate','Run Vector')
    %              axis equal
    %              xlim([-1 1]);
    %              ylim([-1 1]);
    %              title([num2str(rad2deg(phi)) ' degrees']);
    %              w = waitforbuttonpress;
    		end

        %
        % Forces a write of tracks data to model stats.
        % Does not write any run information.
        %
        function flush(obj)
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
                     obj.Dn1, ...
                     obj.prev_state, ...
                     obj.state, ...
                     [obj.xStart obj.yStart],...
                     [obj.location.x obj.location.y],...
                     cell2mat(obj.pos'));
            obj.pos = {};
        end

        %
        % Provides the wrapped cell position
        %
        function [x,y] = getWrappedPosition(obj)
            x = obj.field.wrappedX(obj.location.x);
            y = obj.field.wrappedY(obj.location.y);
        end
    end

end
