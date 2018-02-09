classdef Field<handle
    % The Most Basic Type of Field
    % A field repersents the world in which the Myxo agents move.
    % A basic fild contains a size (X,Y), a list of cells in the field
    % and functions to wrap cells around the field.

    properties
        cellList %A list (of type cell) of all the cells in the field
        xSize = 986; %in um
        ySize = 740; %in um
    end

    methods
        %
        % Constructor
        %
        function obj = Field()

        end

        %
        % Apply wrapped boundary conditions to an x position.
        %
        function x = wrappedX(obj,x)
            x = mod(x - 1,obj.xSize - 1) + 1;
        end

        %
        % Apply wrapped boundary conditions to an y position.
        %
        function y = wrappedY(obj,y)
            y = mod(y - 1,obj.ySize - 1) + 1;
        end

        %
        % Called by Engine to intiate/reset the simulation
        %
        function [] = reset(obj,modelStats,probs);
        end

        %
        % Called by the Engine when a model step occurs
        %
        % n how many steps since the begging of the simulation
        function [] = step(obj,n)
        end
    end

end
