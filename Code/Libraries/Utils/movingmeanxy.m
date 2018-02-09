
function [u,xi,c,s] = movingmeanxy(x,y,window,varargin)
    % [u,xi,c,s] = movingmeanxy(x,y,window,[xi])
	%
	% Calculates the centered moving average of y at points x within a window
	%
	% params:
	% (x,y): paried datapoints
	% window: the window in which to calculate the mean
    %    u(i) = mean(y(x >  (xi(i) - window) & x <= (xi(min(i+1,length(xi))) + window)));
    %
	% optional:
	% xi: points at which to center the window. default: sort(unique(x))
	%
	% returns:
	% u: mean inside each window centered at xi
	% xi: points at which the windows are centered
	% c: number of points within the window
	% s: std within the window
	
	% Author: Chris Cotter (cotter@sciencesundries.com)
	
    if(length(x) ~= length(y))
        error('X and Y must be same length');
    end
    if(nargin == 3)
        xi = sort(unique(x));
    else
        xi = varargin{1};
    end
        
    u = zeros(length(xi),1);
    c = zeros(length(xi),1);
    s = zeros(length(xi),1);
    for i = 1:length(xi)
        filter = x >  (xi(i) - window) & ...
                 x <= (xi(min(i+1,length(xi))) + window);
        u(i) = mean(y(filter));
        c(i) = sum(filter);
        s(i) = std(y(filter));
    end
end