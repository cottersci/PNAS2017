classdef DensityField<Field
    %Extends a basic field by estimating the biofilm cell desntiy from the
	%  agent positions. Aggregate locations are then extracted from
	%  the estimated cell density.
	%
    properties (Constant)
        AGG_DESNITY_CUTOFF = 2.3226 %Cutoff density for detecting aggreagtes
                                    %in cells/um^2
        AVE_CELL_DENSITY = 1.12 %Average cell density within the field of view
                                %in cells/um^2
    end
    
    properties
        density; %The x,y density field estiamted for the current step
		
		alignment_field; % A struct containing the (x,y) coordiantes
						 %  the time step of the beginning of the runs
						 %  and the orientation of runs that stated within 
						 %  the last 12 frames. Used for calculating neighbor alignment
						 
        aMdl; % A k-nearest neighbor serach tree of the (x,y) run start
			  % positions in the alignment_field struct
			  
        aggs_in_frame; %A struct containing               
					   % aggs_in_frame.x where x(i) is the x centroid position of the ith aggreagte
					   % aggs_in_frame.y where y(i) is the y centroid position of the ith aggreagte
					   % aggs_in_frame.majorAxis where majorAxis(i) is the major axis 
					   %    of the ith aggreagte as calculated using regionprops  
					   % aggs_in_frame.minorAxis where minorAxis(i) is the minor axis 
					   %    of the ith aggreagte as calculated using regionprops  
					   % aggs_in_frame.area where area(i) is the area in um 
					   %    of the ith aggreagte as calculated using regionprops  
					   % aggs_in_frame.orientation where orientation(i) is the orientation 
					   %    of the ith aggreagte as calculated using regionprops  
					   
        bandw = 15;  %Bandwidth used by kde2d to estimate biofilm cell density
		
        currentStep = 1; 
		
        start_density; % A 2D probability matrix of size (Field.xSize,Field.ySize)
					   %  used to sample initial cell positions
					   
        orientation; %orientation(i) is the orientation of the ith cell
					 % at the current simulation step.
					 
        nCells;  %Number of agents being simulated
		
        xBinFactor = 0; %These are used to calculate the x y density bin the cell is in
        yBinFactor = 0; % based on its x,y location in um. bins are assumed to be evenly 
		                % spaced from 0 to field.xSize or filed.ySize, which are in um.
    end
    
    methods
        function obj = DensityField(bandw,start_density,nCells)
			%
			% Intilize a density field
			%
			%params:
			% bandw 		 Bandwidth used by kde2d to estimate biofilm cell density
			%
			% start_density  A 2D probability matrix of size (Field.xSize,Field.ySize)
			%     	         used to sample initial cell positions
			%
			% nCells 		 Number of agents being simulated
			%
			
            nBins = 2^10;
            obj.nCells = nCells;
            obj.start_density = start_density;
            obj.xBinFactor = nBins / 986;
            obj.yBinFactor = nBins / 740;
            obj.bandw = bandw;
            
            obj.alignment_field.x = [];
            obj.alignment_field.y = [];
            obj.alignment_field.ori = [];
            obj.alignment_field.TSS1 = [];
        end
                 
        function [] = reset(obj,modelStats,probs)
	        %
	        % Intilizes or Resets the field
	        %
			%params:
			% modelStats the ModelStats object for this simulations
			% probs      a ClosedLoopProbs object
			%
			
            obj.cellList = {};
            obj.currentStep = 1;
                        
            if(isempty(obj.start_density))
                for i = 1:obj.nCells
                    obj.cellList{i} = AlignedCell(obj,modelStats,probs,i);
                end
            else
                XSpace = linspace(1,obj.xSize,2^10);
                YSpace = linspace(1,obj.ySize,2^10);
                for i = 1:obj.nCells
                    [x,y] = pinky(XSpace,YSpace,obj.start_density);
                    obj.cellList{i} = AlignedCell(obj,modelStats,probs,i,x,y);
                end
            end
            
            obj.step(1);
        end

        function obj = step(obj,n)
	        %
	        % Called by the Engine when a model step occurs
	        %
	        %params
	        % n how many steps since the begging of the simulation
			%
			
            obj.currentStep = max(n,1);
            obj.updateDensity();
        
            obj.alignment_field = subStruct(obj.alignment_field,obj.alignment_field.TSS1 > n - 12);
            obj.aMdl = createns([obj.alignment_field.x obj.alignment_field.y]);
        end
        
        function obj = updateDensity(obj)
	        %
	        % Internal function to calculate the biofilm density,
	        % detect aggreagtes, and find the agent orientatiosn at each step. 
			% Updates the class variables orientation, aggs_in_frame, and density
	        %

			cellList = obj.cellList;
			coords = zeros(length(cellList),2);
			obj.orientation = zeros(length(cellList),1);
			for i = 1:length(cellList)
			    [coords(i,1), coords(i,2)] = cellList{i}.getWrappedPosition();
			    obj.orientation(i) = cellList{i}.ori;
			end

			bwd = ([obj.bandw obj.bandw] ./ [986 740]).^2;
			[~, d, ~] = kde2d(coords,2^10,[0 0],[obj.xSize obj.ySize],bwd(1),bwd(2));
			d = d * obj.AVE_CELL_DENSITY * 2^10 * 2^10;
			obj.density = d;

			bw = imresize(obj.density,[obj.ySize,obj.xSize]) > obj.AGG_DESNITY_CUTOFF;
			props = regionprops(bw,'MajorAxis','MinorAxis','Centroid','BoundingBox','Orientation','Area');
			XY = [props.Centroid];
			XY = reshape(XY,[2,length(XY) / 2])';
			obj.aggs_in_frame.x = XY(:,1);
			obj.aggs_in_frame.y = XY(:,2);
			obj.aggs_in_frame.majorAxis = [props.MajorAxisLength]';
			obj.aggs_in_frame.minorAxis = [props.MinorAxisLength]';
			obj.aggs_in_frame.area      = [props.Area]';
			obj.aggs_in_frame.orientation = [deg2rad([props.Orientation]')];
        end
        

        function D = getDensity(obj,x,y)
	        %
	        % Returns the density at position x,y at the current step
	        %
	        %params
	        % x x position in um
	        % y y position in um
	        %
	        %returns
	        % D density
			
            assert(x > 0 & x < obj.xSize,['X val of ',num2str(x),' out of range']);
            assert(y > 0 & y < obj.ySize,['Y val of ',num2str(y),' out of range']);
            
            D = obj.density(...
               ceil(y .* obj.yBinFactor), ...
               ceil(x .* obj.xBinFactor));            
        end
    
        function [agg_props] = getNearestAgg(obj,x,y)
			%
			% Finds the aggregate centroid nearest to the position
			% x,y
			%
			%params
			%  x,y the position to find the nearest aggreagte to.
			%
			%returns
			% agg_props a struct contining the following properotes of the
			%   nearest aggreagte:
			%   	agg_props.x    x centroid coodinate
			%       agg_props.y    y centroid coodinate
			%       agg_props.a    major axis of aggreagte
			%       agg_props.b    minor axis of aggregate
			%       agg_props.or   orientation of aggregate
			%       agg_props.area area of aggregate
			%
			
            if(isempty(obj.aggs_in_frame.x))
                agg_props.x = NaN;
                agg_props.y = NaN;
                agg_props.a = NaN;
                agg_props.b = NaN;
                agg_props.or = NaN;
				agg_props.area = NaN;
            else
                [~,I] = min((obj.aggs_in_frame.x - x).^2 + (obj.aggs_in_frame.y - y).^2);

                agg_props.x = obj.aggs_in_frame.x(I);
                agg_props.y = obj.aggs_in_frame.y(I);
                agg_props.a = obj.aggs_in_frame.majorAxis(I);
                agg_props.b = obj.aggs_in_frame.minorAxis(I);
                agg_props.or = obj.aggs_in_frame.orientation(I);
				agg_props.area = obj.aggs_in_frame.area(I);
            end
        end
    
        function [ksi,strength] = getAlignment(obj,x,y,~)
			%
			% Calculates the avearge angle of nearbuy runs within 
			% the window of DensityField.TIME_CUTOFF, DensityField.RADIUS_CUTOFF
			%
			%params:
			% x,y the x,y coordinates to center the DensityField.RADIUS_CUTOFF
			%
			%returns:
			% ksi the average neumatic angle of the runs within the window of 
			%       DensityField.TIME_CUTOFF, DensityField.RADIUS_CUTOFF
			%
			
            if(isempty(obj.aMdl.X))
                ksi = rand * pi - pi/2;
                strength = 0;
                return
            end
            
            idx = rangesearch(obj.aMdl,[x,y],20);
            idx = idx{1};
            
            if(length(idx) < 2)
                %error('No surrounding Cells\n');
                ksi = rand * pi - pi/2;
                strength = 0;
                return
            end
            
            angles = 2 * atan(sin(obj.alignment_field.ori(idx)) ./ cos(obj.alignment_field.ori(idx)));
            %o = atan(sin(o)/cos(o));
            ksi = atan2(sum(sin(angles(2:end))),sum(cos(angles(2:end)))) / 2;
            strength = mean(cos(angles(1) - angles(2:end)));
            
                %             if(obj.currentStep > 35)
%                 clf, hold on;
%                 for i = 1:length(angles)
%                     line([0 cos(angles(i) / 2)],[0 sin(angles(i) / 2)],'Color',color_chooser(i));
%                 end
%                 h1 = line([0 cos(mean_alignment)],[0 sin(mean_alignment)],'Color','k','LineStyle','--');
%                 h2 = line([0 cos( o)],[0 sin( o)],'Color','r','LineStyle','--','LineWidth',5);
%                 legend([h1 h2],{'Average Angle','Previous Run Vector'})
%                 title(num2str(rad2deg(atan2(sin(2 * (mean_alignment - o)),cos(2 * (mean_alignment - o))) / 2)))
%                 xlim([0 1]);
%                 ylim([-1 1]);
%                 axis equal
%                 drawnow
%                 %waitforbuttonpress
%             end
        end
        
        function [] = registerReversal(obj,x,y,ori,TSS1)
			%
			% Register run for use in calcuting the spatial average 
			%  run orientation within the biofilm
			%
			%params:
			% x,y starting coordiantes of the run
			% ori orientation of the run
			% TSS1 simulation step the run began
			%
			
            obj.alignment_field.x = [obj.alignment_field.x; x];
            obj.alignment_field.y = [obj.alignment_field.y; y];
            obj.alignment_field.ori = [obj.alignment_field.ori; ori];
            obj.alignment_field.TSS1 = [obj.alignment_field.TSS1; TSS1];
        end
    end
end

