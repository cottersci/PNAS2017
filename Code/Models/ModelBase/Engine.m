classdef Engine<handle
    %Performs the actual stepping of the model though time and provides
    % helper functions for viewing the model and extracting model data
	% 
	% An example of how to run the model can be found in 
	%   Models/ClosedLoopModel/SimulationCreation/Testing/TestSimulation.m

    properties
        field;             %The field in which the cell exist
        fieldView;         %Draws a GUI view of the model
        modelStats;        %Model stats
        stepsElapsed;      %number of steps that have occured
        probs;             %Cell behavior model
    end

    methods
        %
        %Construct a simulation
        %
        %params:
		%  field: Field object containing the 
		%       cells and enviorment logic
		%  probs: Probabilities object containing 
		%		the behavoir logic the cells should follow
        function obj = Engine(field,probs)
            obj.field = field;
            obj.probs = probs;
            obj.fieldView = FieldView(obj.field);
            obj.reset(); %Populate the simulation
            fprintf('\n');
        end

        %
        %Reset the simulation
        %
        function reset(obj)
            obj.stepsElapsed = 0;
            obj.modelStats = ModelStats();
            obj.field.reset(obj.modelStats,obj.probs);

            obj.fieldView.update();
            obj.sanityCheck();
        end

        %
        % Step the model forwrad N steps
        %
        % N the number of steps forward
        function loop(obj,N)
            fprintf('\n\n');

            p = Progress(N);
            for i = 1:N
                p.d(i);
                obj.step();
            end
            p.done();
        end

        %
        % Step the model one step forward in time
        %
        function step(obj)
            obj.stepsElapsed = obj.stepsElapsed + 1;
            obj.field.step(obj.stepsElapsed);

            for i = 1:obj.field.nCells
                obj.field.cellList{i}.step(obj.stepsElapsed);
            end

            obj.fieldView.update();
        end

        %
        % Toggle a GUI view of the model
        %
		%params:
        %   value:
        %       'on'    Turn view on
        %       'off'   Turn view off
        function view(obj,value)
            switch value
                case 'off'
                    obj.fieldView.viewOFF();
                case 'on'
                    obj.fieldView.viewON();
            end
        end
        
        %
        % Return agent trajectory data
        %
		% simTracks structure is the same as for experimental trajectories, see README for details
		%
        % Without "Flusing" exportTracks will return the tracks for each agent
        % up to its last state change. "Flushing" will force the agents to add data 
		% up to the last simulations step to the simTracks object, but the agent's trajectory
		% will be corrupted if the model is steped forward in time after a flush.
        %
        % simTracks =
        %       exportTracks()
        %           Exports a struct simular to m_tracks
        %       exportTracks(noflush)
        %           Passing in any value skips flushing data from cells
        %
        function simTracks = exportTracks(obj)
            %Force remaning track data into modelStats
            if(nargin == 1)
                for i = 1:obj.field.nCells
                    obj.field.cellList{i}.flush();
                end
            end

            simTracks = obj.modelStats.tracks;
        end

        %
        % Return agent run data
        %
		% modelData structure is the same as for experimental runs, see README for details
		%
        % See exportTracks for details about noflush. In the case of runs
        % a flushed agent adds a partial run to the run database
        % that ends at the agents current position
        %
        % modelData =
        %       exportData()
        %           Exports a table of run variables simular to AllDataTable
        %       exportData(noflush)
        %           Passing in anything skips flushing data from cells
        %
        function modelData = exportData(obj,varargin)
            if(nargin == 1)
                for i = 1:obj.field.nCells
                    obj.field.cellList{i}.flush();
                end
            end

            modelData = obj.modelStats.exportData();
        end

        %
        %Destructor
        %
        function delete(obj)
            obj.fieldView.viewOFF();
        end

        %
        % Performs model state checks for after reset or initlization
        %
        function sanityCheck(obj)
            % Check on a few things and throw warnings
            if(obj.stepsElapsed ~= 0)
                warning('Steps Elapsed not starting at 0')
            end
            if(obj.field.currentStep < 1 || obj.field.currentStep > size(obj.field.density,3))
                Error('Field currentStep is starting outside the range 1 , size(density,3)')
            end
        end
    end

end
