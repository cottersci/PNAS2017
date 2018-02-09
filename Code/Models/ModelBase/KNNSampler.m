classdef KNNSampler
    %
    % Uses K-nearest neighbor sampling to find the run nearest to a given run
    %

    properties
        prctile_high = [];
        prctile_low = [];

        edge_enable = [];
        mins =[];
        ranges = [];
        data;
    end

    methods
        %
        % Constructor
        %
        % data is an N-observations x N-variables matrix.
        % Data should not be normalized, normalization is performed inside
        % this class
        %
        function obj = KNNSampler(data)
            N = size(data);

            if(N(2) > N(1))
                error('More variables than obersvations')
            end

            obj.mins = min(data);
            obj.ranges = range(data);

            obj.data = bsxfun(@rdivide,bsxfun(@minus,data,obj.mins),obj.ranges);
        end

        %
        % Find the observation in data that most closely matches
        % the passed obs.
        %
        % obs should be a 1 x N-variable array, where N-variable is the same
        % as N-variable of the data matrix KNNSampler was initilized with
        %
        % returns
        %  idx: The index of the observation in data that most closely matches
        %    obs
        %
        %  d: the distances between data(idx,:) and obs
        %
        function [idx, d] = sample(obj,obs)
            dist = obj.getDistances(obs);

            [~,I] = min(dist);
            idx = I;
            d = dist(I);
        end

        %
        % Same as sample() but returns the K nearest observations in data
        %
        function [idx, d] = sampleK(obj,obs,K)
            dist = obj.getDistances(obs);

            [~,I] = sort(dist);
            idx = I(1:K);
            d = dist(I);
        end

        %
        % Same as sample() but returns all observations in data within D distance
        %
        function [idx, d] = sampleD(obj,obs,D)
            dist = obj.getDistances(obs);

            I = find(dist < (D ./ sum(obj.ranges)));
            idx = I;
            d = dist(I);
        end

        %
        % Find the normalized distance between all observations in data and obs
        %
        % returns
        %  dist: a N-observations x 1 array of the  normalized
        %     distance between each observation in data and obs
        %
        function [dist] = getDistances(obj,obs)
            obs = (obs - obj.mins) ./ obj.ranges;

            %Values just above and below one provide wiggle room
            % for rounding errors.
            %h_outside_range = obs > obj.prctile_high & obj.edge_enable;
            %l_outside_range = obs < obj.prctile_low & obj.edge_enable;

            %obs(h_outside_range) = obj.prctile_high(h_outside_range);
            %obs(l_outside_range) = obj.prctile_low(l_outside_range);

            colfilt = ~isnan(obs); %obs that are NaN are ingored
            dist = sum(abs(bsxfun(@minus,obj.data(:,colfilt),obs(colfilt))),2);
        end

%%         function [idx, do] = sampleDebugger(obj,obs)
%             obs = (obs - obj.mins) ./ obj.ranges;
%
%             %Values just above and below one provide wiggle room
%             % for rounding errors.
%             h_outside_range = obs > 1.0001;
%             l_outside_range = obs < -0.0001;
%
%             obs(h_outside_range) = obj.prctile_high(h_outside_range);
%             obs(l_outside_range) = obj.prctile_low(l_outside_range);
%
%             colfilt = ~isnan(obs); %obs that are NaN are ingored
%             objD = abs(bsxfun(@minus,obj.data(:,colfilt),obs(colfilt)));
%             dist = sum(objD,2);
%
%             [~,I] = min(dist);
%             idx = I;
%             d = dist(I);
%             do = min(objD);
%         end
    end
end
