function [ s ] = subStruct(struct, filter, varargin)
% Applies the index vector filter to all variables in struct
% returning a struct who's variables only contain the values in filter.
%
% Drops structures inside the struct
% Passes variables containing strings or of length 1 to the new struct unchanged
%
% params:
% struct: The struct to filter
% filter: the filter to apply to the struct
% 
% optinal:
% 'r': sub-structs are recursivelly filtered
%
% Note:
%   This function was mostly depricated by the addtion of tables to MATLAB

% Author: Chris Cotter (cotter@sciencesundries.com)

    RECURSIVE = false;
    if(nargin > 2)
        RECURSIVE = strcmp(varargin{1},'r');
    end
    
    names = fieldnames(struct);
    for i = names'
        if isstruct(struct.(i{1}))
            if RECURSIVE
                s.(i{1}) = subStruct(struct.(i{1}),filter,'r');
            end
        elseif length(struct.(i{1})) == 1 || ischar(struct.(i{1}))
            s.(i{1}) = struct.(i{1});
        else
            s.(i{1}) = struct.(i{1})(filter,:);
        end
    end
end

