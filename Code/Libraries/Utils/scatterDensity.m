
function [im,density_X,density_Y] = scatterDensity(x,y)
% [im,density_X,density_Y] = scatterDensity(x,y,[  [x_min y_min],[x_max y_max] ])
%
% Scatter plot where points are colored based on the local point density. 
%
% params:
% x X point of scatter. treated as x = x(:)
% y Y point of scatter. treated as y = y(:)
%
% optional:
% [x_min y_min]: minimum x and y values to plot. default: calculated by kde2d
% [x_max y_max]: maximum x and y values to plot. default: calculated by kde2d
%
% NOTES:
%   requires kde2d from https://www.mathworks.com/matlabcentral/fileexchange/36153-2d-bandwidth-estimator-for-kde

% Author: Chris Cotter (cotter@sciencesundries.com)
    x = x(:);
    y = y(:);
    
    if(isempty(x) || isempty(y))
        error('x,y must not be empty')
    end

    if(nargin < 3)
        mins = [min(x) min(y)];
        maxs = [max(x) max(y)];
    else
        mins = varargin{1};
        maxs = varargin{2};
    end

    [~,im,density_X,density_Y] = kde2d([x, y],2^10,mins,maxs);

    [~,Xbin] = histc(x,density_X(1,:));
    [~,Ybin] = histc(y,density_Y(:,1));
    C = sub2ind(size(im),max(Ybin,1),max(Xbin,1));
    scatter(x,y,4,im(C),'*');
end