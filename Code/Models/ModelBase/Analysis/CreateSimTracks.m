function [ sim_tracks ] = CreateSimTracks( simTracks, varargin )
% [ sim_tracks ] = CreateSimTracks( simTracks ) 
%      mods x and y directions
%
% [ sim_tracks ] = CreateSimTracks( simTracks, 1 )
%       does not mod x and y directions

    if(~iscell(simTracks))
        warning('simTracks is not of type cell, gracefully exiting');
        sim_tracks = simTracks;
        return;
    end
    
    tt = cell2mat(simTracks');
    [~,I] = sortrows(tt,[8,5]);
    tt = tt(I,:);

    if(length(varargin) > 0)
        sim_tracks.x = tt(:,1);
        sim_tracks.y = tt(:,2);
    else
        sim_tracks.x = mod(tt(:,1),986);
        sim_tracks.y = mod(tt(:,2),740);
    end
    
    sim_tracks.o = tt(:,3);
    sim_tracks.density = tt(:,4);
    sim_tracks.frame = tt(:,5);
    sim_tracks.v     = tt(:,6); 
    sim_tracks.state = tt(:,7);
    sim_tracks.count = tt(:,8);
    sim_tracks.id = tt(:,9);
    sim_tracks.units = 'um';

end

