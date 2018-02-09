% Author: Chris Cotter (cotter@sciencesundries.com)
classdef Progress<handle
	%
	% Track progress of loop
	%
	% based off of https://www.mathworks.com/matlabcentral/fileexchange/8564-progress
	%
	% Example:
	%
	% N = 100;
	% p = Progress(N)
	% for i = 1:N
	% 	p.d(i)
	%   pause(0.1)
	% end
	% p.done() %<- only really required to get a carrage return
    properties (Constant)
        % Vizualization parameters
        strPercentageLength = 10;   %   Length of percentage string (must be >5)
        strDotsMaximum      = 10;   %   The total number of dots in a progress bar
    end
    
    properties
        strCR = -1;
        max_value = NaN;
        last_time_stamp = [0 0 0 0 0 0];
        time_per_step;
        c = -1;
    end
    
    methods
        function obj = Progress(max_value)
			%
			% Create a progress bar
			%
			% params:
			% max_value: progress is at 100% at this value.
			%
			% returns:
			% obj (Progress): a progress bar object with a max value of max_value
			%
            obj.max_value = max_value;
        end
        
        function d(obj,p)
			%
			% Update/Show the progress bar
			%
			% params:
			% p: the current progress toward max_value. 
			%    percent finished is caluclated as
			%    p/max_value * 100
			%
            obj.update(p/obj.max_value);
        end
        
        function done(obj)
			%
			% Resets the Progress bar and prints a 
			% carrage return.
			%
            fprintf(['\n']);
            obj.strCR == -1;
        end

        function update(obj,frac)
            % internal function to update progress bar
            c = floor(frac .* 100);
            
            if(obj.c == c)
                return
            end
            
            percentageOut = [num2str(c) '%%'];
            percentageOut = [percentageOut repmat(' ',1,obj.strPercentageLength-length(percentageOut)-1)];
            nDots = floor(c/100*obj.strDotsMaximum);
            dotOut = ['[' repmat('.',1,nDots) repmat(' ',1,obj.strDotsMaximum-nDots) ']'];

            time = clock();
            if(any(obj.last_time_stamp))
                time_taken = etime(time,obj.last_time_stamp);
                if(isempty(obj.time_per_step))
                    obj.time_per_step = time_taken ./ (c - obj.c);
                else
                    obj.time_per_step = obj.time_per_step + 0.1 * (time_taken ./ (c - obj.c) - obj.time_per_step);
                end
                time_remaining = obj.time_per_step * (100 - c);
                if(time_remaining > 120)
                    time_out = [' ' num2str(time_remaining / 60) ' min remaining '];
                else
                    time_out = [' ' num2str(time_remaining) ' sec remaining '];
                end
                
                
                strOut = [percentageOut time_out dotOut];
            else
                strOut = [percentageOut dotOut];
            end
            
            % Print it on the screen
            if obj.strCR == -1
                % Don't do carriage return during first run
                fprintf(strOut);
            else
                % Do it during all the other runs
                fprintf(obj.strCR);
                fprintf(strOut);
            end

            % Update persistant variables
            obj.last_time_stamp = time;
            obj.strCR = repmat('\b',1,length(strOut)-1);
            obj.c = c;
        end
    end
end