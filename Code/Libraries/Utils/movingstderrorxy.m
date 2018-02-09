function [s,xi] = movingstderrorxy(x,y,window,varargin)
    % [u,xi] = movingstderrorxyx,y,window,xi)
	%
	% Calculates standard error of y at points x within a window
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
	% s: standard error of points within the window
	% xi: points at which the windows are centered

	% Author: Chris Cotter (cotter@sciencesundries.com)

    if(nargin == 3)
        xi = sort(unique(x));
    else
        xi = varargin{1};
    end
        
    s = zeros(length(xi),1);
    
    for i = 1:length(xi)
        filter = x >  (xi(i) - window) & ...
                 x <= (xi(min(i+1,length(xi))) + window);
        s(i) = std(y(filter)) / sqrt(sum(filter));
    end
end