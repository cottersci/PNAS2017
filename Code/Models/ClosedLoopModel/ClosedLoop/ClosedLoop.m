classdef ClosedLoop<Engine
    %The Closed-Loop model esitamtes the biofilm cell desntiy from the
	%  agent positions. Aggregate locations are then extracted from
	%  the estimated cell density. Cell run behaviors are then chosen
	%  based on the estimated cell density and dected aggregate positions
    
    properties
        start_density;
    end
    
    methods        
        function obj = ClosedLoop(probs,nCells,varargin)
	        %
	        %Construct a model using DensityField.m
	        %
	        %params
			% probs         Probabilites() class that drives cell beahvior
			% nCells        number of cells in simulation
			%optional:
	        % start_density A 2D probability matrix of size (Field.xSize,Field.ySize)
			%               used to sample initial cell positions
	        % bandw         KDE bandwith used to calculate cell density
			%
			
            p = inputParser;
            addRequired(p,'probs',@(x) isa(x,'ClosedLoopProbs'));
            addRequired(p,'nCells',@isnumeric);
            addOptional(p,'StartDensity',[],@isnumeric);
            addOptional(p,'bandwidth',15,@isnumeric)
            parse(p,probs,nCells,varargin{:});  
            
            obj@Engine( ...
                        DensityField(p.Results.bandwidth, ...
                                     p.Results.StartDensity, ...
                                     p.Results.nCells), ...
                        p.Results.probs ...
                       );
        end
        
        function reset(obj)
            obj.stepsElapsed = 0;
            obj.modelStats = ClosedLoopModelStats();            
            obj.field.reset(obj.modelStats,obj.probs);
            
            obj.fieldView.update();
            obj.sanityCheck();
        end
    end
end

