classdef ClosedLoopModelStats<ModelStats
	%
	% Extends ModelStats to keep track of alignment paramaters of the agent.
	%
    
    properties
    end
    
    methods
        function obj = ClosedLoopModelStats()
            obj@ModelStats();
            obj.D.chi  =   {}; % rad
            obj.D.ksi  =   {}; % rad
            obj.D.area =   {}; % um^2
            obj.D.a_str =  {}; %[-1 1] 
        end

        function addRun(obj,id,Rt1,Rs1,Rd1,rho1,TSS1,beta1,theta1,phi0,chi,ksi,alignment_strength,Dn1,state0,state1,start_loc,stop_loc,track)
		    %
		    % Add a run from an agent to the history.
		    %
			
            addRun@ModelStats(obj,id,Rt1,Rs1,Rd1,rho1,TSS1,beta1,theta1,phi0,Dn1,state0,state1,start_loc,stop_loc,track);
            obj.D.chi{obj.counter-1} = chi;
            obj.D.ksi{obj.counter-1} = ksi;
            obj.D.a_str{obj.counter-1} = alignment_strength;
        end
        
        function data = exportData(obj)
		    %
		    % Export the agent run history as a table simular to AllDataTable
		    %
			
            [data,filt] = exportData@ModelStats(obj);
     
            
            dataprime = table(cell2mat(obj.D.chi(1:obj.counter-1))', ...
                         cell2mat(obj.D.ksi(1:obj.counter-1))', ...
                         cell2mat(obj.D.a_str(1:obj.counter-1))', ...
                         'VariableNames', ...
                         { ...
                            'chi', ...
                            'ksi', ...
                            'astr', ...
                          } ...
                      );
                  
             %remove runs that reverse as their first action, which creates a run of zero distance
             dataprime = dataprime(filt,:);
             
             data = [data dataprime];
        end
    end
end

