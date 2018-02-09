function [] = BatchRunSimulations(results_folder,data_location,varargin)
	addpath('Models/ModelBase')
	addpath('Models/ClosedLoopModel/ClosedLoop')
	addpath('Models/ClosedLoopModel/SimulationCreation')
	addpath('Libraries/Utils')

	Nruns = 3;
	nCells = 10000;
	Nsteps = 600;
	prerun = 180;
	bandwidth = 14;

	opt = inputParser;
	addRequired(opt,'results_folder',@isstr)
	addRequired(opt,'data_location',@isstr)
	addParameter(opt,'Nsteps',Nsteps,@isnumeric)
	addParameter(opt,'Nruns',Nruns,@isnumeric)
	addParameter(opt,'Ncells',nCells,@isnumeric)
	addParameter(opt,'PreRun',prerun,@isnumeric)
	addParameter(opt,'bandwidth',bandwidth,@isnumeric)
	parse(opt,results_folder,data_location,varargin{:})
	opt = opt.Results;
	
	fprintf('##### PARAMATERS ###########\n')
	fprintf('Nruns = %d \n',opt.Nruns)
	fprintf('Ncells = %d \n',opt.Ncells)
	fprintf('Nsteps = %d \n',opt.Nsteps)
	fprintf('prerun = %d \n',opt.PreRun)
	fprintf('bandwidth = %d \n',opt.bandwidth)
	fprintf(['Results Folder: ' opt.results_folder '\n'])
	fprintf(['Data Location: ' opt.data_location '\n'])
	fprintf('############################\n')
	
	load([opt.data_location '/AllDataTable.mat'])
	prs = 0;
	
	mkdir([opt.results_folder]);

	%%% Generate Probs
	%%%%%%%%%%%%%%%%%%  
	[Mdlb, Mdlr, Mdlst, Init] = create_search_trees(AllDataTable);
	probs = ClosedLoopProbs(Mdlb,Mdlr,Mdlst,Init,opt.PreRun);

	%%% Run Simulations
	%%%%%%%%%%%%%%%%%%%
	for run = 1:Nruns
	    %% Run Simulation
	    E = ClosedLoop(probs,opt.Ncells,'bandwidth',opt.bandwidth);
	    E.loop(opt.Nsteps + opt.PreRun);
    
	    %% Save Results
	    data = E.exportData();
	    sim_tracks =  E.exportTracks();
	    save([opt.results_folder '/sim_tracks-' num2str(run)],'sim_tracks');
	    save([opt.results_folder '/sim_data-'  num2str(run)],'data');
	end
end


