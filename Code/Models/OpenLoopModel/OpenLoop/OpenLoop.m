classdef OpenLoop<Engine
    %
	% OpenLoop model models agents over an input biofilm cell density.
	% That is, agents do not affect biofilm cell density, instead 
	% it is input as a variable and should be the measured cell densities
	% in each frame of the experimental data
	%
    
    properties
        start_density;
    end
    
    methods        
        %
        %Construct a model with an A-priori field
        %
        %params
        % density       X*Y*T density profiles of size X*Y for each frame T.
        %                  density does not have to be the same as field size
        % start_density Spatial density to initiate model with
        % probs         Probabilites() class that drives cell beahvior
        % agg_tracks    struct of agg positions/properties
        % nCells        number of cells in simulation
        function obj = OpenLoop(density,start_density,probs,agg_tracks,nCells)    
            obj@Engine( ...
                        APrioriDensityAlignmentField(density, ...
                                                     start_density, ...
                                                     agg_tracks, ...
                                                     nCells), ...
                        probs ...
                       );
        end
    end
end

