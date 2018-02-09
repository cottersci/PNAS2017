
function [group_pos,group_box_pos] = gboxplot(data,labels,varargin)
% gboxplot(data,labels,opts)
% gboxplot(axes,data,labels,opts)
%
% Extends the built in boxplot function by:
%     1) adding support for mutiple groups of box plots
%     2) Replacing box plot labels with text boxes for easier formatting
%
% INPUTS:
% data: The data to be plotted. Can take one of two formats:
%         1) a 1xN cell containing N vectors. Each vector will be one box
%         plot
%         2) a 1xM cell containing M cells, where each child cell is a 1xN
%         cell containing N vectors. Each M cell will be plotted as a
%         group of N boxplots.
% labels: labels for the boxplots
%
% Optional INPUTS:
% 'legend': 1xM cell containing legend labels for boxplot groups
% 'axis': Axis in which to plot
% 'jitter': Plots the data points on top of the box plot, with jitter
% 'jitterWidth': value: data will be ploted +/-value 
%                   around the box plot x center 
% 'markerSize': Size of markers of the jittered datapoints
% 
% all other optional arguments are passed directly to the underlying boxplot call. 

% Author: Chris Cotter (cotter@sciencesundries.com)

    %%%
    %Parse input
    %
    %A custom parser is used so that the unrecosnized variables
    %can be passed to the boxplot command
    %%%
    if ~iscell(data)
        error('First argument must be of type cell')
    end
    
    if nargin < 2
        labels = arrayfun(@(x){num2str(x)},1:10);
    end
    
    %Default values
    LEGEND = arrayfun(@(x){num2str(x)},1:max(cellfun(@(x) size(x,2),data)));
    GROUP_GAP = .1;
    GAP = 0.2;
    JITTER = false;
    JITTER_WIDTH = 0.5;
    MARKER_SIZE = 7;
    args = {};
    
    i = 1;
    while i <= length(varargin)
        if(ischar(varargin{i}))
            switch(varargin{i})
                case 'legend'
                    i = i + 1;
                    LEGEND = varargin{i};
                case 'axis'
                    i = i + 1;
                    AXIS = varargin{i};
                case 'jitter'
                    JITTER = true;
                case 'jitterWidth' 
                    i = i + 1;
                    JITTER_WIDTH = varargin{i};
                case 'markerSize'
                    i = i + 1;
                    MARKER_SIZE = varargin{i};
                otherwise
                    args{length(args) + 1} = varargin{i};
                    i = i + 1;
                    args{length(args) + 1} = varargin{i};
            end
        end
        i = i + 1;
    end
    
    %%% Parser End    
    if(exist('AXIS') == 1)
        newplot(AXIS);
    else
        newplot(gca)
    end
    hold on;
    ngroups = size(data,2);
    group_pos = zeros(1,ngroups);
    group_box_pos = cell(1,ngroups);
    pos = GAP;
    
    if(iscell(data{1}))
        for group = 1:ngroups

            nplots = size(data{group},2);
            group_box_pos{group} = zeros(1,nplots);
            for i = 1:nplots
                boxplot(data{group}{i},'positions',pos,'labels',{''},'color',color_chooser(i,'lines'),args{:});
                len = length(data{group}{i});
                if(JITTER)
                    plot(repmat(pos,len,1) + ((rand(len,1) - 0.5) * GAP * JITTER_WIDTH),data{group}{i},'.','MarkerSize',MARKER_SIZE,'Color',color_chooser(i,'lines'));
                end
                group_box_pos{group}(i) = pos;
                pos = pos + GAP;
            end

            group_pos(group) = pos - GAP * (1 + (nplots - 1) / 2);
            %hAnnotation = handle(annotation('textbox', 0, 0,'String',num2str(group)));

            %text('Position',[(pos - GAP) / 2 + (group - 1) * GROUP_GAP,-8],'Units','String',labels{group}); 

            pos = pos + GROUP_GAP;
        end
        
        warning('off')
        legend(findobj(gca,'Tag','Box'),LEGEND);
        warning('on')
    else
        nplots = size(data,2);
        %data{i}
        for i = 1:nplots
            boxplot(data{i},'positions',pos,'labels',{''},'color',color_chooser(i,'lines'),args{:});
            if(JITTER)
                len = length(data{i});
                plot(repmat(pos,len,1) + ((rand(len,1) - 0.5) * GAP * JITTER_WIDTH),data{i},'*','Color',color_chooser(i,'lines'));
            end
            group_pos(i) = pos;
            pos = pos + GAP;
        end
    end
    
    set(gca, 'XTick', group_pos, 'XTickLabel', labels);
    set(gca, 'Ticklength', [0 0]);
    
    xlim([0 pos])
    ylim('auto')
    
    hold off;
end



