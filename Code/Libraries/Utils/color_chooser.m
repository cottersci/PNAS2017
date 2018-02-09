
function [ c ] = color_chooser(i, cmap)
%[ c ] = color_chooser(i, cmap)
%Chooses a color c from the colormap cmap 
%such that c = cmap(mod(abs(i)-1,64) + 1,:);
%
%PARAM
% i  position in colormap
% cmap String discribing the colormap cmap = 'lines'
%
%Returns
% c color form colormap cmap

% Author: Chris Cotter (cotter@sciencesundries.com)

    if nargin < 2
        cmap = 'lines';
    end
    map = colormap(cmap); 
    
    if length(i) > 1
        %Map to [min_val max_val] to [0 64]
        min_val = min(i);
        max_val = max(i);

        value = ceil(((i - min_val) / (max_val - min_val)) * 62) + 1;
        
        c = map(value,:);
    else   
        c = map(mod(abs(i)-1,64) + 1,:);
    end
end

% $Log: color_chooser.m,v $
% Revision 1.1  2014/01/29 21:21:54  cotter
% _
%

