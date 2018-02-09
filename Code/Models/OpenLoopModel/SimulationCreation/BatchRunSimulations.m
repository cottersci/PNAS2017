function [] = BatchRunSimulations(results_folder,data_location,varargin)
	addpath('Models/ModelBase')
	addpath('Models/OpenLoopModel/OpenLoop')
	addpath('Models/OpenLoopModel/SimulationCreation')
	addpath('Libraries/Utils')

	Nruns = 3;
	nCells = 10000;
	Nsteps = 600;
	
	opt = inputParser;
	addRequired(opt,'results_folder',@isstr)
	addRequired(opt,'data_location',@isstr)
	addParameter(opt,'Nsteps',Nsteps,@isnumeric)
	addParameter(opt,'Nruns',Nruns,@isnumeric)
	addParameter(opt,'Ncells',nCells,@isnumeric)
	parse(opt,results_folder,data_location,varargin{:})
	opt = opt.Results;
	
	fprintf('##### PARAMATERS ###########\n')
	fprintf('Nruns = %d \n',opt.Nruns)
	fprintf('Ncells = %d \n',opt.Ncells)
	fprintf('Nsteps = %d \n',opt.Nsteps)
	fprintf(['Results Folder: ' opt.results_folder '\n'])
	fprintf(['Data Location: ' opt.data_location '\n'])
	fprintf(['Results Folder: ' opt.results_folder '\n'])
	fprintf(['Data Location: ' opt.data_location '\n'])
	fprintf('############################\n')
	
	load([opt.data_location '/AllData.mat']);
	load([opt.data_location '/AllDataTable.mat']);

	mkdir([opt.results_folder]);
	
	prs = 0;
	p = Progress(opt.Nruns * length(AllData));

	for set = 1:length(AllData)
	    p.d(prs)

	    load([opt.data_location '/' AllData{set}.movie{1} '/' 'Kum.mat']);

	    %% Concatonate densites and tracks to align them between movies
	    Kmodel = Kum(:,:,AllData{set}.AlignedStart:AllData{set}.AlignedStop);
	    clear Kum;
	    agg_tracks = AllData{set}.agg_tracks;
	    agg_tracks = subStruct(agg_tracks,agg_tracks.frame >= AllData{set}.AlignedStart & agg_tracks.frame <= AllData{set}.AlignedStop);
	    agg_tracks.frame = agg_tracks.frame - AllData{set}.AlignedStart;

	    %%% Generate Probs
	    %%%%%%%%%%%%%%%%%%
	    [Mdlb, Mdlr, Mdlst, Init] = create_search_trees(AllDataTable(AllDataTable.set == set,:));
	    probs = Probabilities(Mdlb,Mdlr,Mdlst);

	    %% Run Simulations
	    for run = 1:opt.Nruns
	        p.d(prs)

	        %% Run Simulation
	        f = Kmodel(:,:,1);
	        f(f < 0) = 1e-8;
	        E = OpenLoop(Kmodel,f,probs,agg_tracks,opt.Ncells);
	        E.loop(opt.Nsteps);

	        %% Save Results
	        data = E.exportData();
	        sim_tracks = E.exportTracks();

	        save([opt.results_folder '/sim_tracks-' num2str(set) '-' num2str(run)],'sim_tracks');
	        save([opt.results_folder '/sim_data-' num2str(set) '-' num2str(run)],'data');

	        %% Cleanup
	        prs = prs + 1;
	    end
	end
end