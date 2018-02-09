classdef APrioriDensityAlignmentField<Field
    %Extends a basic field to provide an a-priori defined cell density
    % at points within the field.
    properties (Constant)
        ASSRTMSG = 'APrioriDensityField';
    end
    
    properties
        density; %Contains density valuse
        
        agg_tracks; %struct of agg positions/properties
        aggs_in_frame; %subStruct of agg_tracks for current frame
        start_density; %Spatial density to initiate model at
        nCells; %Number of cells in model
       
        BINS; % size(density,1);

        %These are used to calculate the x y density bin the cell is in
        %based on its x,y location in um.
        %bins are assumed to be evenly spaced from 0 to
        %field.xSize or filed.ySize, which are in um.
        xBinFactor = 0;
        yBinFactor = 0;
        
        currentStep = 1;
    end
    
    methods
        
        %
        % APrioriDensityAlignmentField(density,start_density,agg_tracks,nCells) 
        %
        % params
        % density       X*Y*T density profiles of size X*Y for each frame T.
        %                  density does not have to be the same as field size
        % start_density Spatial density to initiate model with
        % agg_tracks    struct of agg positions/properties
        % nCells        number of cells in simulation
        function obj = APrioriDensityAlignmentField(density,start_density,agg_tracks,nCells) 
            obj.agg_tracks = agg_tracks;
            obj.aggs_in_frame = subStruct(agg_tracks,agg_tracks.frame == 1);
            obj.nCells = nCells;
            obj.start_density = start_density;
            obj.density = density;
            nBins = size(density,1);
            obj.xBinFactor = nBins / 986;
            obj.yBinFactor = nBins / 740;
        end
        
        %
        % Intilizes or Resets the field
        %
        function [] = reset(obj,modelStats,probs)
            obj.cellList = {};
            obj.currentStep = 1;
                        
            nBins = size(obj.density,1);
            
            Xin = linspace(1,obj.xSize - 1,nBins);
            Yin = linspace(1,obj.ySize - 1,nBins);

            for i = 1:obj.nCells
                [x,y] = pinky(Xin,Yin,obj.start_density);
                obj.cellList{i} = MyxoCell(obj,modelStats,probs,i,x,y);
            end
            
            obj.step(1);
        end
        
        %
        % Called by the Engine when a model step occurs
        %
        %params
        % n how many steps since the begging of the simulation
        function obj = step(obj,n)
            obj.currentStep = max(min(n,size(obj.density,3))-1,1);

            %
            % Provides toridially wrappped aggreagte locations
            %
            obj.aggs_in_frame = subStruct(obj.agg_tracks,obj.agg_tracks.frame == obj.currentStep);
%             aggsNorth = aggs; aggsNorth.y = aggsNorth.y + obj.ySize;
%             aggsSouth = aggs; aggsSouth.y = aggsSouth.y - obj.ySize;
%             aggsEast = aggs;  aggsEast.x = aggsEast.x + obj.xSize;
%             aggsWest = aggs;  aggsWest.s = aggsWest.x - obj.xSize;
% 
%             obj.aggs_in_frame = obj.concatStruct(aggs,aggsNorth);
%             obj.aggs_in_frame = obj.concatStruct(obj.aggs_in_frame,aggsSouth);
%             obj.aggs_in_frame = obj.concatStruct(obj.aggs_in_frame,aggsEast);
%             obj.aggs_in_frame = obj.concatStruct(obj.aggs_in_frame,aggsWest);
        end
        
        %
        % Returns the density at position x,y at the current step
        %
        %params
        % x x position in um
        % y y position in um
        %
        %returns
        % D density
        %
        function D = getDensity(obj,x,y)
            %assert(x > 0 & x < obj.xSize,[obj.ASSRTMSG,'.getDensity X val of ',num2str(x),' out of range']);
            %assert(y > 0 & y < obj.ySize,[obj.ASSRTMSG,'.getDensity Y val of ',num2str(y),' out of range']);
            D = obj.density(...
                ceil(y .* obj.yBinFactor), ...
                ceil(x .* obj.xBinFactor), ...
                obj.currentStep);    
        end
    
        %
        % Returns the aggreagte nearest to positions x,y
        %
        % returns
        % agg centroid x,y
        % agg major,minor axis a,b
        % agg orientation or
        %
        function [agg_props] = getNearestAgg(obj,x,y)
            
            [~,I] = min((obj.aggs_in_frame.x - x).^2 + (obj.aggs_in_frame.y - y).^2);
            %I = 1;
            
            if(isempty(I))
                agg_props.x = NaN;
                agg_props.y = NaN;
                agg_props.a = NaN;
                agg_props.b = NaN;
                agg_props.or = NaN;
            else
                agg_props.x = obj.aggs_in_frame.x(I);
                agg_props.y = obj.aggs_in_frame.y(I);
                agg_props.a = obj.aggs_in_frame.majorAxis(I);
                agg_props.b = obj.aggs_in_frame.minorAxis(I);
                agg_props.or = obj.aggs_in_frame.orientation(I);
            end
        end
        
        %
        % Used in step to add toridally wrapped aggs
        %
        function st1 = concatStruct(obj, st1, st2)
            names = fieldnames(st1);
            for i = names'
                if isstruct(st1.(i{1}))
                    %Skip these
                else
                    st1.(i{1}) = [st1.(i{1}); st2.(i{1})];
                end
            end
        end
    end
end

