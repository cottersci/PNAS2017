classdef ModelStats<handle
    %
    % Keeps track of the history of runs that each agent takes
    %

    properties
       startTime = '';
       D;
       tracks = {};

       counter = 1;
    end

    methods

	function obj = ModelStats()
	    obj.startTime = num2str(clock,'%4u-%02u-%02u-%02u-%02u-%02.0f');

       obj.D.Rt1 =    {}; %in min
       obj.D.start_loc= {}; % [xStart yStart] in um
       obj.D.stop_loc = {}; % [xStop yStop] in um
       obj.D.TSS1 =   {}; % in steps
       obj.D.Rs1 =    {}; % in um/min
       obj.D.Rd1 =    {}; % in um
       obj.D.beta1 =  {}; % rad
       obj.D.theta1 = {}; % rad
       obj.D.phi0 =   {}; % rad
       obj.D.rho1 =   {}; % normalized units;
       obj.D.Dn1  =   {}; % um
       obj.D.state1 = {}; % 1,2 or 3;
       obj.D.state0 = {};
       obj.D.id     = {};
    end

    %
    % Add a run from an agent to the history.
    %
    function addRun(obj,id,Rt1,Rs1,Rd1,rho1,TSS1,beta1,theta1,phi0,Dn1,state0,state1,start_loc,stop_loc,track)

        if(obj.counter > length(obj.D.Rt1))
            obj.growStruct();
        end

        obj.D.Rt1{obj.counter} = Rt1;
        obj.D.Rs1{obj.counter} = Rs1;
        obj.D.Rd1{obj.counter} = Rd1;
        obj.D.rho1{obj.counter} = rho1;
        obj.D.TSS1{obj.counter} = TSS1;
        obj.D.beta1{obj.counter} = beta1;
        obj.D.theta1{obj.counter} = theta1;
        obj.D.phi0{obj.counter} = phi0;
        obj.D.Dn1{obj.counter} = Dn1;
        obj.D.state1{obj.counter} = state1;
        obj.D.state0{obj.counter} = state0;
        obj.D.start_loc{obj.counter} = start_loc;
        obj.D.stop_loc{obj.counter} = stop_loc;
        obj.D.id{obj.counter} = id;
        obj.counter = obj.counter + 1;

        obj.tracks{end + 1} = track;
    end

    %
    % Export the agent run history as a table simular to AllDataTable
    %
    function [data,filt] = exportData(obj)
        start = cell2mat(obj.D.start_loc');
        stop = cell2mat(obj.D.stop_loc');

        V1 = [stop(:,1) - start(:,1), stop(:,2) - start(:,2)]';
        direc = atan(V1(2,:) ./ V1(1,:));

%             figure
%             for k = 1:length(V1)
%                 clf
%                 line([0 V1(1,k)],[0 V1(2,k)],'Color','b');
%                 line([0 cos(direc(k))],[0 sin(direc(k))],'Color','m','LineStyle','--')
%                 title(['k = ' num2str(k) ' orientation = ' num2str(rad2deg(direc(k)))]);
%                 axis equal
%                 drawnow
%                 w = waitforbuttonpress;
%             end

        data = table(cell2mat(obj.D.id(1:obj.counter-1))', ...
                     cell2mat(obj.D.Rt1(1:obj.counter-1))', ...
                     cell2mat(obj.D.Rs1(1:obj.counter-1))', ...
                     cell2mat(obj.D.Rd1(1:obj.counter-1))', ...
                     cell2mat(obj.D.rho1(1:obj.counter-1))', ...
                     cell2mat(obj.D.TSS1(1:obj.counter-1))', ...
                     cell2mat(obj.D.beta1(1:obj.counter-1))', ...
                     cell2mat(obj.D.theta1(1:obj.counter-1))', ...
                     cell2mat(obj.D.phi0(1:obj.counter-1))', ...
                     cell2mat(obj.D.Dn1(1:obj.counter-1))', ...
                     cell2mat(obj.D.state1(1:obj.counter-1))', ...
                     cell2mat(obj.D.state0(1:obj.counter-1))', ...
                     start(:,1), ...
                     start(:,2), ...
                     stop(:,1), ...
                     stop(:,2), ...
                     direc', ...
                     'VariableNames', ...
                     { ...
                        'id', ...
                        'Rt1', ...
                        'Rs1', ...
                        'Rd1', ...
                        'rho1', ...
                        'TSS1', ...
                        'beta1', ...
                        'theta1', ...
                        'phi0', ...
                        'Dn1', ...
                        'state1', ...
                        'state0', ...
                        'xstart1', ...
                        'ystart1', ...
                        'xstop1', ...
                        'ystop1' ...   -
                        'orientation1', ...
                      } ...
                  );

         %remove runs that reverse as their first action, which creates a run of zero distance
         filt = ~isnan(data.orientation1);
         data = data(filt,:);

         %reshape(cell2mat(obj.D.start_loc(1:obj.counter-1)),2,length(obj.D.start_loc(1:obj.counter-1)))';
        %reshape(cell2mat(obj.D.stop_loc(1:obj.counter-1)),2,length(obj.D.start_loc(1:obj.counter-1)))';
        end

        %
        % Preallocate structure space
        %
        function growStruct(obj)
            GROW_BY = 10000;
            fields = fieldnames(obj.D);
            for i = 1:length(fields)
                obj.D.(fields{i}) = [obj.D.(fields{i}) cell(1,GROW_BY)];
            end
        end

        %%%
        % Writes all model data to a file named [sim-start-time]-tracks
        %%%
        function save(obj)
            m = matfile([obj.startTime, '-tracks.mat'],'Writable',true);
            m.simTracks = obj.tracks;
            %m.runStartTime = obj.runStartTime;
            %m.runPeriod = obj.runPeriod;
            %m.runStart = obj.runStart;
            %m.runStop = obj.runStop;
            %m.runSpeed = obj.runSpeed;
            %m.runStartDensity = obj.runStartDensity;

            %m.stopLength = obj.stopLength;
            %m.stopStartTime = obj.stopStartTime;
            %m.stopStart = obj.stopStart;
            %m.stopStop  = obj.stopStop;
        end
    end
end
